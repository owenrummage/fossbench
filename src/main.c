/*
 * fossmark - a multi-core AArch64 CPU benchmark
 *
 * This file is the portable driver: it owns everything the assembly kernels
 * deliberately do not (timing, memory, I/O, scoring). The kernels in
 * fossmark.S are pure computation and identical on every OS; only this file
 * knows what an operating system is.
 *
 * Every workload is run twice: once on a single core, and once on all available
 * cores at once - one identical copy of the kernel per core, each with its own
 * private buffers, so the machine is driven to 100%% and the rate is whole-machine
 * throughput. From these two passes fossmark reports two composite scores, a
 * SINGLECORE and a MULTICORE, from the same tests and the same weights.
 *
 * Build: cc -O2 -pthread main.c fossmark.S -o fossmark -lm
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <pthread.h>
#include <unistd.h>

/* ---------- platform identification (for the banner only) ---------- */

#if defined(_WIN32)
#  define FM_OS "Windows"
#elif defined(__APPLE__)
#  define FM_OS "macOS"
#elif defined(__linux__)
#  define FM_OS "Linux"
#else
#  define FM_OS "POSIX"
#endif

#if defined(__aarch64__) || defined(_M_ARM64)
#  define FM_ARCH "ARM64"
#  define D_INT  "64-bit ALU: madd, umulh, udiv, bitops"
#  define D_FP   "double: fmadd, fdiv, fsqrt"
#  define D_SIMD "NEON ASIMD: 128-bit integer + float"
#elif defined(__x86_64__) || defined(_M_X64)
#  define FM_ARCH "x86-64"
#  define D_INT  "64-bit ALU: imul, mul, div, bitops"
#  define D_FP   "double: mulsd/addsd, divsd, sqrtsd"
#  define D_SIMD "SSE2: 128-bit integer + float"
#else
#  define FM_ARCH "unknown"
#  define D_INT  "64-bit integer ALU"
#  define D_FP   "double-precision FP"
#  define D_SIMD "128-bit SIMD: integer + float"
#endif

/* ---------- portable monotonic clock ---------- */

#if defined(_WIN32)
#  define WIN32_LEAN_AND_MEAN
#  include <windows.h>
static double now_seconds(void)
{
	LARGE_INTEGER f, t;
	QueryPerformanceFrequency(&f);
	QueryPerformanceCounter(&t);
	return (double)t.QuadPart / (double)f.QuadPart;
}
#else
#  include <time.h>
static double now_seconds(void)
{
	struct timespec ts;
	clock_gettime(CLOCK_MONOTONIC, &ts);
	return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}
#endif

/* ---------- the assembly kernels ---------- */

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

/* ---------- tuning ---------- */

#define PRIME_LIMIT	(2u * 1000u * 1000u)	/* sieve span              */
#define COMPRESS_LEN	(4u * 1024u * 1024u)	/* corpus size             */
#define HT_ENTRIES	(1u << 16)		/* LZ77 hash buckets       */
#define CIPHER_LEN	(1u * 1024u * 1024u)	/* plaintext size          */
#define SIMD_BUF	256			/* NEON scratch            */
#define NBODY_N		512			/* bodies                  */
#define SORT_N		(1u << 20)		/* elements to sort        */
#define CHASE_NODES	(1u << 21)		/* 16 MiB cycle, > any L2  */

#define MIN_SECONDS	2.0			/* per-test measured floor */
#define REPEATS		3			/* best-of, to reject noise */

