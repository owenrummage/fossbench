/*
 * Portable kernel backend for big-endian PowerPC.
 *
 * Keeping this backend in C lets the compiler implement 64-bit arguments and
 * returns according to the platform ABI.  All byte-oriented formats
 * are decoded explicitly, so the code is correct on big-endian systems.
 */
#include <math.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#if defined(__linux__)
#include <sys/auxv.h>
#endif

static uint32_t rotl32(uint32_t x, unsigned n)
{
	return (x << n) | (x >> (32 - n));
}

uint64_t fm_int_math(uint64_t iters)
{
	uint64_t a = 0x9e3779b97f4a7c15ULL, b = 0xbf58476d1ce4e5b9ULL;
	uint64_t c = 0x94d049bb133111ebULL, d = 0x2545f4914f6cdd1dULL;
	uint64_t i;
	if (!iters) return 0;
	for (i = 0; i < iters; i++) {
		a = a * 0xdeadbeefU + b; b = b * 0xdeadbeefU + c;
		c = c * 0xdeadbeefU + d; d = d * 0xdeadbeefU + a;
		a ^= c >> 29; b ^= d << 17; c ^= (a >> 31) | (a << 33);
		d ^= b >> 7; a += c / 0xdeadbeefU; b += d / 0xdeadbeefU;
	}
	return a ^ b ^ c ^ d;
}

uint64_t fm_fp_math(uint64_t iters)
{
	double a = 1.5, b = 2.5, c = 3.5, d = .5, out;
	uint64_t bits, i;
	if (!iters) return 0;
	for (i = 0; i < iters; i++) {
		a = fmin(a * 1.0625 + .0009765625, 2.0);
		b = fmin(b * 1.0625 + .0009765625, 2.0);
		c = fmin(c * 1.0625 + .0009765625, 2.0) + sqrt(a);
		d = fmax(fabs(fmin(d * 1.0625 + .0009765625, 2.0) + sqrt(b)), 1.0);
		a += 1.0 / (c + 1.0); b += 1.0 / (d + 1.0);
	}
	out = a + b + c + d;
	memcpy(&bits, &out, sizeof bits);
	return bits;
}

uint64_t fm_primes(uint64_t limit, uint8_t *sieve)
{
	uint64_t i, j, count = 0;
	if (limit < 2) return 0;
	memset(sieve, 0, (size_t)limit);
	sieve[0] = sieve[1] = 1;
	for (i = 2; i <= (limit - 1) / i; i++)
		if (!sieve[i]) for (j = i * i; j < limit; j += i) sieve[j] = 1;
	for (i = 2; i < limit; i++) count += !sieve[i];
	return count;
}

#if !defined(__powerpc64__)
static uint64_t fm_simd_scalar(uint64_t iters, void *memory)
{
	uint32_t *v = (uint32_t *)memory;
	uint32_t a[8]; uint64_t i; unsigned j; uint32_t sum = 0;
	if (!iters) return 0;
	memcpy(a, v, sizeof a);
	for (i = 0; i < iters; i++)
		for (j = 0; j < 8; j++) a[j] = rotl32(a[j] + a[(j + 1) & 7] * (j + 3), (j + 5) & 31);
	for (j = 0; j < 8; j++) sum ^= a[j];
	memcpy(v, a, sizeof a);
	return sum;
}
#endif

#if defined(__powerpc64__)
/* The PowerPC 970 in every iMac G5 implements AltiVec.  Using GCC's vector
 * type here lets the compiler handle whichever PPC64 ELF ABI the system uses;
 * both PPC64 ABIs differ from the PPC32 assembly convention below. */
typedef uint32_t fm_vec_u32 __attribute__((vector_size(16)));

uint64_t fm_simd(uint64_t iters, void *memory)
{
	fm_vec_u32 a, b;
	uint32_t *v = (uint32_t *)memory;
	uint32_t sum = 0;
	uint64_t i;
	unsigned j;

	if (!iters)
		return 0;
	memcpy(&a, v, sizeof a);
	memcpy(&b, v + 4, sizeof b);
	for (i = 0; i < iters; i++) {
		a = a + b;
		b = b ^ a;
		a = a + b;
		b = b ^ a;
	}
	memcpy(v, &a, sizeof a);
	memcpy(v + 4, &b, sizeof b);
	for (j = 0; j < 8; j++)
		sum ^= v[j];
	return sum;
}
#else
/* These are kept in fossmark_ppc32_ext.S so this translation unit, and thus
 * the executable's default code path, only requires baseline PPC32. */
