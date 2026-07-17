/*
 * test_kernels.c - correctness checks for the fossmark assembly kernels
 *
 * The benchmark's own best-of-N run guards against non-determinism, but a
 * kernel can be perfectly deterministic and still wrong. This file is the
 * "single C file to poke at and test with": it validates each kernel against
 * an independent reference or an invariant, so a mistake in the assembly is
 * caught here rather than silently skewing a score.
 *
 * Every check (except the single-threaded pointer-chase) is run concurrently
 * on all available cores. The kernels take their buffers as arguments and hold
 * no shared state, so a correct kernel must give identical, correct results no
 * matter how many copies run at once; a hidden global or a reentrancy bug would
 * survive a single-threaded run but fail here.
 *
 * Build: cc -O2 -pthread test_kernels.c fossmark.S -o test_kernels -lm
 * Exit status is 0 iff every check passes.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <pthread.h>
#include <unistd.h>

extern uint64_t fm_int_math(uint64_t iters);
extern uint64_t fm_fp_math(uint64_t iters);
extern uint64_t fm_primes(uint64_t limit, uint8_t *sieve);
extern uint64_t fm_simd(uint64_t iters, void *buf);
extern uint64_t fm_compress(const uint8_t *src, uint64_t len, uint32_t *ht);
extern uint64_t fm_chacha20(uint8_t *buf, uint64_t len,
			    const uint8_t key[32], uint64_t rounds);
extern uint64_t fm_physics(double *bodies, uint64_t n, uint64_t steps);
extern uint64_t fm_sort(uint32_t *a, uint64_t n);
extern uint64_t fm_chase(void **ptrs, uint64_t steps);

static int failures = 0;
static int checks   = 0;

/*
 * Concurrency plumbing. Each check runs on every core at once; the counters and
 * stdout are shared, so ok()/note() serialise on this lock. `fm_primary` is set
 * on exactly one thread per check (the one running on the main thread): it owns
 * the human-readable output so the "[ ok ]" lines and diagnostics appear once,
 * not once per core. Every thread still evaluates every assertion, so a failure
 * on any core - even a silent secondary - is reported and counted.
 */
static pthread_mutex_t io_lock = PTHREAD_MUTEX_INITIALIZER;
static __thread int    fm_primary = 1;
static long            fm_ncores  = 1;

static void ok(const char *what, int cond)
{
	pthread_mutex_lock(&io_lock);
	if (fm_primary) {
		checks++;
		if (cond) {
			printf("  [ ok ] %s\n", what);
		} else {
			printf("  [FAIL] %s\n", what);
			failures++;
		}
	} else if (!cond) {
		/* a secondary core disagrees: surface it explicitly */
		printf("  [FAIL] %s (concurrent core)\n", what);
		failures++;
	}
	pthread_mutex_unlock(&io_lock);
}

/* Diagnostic output that should appear once per check, not once per core. */
static void note(const char *fmt, ...)
{
	va_list ap;

	if (!fm_primary)
		return;
	pthread_mutex_lock(&io_lock);
	va_start(ap, fmt);
	vprintf(fmt, ap);
	va_end(ap);
	pthread_mutex_unlock(&io_lock);
}

/* Run `check` on every core simultaneously. The main thread is the primary;
 * fm_ncores-1 workers run the same check as silent secondaries. */
static void *fm_worker(void *arg)
{
	void (*check)(void) = *(void (**)(void))arg;

	fm_primary = 0;
	check();
	return NULL;
}

static void parallel(void (*check)(void))
{
	long extra = fm_ncores - 1;
	pthread_t *th = NULL;
	long i, spawned = 0;

	if (extra > 0) {
		th = calloc((size_t)extra, sizeof *th);
		if (th) {
			for (i = 0; i < extra; i++)
				if (pthread_create(&th[spawned], NULL,
						   fm_worker, &check) == 0)
					spawned++;
		}
	}

	check();			/* primary runs on this thread */

	for (i = 0; i < spawned; i++)
		pthread_join(th[i], NULL);
	free(th);
}

/* ---------- reference implementations ---------- */

static uint64_t ref_prime_count(uint64_t limit)
{
	uint8_t *s = calloc(limit, 1);
	uint64_t count = 0, i, j;

	for (i = 2; i * i < limit; i++)
		if (!s[i])
			for (j = i * i; j < limit; j += i)
				s[j] = 1;
	for (i = 2; i < limit; i++)
		if (!s[i])
			count++;
	free(s);
	return count;
}