/* ---------- scoring configuration ----------
 *
 * The overall score is a WEIGHTED geometric mean of each test's rate expressed
 * relative to a reference machine. Two knobs per test:
 *
 *   FM_REF_*     the reference rate (this machine's measured rate). A machine
 *                matching the reference scores FM_TARGET_SCORE on that test.
 *   FM_WEIGHT_*  how much that test counts toward the overall, by its
 *                influence on everyday user experience. Weights are relative:
 *                only their ratios matter, so they need not sum to anything -
 *                the code normalises by their sum. (They happen to sum to 100
 *                here, so each reads as a percent.)
 *
 * Per-test score:  S_i      = FM_TARGET_SCORE * (rate_i / FM_REF_i)
 * Overall score:   Overall  = FM_TARGET_SCORE *
 *                             exp( Sum(w_i * ln(rate_i/FM_REF_i)) / Sum(w_i) )
 *
 * On the reference machine every ratio is 1, so every S_i and the overall come
 * out to exactly FM_TARGET_SCORE, regardless of the weights. Scaling is linear
 * in performance, so far slower machines fall well below (half as fast -> half
 * the score) and faster future machines rise above.
 */

#define FM_TARGET_SCORE		10000.0		/* reference-machine overall */

/* Reference rates: this machine, in each test's native unit (see tests[]). */
#define FM_REF_INT		3086.0		/* Mops/s    */
#define FM_REF_FP		1682.0		/* Mops/s    */
#define FM_REF_PRIMES		812.0		/* Mcand/s   */
#define FM_REF_SIMD		6576.0		/* Mops/s    */
#define FM_REF_COMPRESS		674.0		/* MB/s      */
#define FM_REF_CRYPTO		406.0		/* MB/s      */
#define FM_REF_PHYSICS		631.0		/* Mpair/s   */
#define FM_REF_SORT		363.0		/* Mkey-cmp/s*/
#define FM_REF_CHASE		79.0		/* Mhop/s (scoring); shown as ns/access */

/* Weights: influence on day-to-day, common-workload user experience.
 * Rationale: integer/general-purpose code and memory-latency-bound
 * responsiveness dominate everyday use; specialised FP/physics matter least.
 * Roughly an 80/20 integer-vs-FP split, in the spirit of Geekbench 6's
 * weighted, integer-dominant methodology. Retune freely. */
#define FM_WEIGHT_INT		20.0		/* general-purpose ALU: everything   */
#define FM_WEIGHT_CHASE		16.0		/* memory latency: responsiveness    */
#define FM_WEIGHT_COMPRESS	14.0		/* web, storage, RAM compression     */
#define FM_WEIGHT_SORT		12.0		/* general data-structure work       */
#define FM_WEIGHT_SIMD		11.0		/* codecs, mem/string ops, parsing   */
#define FM_WEIGHT_FP		9.0		/* spreadsheets, app/media math      */
#define FM_WEIGHT_CRYPTO	8.0		/* TLS, disk encryption (small frac) */
#define FM_WEIGHT_PRIMES	6.0		/* synthetic ALU+memory proxy        */
#define FM_WEIGHT_PHYSICS	4.0		/* niche simulation/games            */

/* ---------- deterministic PRNG (splitmix64) ---------- */

static uint64_t rng_state = 0x853c49e6748fea9bULL;

static uint64_t rng_next(void)
{
	uint64_t z = (rng_state += 0x9e3779b97f4a7c15ULL);
	z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ULL;
	z = (z ^ (z >> 27)) * 0x94d049bb133111ebULL;
	return z ^ (z >> 31);
}

static void rng_reset(void) { rng_state = 0x853c49e6748fea9bULL; }

/* ---------- aligned allocation ---------- */

static void *xalloc(size_t n)
{
	void *p = NULL;
#if defined(_WIN32)
	p = _aligned_malloc(n, 64);
#else
	if (posix_memalign(&p, 64, n) != 0)
		p = NULL;
#endif
	if (!p) {
		fprintf(stderr, "fossmark: out of memory (%zu bytes)\n", n);
		exit(1);
	}
	return p;
}

static void xfree(void *p)
{
#if defined(_WIN32)
	_aligned_free(p);
#else
	free(p);
#endif
}

/* ---------- workload state ----------
 *
 * Because every core runs the same kernel simultaneously, each core needs its
 * OWN mutable buffers - sharing them would be a data race and would corrupt
 * both the results and the determinism check. Per-core scratch lives in a
 * `workspace`, one per thread. Read-only inputs (the corpus, the pristine
 * physics/sort seeds, the key, the chase graph) are genuinely shared.
 */