extern void fm_simd_ps_kernel(uint64_t iters, void *memory);
extern void fm_simd_vsx_kernel(uint64_t iters, void *memory);
extern void fm_simd_altivec_kernel(uint64_t iters, void *memory);

typedef void (*fm_simd_kernel)(uint64_t, void *);

static int device_is_nintendo(void)
{
#if defined(__linux__)
	static const char prefix[] = "nintendo,";
	static const char *const paths[] = {
		"/proc/device-tree/compatible",
		"/sys/firmware/devicetree/base/compatible"
	};
	char compatible[sizeof prefix - 1];
	unsigned i;

	for (i = 0; i < sizeof paths / sizeof paths[0]; i++) {
		FILE *fp = fopen(paths[i], "rb");
		int match;
		if (fp == NULL)
			continue;
		match = fread(compatible, 1, sizeof compatible, fp) == sizeof compatible &&
			memcmp(compatible, prefix, sizeof compatible) == 0;
		fclose(fp);
		return match;
	}
	return 0;
#else
	return 0;
#endif
}

static fm_simd_kernel detect_simd_kernel(void)
{
	/* Linux exposes these in AT_HWCAP on both 32- and 64-bit PowerPC.
	 * Spell out the ABI values instead of depending on kernel-only headers. */
#if defined(__linux__) && defined(AT_HWCAP)
	const unsigned long hwcap = getauxval(AT_HWCAP);
	const unsigned long has_altivec = 0x10000000UL;
	const unsigned long has_vsx = 0x00000080UL;

	if (device_is_nintendo())
		return fm_simd_ps_kernel;
	if (hwcap & has_vsx)
		return fm_simd_vsx_kernel;
	if (hwcap & has_altivec)
		return fm_simd_altivec_kernel;
#else
	if (device_is_nintendo())
		return fm_simd_ps_kernel;
#endif
	return NULL;
}

uint64_t fm_simd(uint64_t iters, void *memory)
{
	static fm_simd_kernel kernel;
	static int detected;
	fm_simd_kernel selected;
	uint32_t *v = (uint32_t *)memory;
	uint32_t sum = 0;
	unsigned j;

	if (!iters)
		return 0;
	if (!__atomic_load_n(&detected, __ATOMIC_ACQUIRE)) {
		fm_simd_kernel found = detect_simd_kernel();
		__atomic_store_n(&kernel, found, __ATOMIC_RELAXED);
		__atomic_store_n(&detected, 1, __ATOMIC_RELEASE);
	}
	selected = __atomic_load_n(&kernel, __ATOMIC_RELAXED);
	if (selected == NULL)
		return fm_simd_scalar(iters, memory);

	selected(iters, memory);
	for (j = 0; j < 8; j++)
		sum ^= v[j];
	return sum;
}
#endif

static uint32_t load32_native(const uint8_t *p)
{
	uint32_t v; memcpy(&v, p, sizeof v); return v;
}

uint64_t fm_compress(const uint8_t *src, uint64_t len, uint32_t *ht)
{
	uint64_t ip = 0, anchor = 0, out = 0, ref, ml, lit;
	memset(ht, 0, (size_t)(1U << 16) * sizeof *ht);
	if (len < 16) return len + 1;
	while (ip < len - 12) {
		uint32_t seq = load32_native(src + ip);
		uint32_t h = (uint32_t)(seq * 2654435761U) >> 16;
		ref = ht[h]; ht[h] = (uint32_t)ip;
		if (ref >= ip || ip - ref >= 65536 || load32_native(src + ref) != seq) { ip++; continue; }
		for (ml = 4; ip + ml < len && src[ip + ml] == src[ref + ml]; ml++) {}
		lit = ip - anchor; out += lit + 3 + (lit >= 15) + (ml >= 19);
		ip += ml; anchor = ip;
	}
	return out + (len - anchor) + 1;
}

