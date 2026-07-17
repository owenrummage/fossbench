/*
 * Portable kernel backend for 32-bit PowerPC.
 *
 * Keeping this backend in C lets the compiler implement 64-bit arguments and
 * returns according to the platform's PPC32 ABI.  All byte-oriented formats
 * are decoded explicitly, so the code is correct on big-endian systems.
 */
#include <math.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

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

uint64_t fm_simd(uint64_t iters, void *memory)
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