struct workspace {
	uint8_t  *sieve;	/* prime sieve scratch                 */
	uint32_t *ht;		/* LZ77 hash table scratch             */
	uint8_t  *cipher_buf;	/* ChaCha20 buffer, encrypted in place */
	uint8_t  *simd_buf;	/* NEON scratch                        */
	double   *bodies;	/* n-body integration buffer           */
	uint32_t *sort_work;	/* the buffer we actually sort         */
	void    **chase;	/* private 16 MiB pointer-chase cycle  */
};

static long              g_ncores  = 1;	/* active online cores               */
static struct workspace *g_ws;		/* g_ncores per-thread workspaces    */

static uint8_t  *g_corpus;	/* shared, read-only compression input   */
static uint8_t   g_key[32];	/* shared, read-only cipher key          */
static uint8_t  *g_cipher_src;	/* pristine plaintext, copied per-core   */
static uint8_t  *g_simd_src;	/* pristine NEON seed, copied per-core   */
static double   *g_bodies_src;	/* pristine initial conditions           */
static uint32_t *g_sort_src;	/* pristine unsorted data                */

/*
 * Synthesise a compressible corpus. Random bytes would be incompressible and
 * would make the match-finder trivially miss every probe, measuring nothing
 * interesting. This builds text-like data with realistic repetition instead.
 */
static void build_corpus(uint8_t *buf, size_t len)
{
	static const char *words[] = {
		"the", "quick", "brown", "fox", "jumps", "over", "lazy",
		"dog", "benchmark", "processor", "assembly", "vector",
		"memory", "cache", "pipeline", "instruction", "compress",
		"data", "system", "performance", "register", "kernel"
	};
	const size_t nwords = sizeof(words) / sizeof(words[0]);
	size_t pos = 0;

	while (pos < len) {
		const char *w = words[rng_next() % nwords];
		size_t wl = strlen(w);

		if (pos + wl + 1 > len)
			break;
		memcpy(buf + pos, w, wl);
		pos += wl;
		buf[pos++] = (rng_next() % 8 == 0) ? '\n' : ' ';
	}
	while (pos < len)
		buf[pos++] = ' ';
}

/* Build a single random cycle through the node array (Sattolo's algorithm),
 * guaranteeing one cycle of exactly CHASE_NODES steps with no early closure. */
static void build_chase(void **nodes, size_t n)
{
	size_t *perm = xalloc(n * sizeof(size_t));
	size_t i;

	for (i = 0; i < n; i++)
		perm[i] = i;
	for (i = n - 1; i > 0; i--) {
		size_t j = (size_t)(rng_next() % i);	/* strictly j < i */
		size_t t = perm[i];
		perm[i] = perm[j];
		perm[j] = t;
	}
	for (i = 0; i < n; i++)
		nodes[perm[i]] = (void *)&nodes[perm[(i + 1) % n]];

	xfree(perm);
}