/* A textbook scalar ChaCha20 block function, used both to anchor against the
 * RFC 8439 known-answer vector and to validate the NEON kernel block-for-block.
 * `out` receives 64 keystream bytes for the given counter and 12-byte nonce. */
#define ROTL32(x, n) (((x) << (n)) | ((x) >> (32 - (n))))

static void ref_chacha_block(uint32_t out_words[16], const uint8_t key[32],
			     uint32_t counter, const uint8_t nonce[12])
{
	static const uint32_t c[4] = {
		0x61707865, 0x3320646e, 0x79622d32, 0x6b206574
	};
	uint32_t s[16], x[16];
	int i;

	for (i = 0; i < 4; i++)
		s[i] = c[i];
	for (i = 0; i < 8; i++)
		s[4 + i] = (uint32_t)key[4 * i] | (uint32_t)key[4 * i + 1] << 8 |
			   (uint32_t)key[4 * i + 2] << 16 |
			   (uint32_t)key[4 * i + 3] << 24;
	s[12] = counter;
	for (i = 0; i < 3; i++)
		s[13 + i] = (uint32_t)nonce[4 * i] | (uint32_t)nonce[4 * i + 1] << 8 |
			    (uint32_t)nonce[4 * i + 2] << 16 |
			    (uint32_t)nonce[4 * i + 3] << 24;

	memcpy(x, s, sizeof x);
#define QR(a, b, cc, d)                                            \
	x[a] += x[b]; x[d] ^= x[a]; x[d] = ROTL32(x[d], 16);       \
	x[cc] += x[d]; x[b] ^= x[cc]; x[b] = ROTL32(x[b], 12);     \
	x[a] += x[b]; x[d] ^= x[a]; x[d] = ROTL32(x[d], 8);        \
	x[cc] += x[d]; x[b] ^= x[cc]; x[b] = ROTL32(x[b], 7)
	for (i = 0; i < 10; i++) {
		QR(0, 4, 8, 12); QR(1, 5, 9, 13);
		QR(2, 6, 10, 14); QR(3, 7, 11, 15);
		QR(0, 5, 10, 15); QR(1, 6, 11, 12);
		QR(2, 7, 8, 13); QR(3, 4, 9, 14);
	}
#undef QR
	for (i = 0; i < 16; i++)
		out_words[i] = x[i] + s[i];
}

/* ---------- checks ---------- */

static void check_int(void)
{
	/* determinism and non-triviality: the checksum must be stable and
	 * must actually change with the iteration count */
	uint64_t a = fm_int_math(1000);
	uint64_t b = fm_int_math(1000);
	uint64_t c = fm_int_math(2000);

	ok("int_math is deterministic", a == b);
	ok("int_math depends on iters", a != c);
	ok("int_math(0) is zero",       fm_int_math(0) == 0);
}

static void check_fp(void)
{
	uint64_t a = fm_fp_math(1000);
	uint64_t b = fm_fp_math(1000);
	double da;

	memcpy(&da, &a, sizeof da);
	ok("fp_math is deterministic",  a == b);
	ok("fp_math result is finite",  isfinite(da));
	ok("fp_math(0) is zero",        fm_fp_math(0) == 0);
}

static void check_primes(void)
{
	enum { LIM = 1000000 };
	uint8_t *sieve = malloc(LIM);
	uint64_t got = fm_primes(LIM, sieve);
	uint64_t ref = ref_prime_count(LIM);

	note("         primes < %d: got %llu, expected %llu\n",
	     LIM, (unsigned long long)got, (unsigned long long)ref);
	ok("primes matches reference sieve", got == ref);
	ok("primes < 10 == 4",  fm_primes(10, sieve) == 4);   /* 2,3,5,7 */
	ok("primes < 2 == 0",   fm_primes(2, sieve) == 0);
	free(sieve);
}

static void check_simd(void)
{
	uint8_t *buf = aligned_alloc(16, 256);
	uint64_t a, b;

	memset(buf, 0xA5, 256);
	a = fm_simd(500, buf);
	memset(buf, 0xA5, 256);
	b = fm_simd(500, buf);
	ok("simd is deterministic", a == b);
	ok("simd(0) is zero",       fm_simd(0, buf) == 0);
	free(buf);
}