static uint32_t load32le(const uint8_t *p)
{
	return (uint32_t)p[0] | (uint32_t)p[1] << 8 | (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24;
}
static void store32le(uint8_t *p, uint32_t v)
{
	p[0] = (uint8_t)v; p[1] = (uint8_t)(v >> 8); p[2] = (uint8_t)(v >> 16); p[3] = (uint8_t)(v >> 24);
}
#define QR(a,b,c,d) do { a+=b; d=rotl32(d^a,16); c+=d; b=rotl32(b^c,12); a+=b; d=rotl32(d^a,8); c+=d; b=rotl32(b^c,7); } while (0)
uint64_t fm_chacha20(uint8_t *buf, uint64_t len, const uint8_t key[32], uint64_t passes)
{
	static const uint32_t sigma[4] = {0x61707865,0x3320646e,0x79622d32,0x6b206574};
	uint32_t base[16], x[16], counter = 0, checksum = 0; uint64_t pass, off; int i, r;
	len &= ~(uint64_t)63; if (!len || !passes) return 0;
	memcpy(base, sigma, 16); for (i=0;i<8;i++) base[4+i]=load32le(key+4*i);
	base[13]=base[14]=base[15]=0;
	for (pass=0;pass<passes;pass++) for (off=0;off<len;off+=64) {
		base[12]=counter++; memcpy(x,base,sizeof x);
		for(r=0;r<10;r++) { QR(x[0],x[4],x[8],x[12]); QR(x[1],x[5],x[9],x[13]); QR(x[2],x[6],x[10],x[14]); QR(x[3],x[7],x[11],x[15]); QR(x[0],x[5],x[10],x[15]); QR(x[1],x[6],x[11],x[12]); QR(x[2],x[7],x[8],x[13]); QR(x[3],x[4],x[9],x[14]); }
		for(i=0;i<16;i++) { uint32_t k=x[i]+base[i]; uint8_t t[4]; store32le(t,k); buf[off+4*i]^=t[0]; buf[off+4*i+1]^=t[1]; buf[off+4*i+2]^=t[2]; buf[off+4*i+3]^=t[3]; checksum^=k; }
	}
	return checksum;
}
#undef QR

uint64_t fm_physics(double *b, uint64_t n, uint64_t steps)
{
	uint64_t s,i,j,bits; double sum=0;
	if (!n || !steps) return 0;
	for(s=0;s<steps;s++) { for(i=0;i<n;i++) { double ax=0,ay=0,az=0; for(j=0;j<n;j++) { double dx=b[8*j]-b[8*i],dy=b[8*j+1]-b[8*i+1],dz=b[8*j+2]-b[8*i+2]; double q=1.0/sqrt(dx*dx+dy*dy+dz*dz+.0625); q=q*q*q*b[8*j+3]; ax+=dx*q; ay+=dy*q; az+=dz*q; } b[8*i+4]+=ax*.0078125; b[8*i+5]+=ay*.0078125; b[8*i+6]+=az*.0078125; } for(i=0;i<n;i++) { b[8*i]+=b[8*i+4]*.0078125; b[8*i+1]+=b[8*i+5]*.0078125; b[8*i+2]+=b[8*i+6]*.0078125; } }
	for (i = 0; i < n; i++)
		sum += b[8*i+4] + b[8*i+5] + b[8*i+6];
	memcpy(&bits, &sum, sizeof bits);
	return bits;
}

static void sift(uint32_t *a, uint64_t root, uint64_t end) { for (;;) { uint64_t c=root*2+1; uint32_t t; if(c>=end)return; if(c+1<end&&a[c+1]>a[c])c++; if(a[root]>=a[c])return; t=a[root];a[root]=a[c];a[c]=t;root=c; } }
uint64_t fm_sort(uint32_t *a, uint64_t n)
{
	uint64_t i,end,sum=0; uint32_t t; if(n<2)return n?a[0]:0;
	for (i = n / 2; i; i--)
		sift(a, i - 1, n);
	for (end = n - 1; end; end--) {
		t = a[0]; a[0] = a[end]; a[end] = t;
		sift(a, 0, end);
	}
	for(i=0;i<n;i++){sum=(sum>>7)|(sum<<57);sum^=a[i];sum+=a[i];} return sum;
}

uint64_t fm_chase(void **ptrs, uint64_t steps)
{
	void **p=ptrs; uint64_t i; if(!steps)return 0; for(i=0;i<steps;i++)p=(void **)*p; return (uint64_t)((uintptr_t)p-(uintptr_t)ptrs);
}