static void setup(void)
{
	size_t i;
	long   t;

	rng_reset();

	/* shared read-only inputs and pristine per-core seeds */
	g_corpus     = xalloc(COMPRESS_LEN);
	g_cipher_src = xalloc(CIPHER_LEN);
	g_simd_src   = xalloc(SIMD_BUF);
	g_bodies_src = xalloc(NBODY_N * 8 * sizeof(double));
	g_sort_src   = xalloc(SORT_N * sizeof(uint32_t));

	build_corpus(g_corpus, COMPRESS_LEN);

	for (i = 0; i < CIPHER_LEN; i++)
		g_cipher_src[i] = (uint8_t)rng_next();
	for (i = 0; i < 32; i++)
		g_key[i] = (uint8_t)rng_next();
	for (i = 0; i < SIMD_BUF; i++)
		g_simd_src[i] = (uint8_t)rng_next();
	for (i = 0; i < SORT_N; i++)
		g_sort_src[i] = (uint32_t)rng_next();

	/* bodies: [x y z mass vx vy vz pad], positions in a unit-ish cube */
	for (i = 0; i < NBODY_N; i++) {
		double *b = &g_bodies_src[i * 8];
		b[0] = (double)(rng_next() % 2000) / 1000.0 - 1.0;
		b[1] = (double)(rng_next() % 2000) / 1000.0 - 1.0;
		b[2] = (double)(rng_next() % 2000) / 1000.0 - 1.0;
		b[3] = (double)(rng_next() % 900) / 1000.0 + 0.1;  /* mass > 0 */
		b[4] = b[5] = b[6] = 0.0;
		b[7] = 0.0;
	}

	/* one private workspace per core, every copy seeded identically so all
	 * cores compute the same deterministic result. Each core also gets its
	 * own pointer-chase cycle: sharing one would collapse the multi-core
	 * latency test into a shared-cache test instead of a memory test. */
	g_ws = xalloc((size_t)g_ncores * sizeof *g_ws);
	for (t = 0; t < g_ncores; t++) {
		struct workspace *w = &g_ws[t];

		w->sieve      = xalloc(PRIME_LIMIT);
		w->ht         = xalloc(HT_ENTRIES * sizeof(uint32_t));
		w->cipher_buf = xalloc(CIPHER_LEN);
		w->simd_buf   = xalloc(SIMD_BUF);
		w->bodies     = xalloc(NBODY_N * 8 * sizeof(double));
		w->sort_work  = xalloc(SORT_N * sizeof(uint32_t));
		w->chase      = xalloc(CHASE_NODES * sizeof(void *));

		memcpy(w->cipher_buf, g_cipher_src, CIPHER_LEN);
		memcpy(w->simd_buf,   g_simd_src,   SIMD_BUF);
		build_chase(w->chase, CHASE_NODES);
	}
}

static void teardown(void)
{
	long t;

	for (t = 0; t < g_ncores; t++) {
		struct workspace *w = &g_ws[t];

		xfree(w->sieve);      xfree(w->ht);        xfree(w->cipher_buf);
		xfree(w->simd_buf);   xfree(w->bodies);    xfree(w->sort_work);
		xfree(w->chase);
	}
	xfree(g_ws);

	xfree(g_corpus);     xfree(g_cipher_src); xfree(g_simd_src);
	xfree(g_bodies_src); xfree(g_sort_src);
}

/* ---------- the test harness ---------- */

/*
 * Each test runs a kernel `n` times against a per-core workspace and returns a
 * checksum. The harness auto-calibrates `n` upward until the run exceeds
 * MIN_SECONDS, so the result is insensitive to clock granularity and to how
 * fast the machine is.
 */
typedef uint64_t (*run_fn)(uint64_t n, struct workspace *ws);

struct test {
	const char *name;
	const char *detail;
	run_fn      run;
	uint64_t    start_n;
	double      work_per_n;	/* abstract work units, for scoring */
	const char *unit;
	double      ref_rate;	/* reference-machine rate, in `unit`     */
	double      weight;	/* relative weight in the overall score  */
};

static uint64_t run_int(uint64_t n, struct workspace *ws)
{
	(void)ws;
	return fm_int_math(n * 100000);
}
static uint64_t run_fp(uint64_t n, struct workspace *ws)
{
	(void)ws;
	return fm_fp_math(n * 100000);
}
static uint64_t run_primes(uint64_t n, struct workspace *ws)
{
	uint64_t c = 0;
	for (uint64_t i = 0; i < n; i++)
		c += fm_primes(PRIME_LIMIT, ws->sieve);
	return c;
}
static uint64_t run_simd(uint64_t n, struct workspace *ws)
{
	return fm_simd(n * 100000, ws->simd_buf);
}
static uint64_t run_compress(uint64_t n, struct workspace *ws)
{
	uint64_t c = 0;
	for (uint64_t i = 0; i < n; i++)
		c += fm_compress(g_corpus, COMPRESS_LEN, ws->ht);
	return c;
}
static uint64_t run_crypto(uint64_t n, struct workspace *ws)
{
	return fm_chacha20(ws->cipher_buf, CIPHER_LEN, g_key, n);
}
static uint64_t run_physics(uint64_t n, struct workspace *ws)
{
	/* restore initial conditions: the integrator mutates the bodies, so
	 * a re-run must start from the same state to be reproducible */
	memcpy(ws->bodies, g_bodies_src, NBODY_N * 8 * sizeof(double));
	return fm_physics(ws->bodies, NBODY_N, n);
}
static uint64_t run_sort(uint64_t n, struct workspace *ws)
{
	uint64_t c = 0;
	for (uint64_t i = 0; i < n; i++) {
		/* restore the pristine data: sorting an already-sorted array
		 * would measure the best case, not the real one */
		memcpy(ws->sort_work, g_sort_src, SORT_N * sizeof(uint32_t));
		c ^= fm_sort(ws->sort_work, SORT_N);
	}
	return c;
}
static uint64_t run_chase(uint64_t n, struct workspace *ws)
{
	return fm_chase(ws->chase, n * 1000000);
}