static void check_compress(void)
{
	enum { N = 65536 };
	uint8_t *src = malloc(N);
	uint32_t *ht = malloc((1 << 16) * sizeof(uint32_t));
	uint64_t incompressible, compressible;
	size_t i;

	/* genuinely incompressible data (splitmix64 output): with no matches
	 * to exploit, an LZ coder's output must be at least the input size */
	{
		uint64_t st = 0x1234567890abcdefULL;
		for (i = 0; i < N; i++) {
			uint64_t z = (st += 0x9e3779b97f4a7c15ULL);
			z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ULL;
			z = (z ^ (z >> 27)) * 0x94d049bb133111ebULL;
			src[i] = (uint8_t)(z ^ (z >> 31));
		}
	}
	incompressible = fm_compress(src, N, ht);

	/* all-zero data is maximally compressible: it must shrink hugely */
	memset(src, 0, N);
	compressible = fm_compress(src, N, ht);

	note("         64KiB random -> %llu bytes, 64KiB zeros -> %llu bytes\n",
	     (unsigned long long)incompressible,
	     (unsigned long long)compressible);
	ok("compress expands random data",   incompressible >= N);
	ok("compress shrinks constant data", compressible < N / 10);
	ok("compress is deterministic",      fm_compress(src, N, ht) == compressible);
	free(src);
	free(ht);
}

static void check_crypto(void)
{
	uint8_t key[32];
	size_t i;

	/* (1) anchor the scalar reference to the RFC 8439 s.2.3.2 vector:
	 *     key = 00,01,...,1f; counter = 1; nonce = 00,00,00,09,...,4a,...
	 *     serialised keystream begins 10 f1 e7 e4. */
	{
		uint32_t w[16];
		uint8_t rnonce[12] = {0,0,0,9, 0,0,0,0x4a, 0,0,0,0};
		uint8_t ks0[4];
		for (i = 0; i < 32; i++)
			key[i] = (uint8_t)i;
		ref_chacha_block(w, key, 1, rnonce);
		for (i = 0; i < 4; i++)
			ks0[i] = (uint8_t)(w[0] >> (8 * i));
		note("         ref keystream[0..3] = %02x %02x %02x %02x "
		     "(RFC 8439 expects 10 f1 e7 e4)\n",
		     ks0[0], ks0[1], ks0[2], ks0[3]);
		ok("scalar ChaCha20 matches RFC 8439 vector",
		   ks0[0] == 0x10 && ks0[1] == 0xf1 &&
		   ks0[2] == 0xe7 && ks0[3] == 0xe4);
	}

	/* (2) validate the NEON kernel against that reference. The kernel
	 *     hardwires nonce = 0 and starts the block counter at 0, so we
	 *     compare its keystream to the reference block-for-block. */
	{
		uint8_t buf[128];
		uint8_t zero_nonce[12] = {0};
		uint32_t ref0[16], ref1[16];
		int match = 1;

		for (i = 0; i < 32; i++)
			key[i] = (uint8_t)(i * 5 + 1);
		memset(buf, 0, sizeof buf);		/* zeros -> raw keystream */
		fm_chacha20(buf, sizeof buf, key, 1);

		ref_chacha_block(ref0, key, 0, zero_nonce);
		ref_chacha_block(ref1, key, 1, zero_nonce);
		for (i = 0; i < 16; i++) {
			uint32_t k0 = (uint32_t)buf[4 * i] |
				(uint32_t)buf[4 * i + 1] << 8 |
				(uint32_t)buf[4 * i + 2] << 16 |
				(uint32_t)buf[4 * i + 3] << 24;
			uint32_t k1 = (uint32_t)buf[64 + 4 * i] |
				(uint32_t)buf[64 + 4 * i + 1] << 8 |
				(uint32_t)buf[64 + 4 * i + 2] << 16 |
				(uint32_t)buf[64 + 4 * i + 3] << 24;
			if (k0 != ref0[i] || k1 != ref1[i])
				match = 0;
		}
		ok("NEON ChaCha20 matches scalar reference (2 blocks)", match);
	}

	/* (3) the cipher is a real XOR stream: applying it twice is identity */
	{
		uint8_t plain[128], work[128], k2[32];
		for (i = 0; i < 128; i++)
			plain[i] = (uint8_t)(i * 7 + 1);
		for (i = 0; i < 32; i++)
			k2[i] = (uint8_t)(i * 3);
		memcpy(work, plain, 128);
		fm_chacha20(work, 128, k2, 1);
		ok("chacha20 actually changes data", memcmp(work, plain, 128) != 0);
		fm_chacha20(work, 128, k2, 1);
		ok("chacha20 round-trips (XOR is involutive)",
		   memcmp(work, plain, 128) == 0);
	}
}