static const struct test tests[] = {
	{ "Integer Math",         D_INT,
	  run_int,      20, 100000.0 * 24,  "Mops/s",
	  FM_REF_INT,      FM_WEIGHT_INT },
	{ "Floating Point Math",  D_FP,
	  run_fp,       20, 100000.0 * 20,  "Mops/s",
	  FM_REF_FP,       FM_WEIGHT_FP },
	{ "Prime Numbers",        "sieve of Eratosthenes to 2M",
	  run_primes,    1, (double)PRIME_LIMIT, "Mcand/s",
	  FM_REF_PRIMES,   FM_WEIGHT_PRIMES },
	{ "Extended Instructions",D_SIMD,
	  run_simd,     10, 100000.0 * 32,  "Mops/s",
	  FM_REF_SIMD,     FM_WEIGHT_SIMD },
	{ "Compression",          "LZ77 match finder, 4 MiB corpus",
	  run_compress,  1, (double)COMPRESS_LEN, "MB/s",
	  FM_REF_COMPRESS, FM_WEIGHT_COMPRESS },
	{ "Encryption",           "ChaCha20, 20 rounds, 1 MiB",
	  run_crypto,    4, (double)CIPHER_LEN, "MB/s",
	  FM_REF_CRYPTO,   FM_WEIGHT_CRYPTO },
	{ "Physics",              "512-body direct-sum gravity",
	  run_physics,   4, (double)NBODY_N * NBODY_N, "Mpair/s",
	  FM_REF_PHYSICS,  FM_WEIGHT_PHYSICS },
	{ "Sorting",              "heapsort, 1M uint32",
	  run_sort,      1, (double)SORT_N * 20,  "Mkey-cmp/s",
	  FM_REF_SORT,     FM_WEIGHT_SORT },
	{ "Memory Latency",       "dependent-load pointer chase, 16 MiB",
	  run_chase,     1, 1000000.0,      "ns/access",
	  FM_REF_CHASE,    FM_WEIGHT_CHASE },
};

#define NTESTS (sizeof(tests) / sizeof(tests[0]))

struct result {
	double   rate;		/* work units per second */
	double   score;
	uint64_t checksum;
	double   seconds;
	uint64_t iters;
	int      threads;	/* cores this test was spread across */
};

/*
 * One unit of parallel work: run `run(n, ws)` on a private workspace. Every
 * core executes the identical kernel on identically-seeded data, so all cores
 * return the same checksum; the harness sums them into one aggregate that stays
 * deterministic across repeats.
 */
struct job {
	run_fn            run;
	uint64_t          n;
	struct workspace *ws;
	uint64_t          result;
};

static void *job_entry(void *arg)
{
	struct job *j = arg;
	j->result = j->run(j->n, j->ws);
	return NULL;
}

/*
 * Run the kernel on `threads` cores at once and return the summed checksum.
 * The calling thread runs job 0 itself; threads 1..N-1 run on spawned workers.
 * A thread that fails to spawn simply runs inline, so the benchmark still
 * completes (with less parallelism) rather than aborting.
 */
static uint64_t dispatch(run_fn run, uint64_t n, int threads)
{
	struct job *jobs = xalloc((size_t)threads * sizeof *jobs);
	pthread_t  *tids = threads > 1
			 ? xalloc((size_t)(threads - 1) * sizeof *tids) : NULL;
	int i, spawned = 0;
	uint64_t agg = 0;

	for (i = 0; i < threads; i++) {
		jobs[i].run = run;
		jobs[i].n   = n;
		jobs[i].ws  = &g_ws[i];
	}
	for (i = 1; i < threads; i++) {
		if (pthread_create(&tids[spawned], NULL, job_entry, &jobs[i]) == 0)
			spawned++;
		else
			job_entry(&jobs[i]);	/* fall back to inline */
	}

	job_entry(&jobs[0]);			/* this thread runs job 0 */

	for (i = 0; i < spawned; i++)
		pthread_join(tids[i], NULL);
	for (i = 0; i < threads; i++)
		agg += jobs[i].result;

	xfree(jobs);
	xfree(tids);
	return agg;
}

static struct result run_test(const struct test *t, int threads)
{
	struct result r;
	uint64_t n = t->start_n;
	double elapsed = 0.0, best = 0.0;
	uint64_t checksum = 0;
	int i;

	/* calibrate: grow n until a single run clears the noise floor */
	for (;;) {
		double t0 = now_seconds();
		checksum = dispatch(t->run, n, threads);
		elapsed = now_seconds() - t0;

		if (elapsed >= MIN_SECONDS)
			break;
		if (elapsed < 0.001) {
			n *= 8;			/* far too fast to measure */
		} else {
			double scale = (MIN_SECONDS * 1.3) / elapsed;
			if (scale < 1.5)
				scale = 1.5;
			if (scale > 8.0)
				scale = 8.0;
			n = (uint64_t)((double)n * scale) + 1;
		}
	}

	/* best-of: the fastest run is the one least disturbed by the OS */
	best = elapsed;
	for (i = 1; i < REPEATS; i++) {
		double t0 = now_seconds();
		uint64_t c = dispatch(t->run, n, threads);
		double e = now_seconds() - t0;

		if (c != checksum) {
			fprintf(stderr,
				"fossmark: %s is non-deterministic "
				"(checksum %llu != %llu)\n", t->name,
				(unsigned long long)c,
				(unsigned long long)checksum);
			exit(2);
		}
		if (e < best)
			best = e;
	}

	r.seconds  = best;
	r.iters    = n;
	r.checksum = checksum;
	r.threads  = threads;
	/* aggregate throughput: `threads` cores each did n*work_per_n of work in
	 * the same wall-clock window, so the machine's rate is their sum */
	r.rate     = ((double)threads * (double)n * t->work_per_n) / best / 1e6;
	/* normalise against the reference machine: this is the per-test score */
	r.score    = FM_TARGET_SCORE * (r.rate / t->ref_rate);
	return r;
}

/*
 * The number shown in the RATE column. Most tests report throughput in their
 * `unit`. The memory-latency test is different: throughput (hops/s) is not what
 * anyone reasons about for memory, so we report the actual per-access latency
 * in nanoseconds instead. That is a per-core property -- the time for one
 * dependent load in the chain -- so it is derived from a single core's hop
 * count and is independent of how many cores ran, unlike the aggregate `rate`.
 */
static double display_metric(const struct test *t, const struct result *r)
{
	if (t->run == run_chase) {
		double hops = (double)r->iters * t->work_per_n;	/* per core */
		return r->seconds / hops * 1e9;			/* ns/access */
	}
	return r->rate;
}

/* ---------- output ---------- */