static void check_physics(void)
{
	/* two equal masses released from rest must accelerate toward each
	 * other: symmetric, momentum-conserving, and bounded. */
	double bodies[2 * 8] = {0};
	double total_p;

	bodies[0] = -1.0; bodies[3] = 1.0;	/* body 0 at x=-1, mass 1 */
	bodies[8] =  1.0; bodies[11] = 1.0;	/* body 1 at x=+1, mass 1 */

	fm_physics(bodies, 2, 200);

	/* velocities must be equal and opposite (Newton's third law) */
	total_p = bodies[4] + bodies[12];	/* vx0 + vx1 */
	note("         2-body: vx0=%.6f vx1=%.6f (sum should be ~0)\n",
	     bodies[4], bodies[12]);
	ok("physics conserves momentum", fabs(total_p) < 1e-9);
	ok("physics: bodies attract",    bodies[4] > 0.0 && bodies[12] < 0.0);
	ok("physics values stay finite", isfinite(bodies[0]) && isfinite(bodies[8]));
}

static int cmp_u32(const void *p, const void *q)
{
	uint32_t x = *(const uint32_t *)p, y = *(const uint32_t *)q;
	return (x > y) - (x < y);
}

static int is_sorted(const uint32_t *a, size_t n)
{
	for (size_t i = 1; i < n; i++)
		if (a[i - 1] > a[i])
			return 0;
	return 1;
}

static void check_sort(void)
{
	enum { N = 10000 };
	uint32_t *a = malloc(N * sizeof(uint32_t));
	uint32_t *b = malloc(N * sizeof(uint32_t));
	uint64_t s;
	size_t i;
	uint32_t r = 12345;

	for (i = 0; i < N; i++) {
		r = r * 1103515245u + 12345u;
		a[i] = r;
	}
	memcpy(b, a, N * sizeof(uint32_t));

	s = fm_sort(a, N);
	ok("sort produces sorted output", is_sorted(a, N));

	/* multiset is preserved: sort the reference with the C library and
	 * compare element by element */
	qsort(b, N, sizeof(uint32_t), cmp_u32);
	ok("sort is a permutation of the input",
	   memcmp(a, b, N * sizeof(uint32_t)) == 0);

	/* already-sorted input stays sorted and gives the same checksum */
	{
		uint64_t s2 = fm_sort(a, N);
		ok("sort is idempotent on sorted data",
		   is_sorted(a, N) && s2 == s);
	}

	ok("sort of empty array is zero", fm_sort(a, 0) == 0);
	free(a);
	free(b);
}

static void check_chase(void)
{
	/* build a tiny 4-node cycle by hand and confirm the walk returns to
	 * the start after exactly `n` steps (offset 0 relative to entry) */
	void *nodes[4];

	nodes[0] = &nodes[1];
	nodes[1] = &nodes[2];
	nodes[2] = &nodes[3];
	nodes[3] = &nodes[0];

	/* 4 hops from &nodes[0] returns to &nodes[0]; fm_chase returns the
	 * final pointer minus the starting pointer, so a full loop gives 0 */
	ok("chase completes a full cycle", fm_chase(nodes, 4) == 0);
	ok("chase(0) is zero",             fm_chase(nodes, 0) == 0);
	/* one hop lands on &nodes[1], i.e. one pointer-width past the start */
	ok("chase single hop offset",
	   fm_chase(nodes, 1) == (uint64_t)((char *)&nodes[1] - (char *)&nodes[0]));
}

int main(void)
{
	long n = sysconf(_SC_NPROCESSORS_ONLN);

	fm_ncores = n > 0 ? n : 1;

	printf("\nfossmark kernel correctness tests\n");
	printf("=================================\n");
	printf("running each check on %ld core%s in parallel\n\n",
	       fm_ncores, fm_ncores == 1 ? "" : "s");

	printf("Integer Math:\n");          parallel(check_int);
	printf("Floating Point Math:\n");    parallel(check_fp);
	printf("Prime Numbers:\n");          parallel(check_primes);
	printf("Extended Instructions:\n");  parallel(check_simd);
	printf("Compression:\n");            parallel(check_compress);
	printf("Encryption:\n");             parallel(check_crypto);
	printf("Physics:\n");                parallel(check_physics);
	printf("Sorting:\n");                parallel(check_sort);
	/* the pointer chase is the single-threaded test: run it on one core */
	printf("Single-Threaded (chase):\n"); check_chase();

	printf("\n=================================\n");
	printf("%d checks, %d failures\n\n", checks, failures);
	return failures ? 1 : 0;
}