static void print_header(void)
{
	printf("\n");
	printf("  fossmark 1.0 - multi-core CPU benchmark\n");
	printf("  ------------------------------------------------------------------\n");
	printf("  platform: %s/%s\n", FM_OS, FM_ARCH);
	printf("  cores:    %ld (each test is run once on 1 core, once on all %ld)\n",
	       g_ncores, g_ncores);
	printf("\n");
	printf("  RATE/TIME/SCORE below are the all-core (multi-core) pass.\n");
	printf("\n");
	printf("  %-24s %12s  %-11s %8s %9s\n",
	       "TEST", "RATE", "UNIT", "TIME", "SCORE");
	printf("  --------------------------------------------------------------------------\n");
	fflush(stdout);
}

int main(int argc, char **argv)
{
	struct result multi[NTESTS], single[NTESTS];
	double multi_log_sum = 0.0, single_log_sum = 0.0;
	double weight_sum = 0.0;
	int verbose = 0;
	size_t i;

	for (i = 1; i < (size_t)argc; i++) {
		if (strcmp(argv[i], "-v") == 0 ||
		    strcmp(argv[i], "--verbose") == 0) {
			verbose = 1;
		} else if (strcmp(argv[i], "-h") == 0 ||
			   strcmp(argv[i], "--help") == 0) {
			printf("usage: %s [-v|--verbose]\n", argv[0]);
			return 0;
		} else {
			fprintf(stderr, "fossmark: unknown option '%s'\n",
				argv[i]);
			return 1;
		}
	}

	{
		long n = sysconf(_SC_NPROCESSORS_ONLN);
		g_ncores = n > 0 ? n : 1;
	}

	printf("\n  preparing workloads...");
	fflush(stdout);
	setup();
	printf(" done\n");

	print_header();

	for (i = 0; i < NTESTS; i++) {
		double sm, ss;

		printf("  %-24s", tests[i].name);
		fflush(stdout);

		/* each test runs twice: the all-core pass (shown) and the
		 * single-core pass (folded into the SINGLECORE score) */
		multi[i]  = run_test(&tests[i], (int)g_ncores);
		single[i] = run_test(&tests[i], 1);

		printf(" %12.1f  %-11s %7.2fs %9.0f\n",
		       display_metric(&tests[i], &multi[i]), tests[i].unit,
		       multi[i].seconds, multi[i].score);
		if (verbose)
			printf("  %-24s   %s\n"
			       "  %-24s   weight=%.0f%%  1-core: %.1f %s / %.0f   %ld-core: %.1f %s / %.0f\n",
			       "", tests[i].detail, "", tests[i].weight,
			       display_metric(&tests[i], &single[i]), tests[i].unit,
			       single[i].score, g_ncores,
			       display_metric(&tests[i], &multi[i]), tests[i].unit,
			       multi[i].score);
		fflush(stdout);

		/* accumulate the weighted geometric mean of BOTH passes, same
		 * weights, so the two composite scores are directly comparable */
		sm = multi[i].score  > 0.0 ? multi[i].score  : 1e-9;
		ss = single[i].score > 0.0 ? single[i].score : 1e-9;
		multi_log_sum  += tests[i].weight * log(sm);
		single_log_sum += tests[i].weight * log(ss);
		weight_sum     += tests[i].weight;
	}

	printf("  --------------------------------------------------------------------------\n");

	/*
	 * Two composite scores, each the WEIGHTED geometric mean of the per-test
	 * scores from one pass. Per-test scores are already normalised so the
	 * single-thread reference machine reads FM_TARGET_SCORE. Geometric rather
	 * than arithmetic so no single test dominates; weighted so tests count in
	 * proportion to their influence on everyday use (the FM_WEIGHT_* config).
	 * The two passes share tests and weights, so MULTICORE / SINGLECORE is a
	 * clean read of how much the machine gains from all its cores.
	 */
	printf("  %-24s %44.0f\n", "MULTICORE SCORE",
	       exp(multi_log_sum / weight_sum));
	printf("  %-24s %44.0f\n", "SINGLECORE SCORE",
	       exp(single_log_sum / weight_sum));
	printf("  %-24s (weighted geometric means, reference machine = %.0f)\n",
	       "", FM_TARGET_SCORE);
	printf("\n");

	teardown();
	return 0;
}
