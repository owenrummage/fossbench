/*
 * fossbench_i386.S - x86 32-bit (i386) CPU benchmark kernels
 *
 * The i386 counterpart to fossbench_x86_64.S. Same nine routines, same
 * contract: each is a pure function of its arguments, contains no syscalls,
 * no libc calls and no external data relocations, so it assembles and runs
 * unmodified under the plain i386 SysV (cdecl) ABI on Linux.
 *
 * i386 has only six general-purpose registers to work with (eax, ebx, ecx,
 * edx, esi, edi - ebp and esp are reserved for the frame/stack) and no
 * 64-bit integer registers or instructions at all, so every 64-bit value here
 * is carried as an explicit hi:lo register or memory pair, and arithmetic on
 * it is built from the matching 32-bit op plus a carry (add/adc, sub/sbb,
 * shrd/shld for cross-word shifts). Register pressure is the binding
 * constraint - with four independent 64-bit accumulators in flight there
 * usually isn't a register left over, so several kernels keep their working
 * state on the stack frame instead of in registers, unlike the amd64/arm64
 * files. That's a real, honest cost of 32-bit x86, not an oversight: it's
 * the same constraint any hand-written i386 code pays.
 *
 * Extended instructions are SSE2 only (mandatory baseline: Pentium 4). As in
 * the amd64 file, no FMA/SSE3+ is used, and every fused multiply-add is a
 * separate multiply and add.
 *
 * Register conventions (i386 SysV cdecl):
 *   integer args   pushed on the stack, right to left, caller cleans up
 *   64-bit args    two stack dwords, low dword at the lower address
 *   64-bit return  edx:eax (edx = high, eax = low)
 *   callee-saved   ebx, esi, edi, ebp
 *   all of xmm0-7 are caller-saved, so no vector register need be preserved.
 */

	.intel_syntax noprefix

#if defined(__APPLE__) || defined(_WIN32)
#  define SYM(name) _##name
#else
#  define SYM(name) name
#endif

#define FN_BEGIN(name) FN_BEGIN_ASM SYM(name)
#define FN_END(name)   FN_END_ASM SYM(name)

	.macro	FN_BEGIN_ASM name
	.p2align 4
	.globl	\name
#if defined(__ELF__)
	.type	\name, @function
#endif
\name:
	.endm

	.macro	FN_END_ASM name
#if defined(__ELF__)
	.size	\name, . - \name
#endif
	.endm

	.text


/* ===================================================================
 * uint64_t fb_int_math(uint64_t iters)   [ [esp+4]:[esp+8] = iters ]
 *
 * Four independent multiply-accumulate chains (a,b,c,d), each carried as a
 * hi:lo stack-frame pair since there's no register space left to hold four
 * 64-bit values at once. Cross-mixed with 64-bit shifts/rotate built from
 * shrd/shld, a genuine 64x64->128 unsigned widening multiply (schoolbook,
 * four 32x32->64 partial products) for the long-latency multiplier path, and
 * hardware division: the divisor (0xdeadbeef) fits in 32 bits, so instead of
 * a 64-by-64 divide (which i386 doesn't have, and which libgcc would emulate
 * with a slow generic software routine), this splits the dividend into
 * hi/lo and does two native 32-bit `div`s - the same trick used to fix the
 * C fallback's __udivdi3 calls, now built directly into the kernel.
 * =================================================================== */
FN_BEGIN(fb_int_math)
	push	ebp
	mov	ebp, esp
	push	ebx
	sub	esp, 48

	/* frame: a_lo=[ebp-8] a_hi=[ebp-12] b_lo=[ebp-16] b_hi=[ebp-20]
	 *        c_lo=[ebp-24] c_hi=[ebp-28] d_lo=[ebp-32] d_hi=[ebp-36]
	 *        t0=[ebp-40] t1=[ebp-44] t2=[ebp-48] t3=[ebp-52]
	 * args:  iters_lo=[ebp+8] iters_hi=[ebp+12] (decremented in place) */

	mov	eax, [ebp+8]
	or	eax, [ebp+12]
	jz	.Lim_zero

	mov	dword ptr [ebp-8],  0x7f4a7c15
	mov	dword ptr [ebp-12],  0x9e3779b9
	mov	dword ptr [ebp-16], 0x1ce4e5b9
	mov	dword ptr [ebp-20], 0xbf58476d
	mov	dword ptr [ebp-24], 0x133111eb
	mov	dword ptr [ebp-28], 0x94d049bb
	mov	dword ptr [ebp-32], 0x4f6cdd1d
	mov	dword ptr [ebp-36], 0x2545f491
	mov	ebx, 0xdeadbeef

.Lim_loop:
	/* ---- a = a*m+b ---- */
	mov	eax, [ebp-8]
	mul	ebx
	mov	[ebp-40], eax
	mov	ecx, edx
	mov	eax, [ebp-12]
	mul	ebx
	add	ecx, eax
	mov	eax, [ebp-40]
	add	eax, [ebp-16]
	adc	ecx, [ebp-20]
	mov	[ebp-8], eax
	mov	[ebp-12], ecx

	/* ---- b = b*m+c ---- */
	mov	eax, [ebp-16]
	mul	ebx
	mov	[ebp-40], eax
	mov	ecx, edx
	mov	eax, [ebp-20]
	mul	ebx
	add	ecx, eax
	mov	eax, [ebp-40]
	add	eax, [ebp-24]
	adc	ecx, [ebp-28]
	mov	[ebp-16], eax
	mov	[ebp-20], ecx

	/* ---- c = c*m+d ---- */
	mov	eax, [ebp-24]
	mul	ebx
	mov	[ebp-40], eax
	mov	ecx, edx
	mov	eax, [ebp-28]
	mul	ebx
	add	ecx, eax
	mov	eax, [ebp-40]
	add	eax, [ebp-32]
	adc	ecx, [ebp-36]
	mov	[ebp-24], eax
	mov	[ebp-28], ecx

	/* ---- d = d*m+a(new) ---- */
	mov	eax, [ebp-32]
	mul	ebx
	mov	[ebp-40], eax
	mov	ecx, edx
	mov	eax, [ebp-36]
	mul	ebx
	add	ecx, eax
	mov	eax, [ebp-40]
	add	eax, [ebp-8]
	adc	ecx, [ebp-12]
	mov	[ebp-32], eax
	mov	[ebp-36], ecx

	/* ---- a ^= c>>29 (logical, 64-bit) ---- */
	mov	eax, [ebp-24]
	mov	edx, [ebp-28]
	shrd	eax, edx, 29
	shr	edx, 29
	xor	[ebp-8], eax
	xor	[ebp-12], edx

	/* ---- b ^= d<<17 (64-bit) ---- */
	mov	eax, [ebp-32]
	mov	edx, [ebp-36]
	shld	edx, eax, 17
	shl	eax, 17
	xor	[ebp-16], eax
	xor	[ebp-20], edx

	/* ---- c ^= ror64(a,31) ---- */
	mov	eax, [ebp-8]
	mov	edx, [ebp-12]
	mov	ecx, eax
	shrd	eax, edx, 31
	shr	edx, 31
	shl	ecx, 1
	or	edx, ecx
	xor	[ebp-24], eax
	xor	[ebp-28], edx

	/* ---- d &= ~sar64(b,7) (arithmetic, 64-bit) ---- */
	mov	eax, [ebp-16]
	mov	edx, [ebp-20]
	shrd	eax, edx, 7
	sar	edx, 7
	not	eax
	not	edx
	and	[ebp-32], eax
	and	[ebp-36], edx

	/* ---- a += high64(unsigned a*c): schoolbook 64x64->128 ---- */
	mov	eax, [ebp-8]
	mul	dword ptr [ebp-24]	/* p0 = a_lo*c_lo */
	mov	[ebp-40], edx		/* t0 = p0_hi */
	mov	eax, [ebp-8]
	mul	dword ptr [ebp-28]	/* p1 = a_lo*c_hi */
	mov	[ebp-44], eax		/* t1 = p1_lo */
	mov	[ebp-48], edx		/* t2 = p1_hi */
	mov	eax, [ebp-12]
	mul	dword ptr [ebp-24]	/* p2 = a_hi*c_lo */
	mov	[ebp-52], edx		/* t3 = p2_hi */
	add	eax, [ebp-44]
	mov	ecx, 0
	adc	ecx, 0
	add	eax, [ebp-40]
	adc	ecx, 0			/* ecx = mid-stage carry (0..2) */
	mov	eax, [ebp-12]
	mul	dword ptr [ebp-28]	/* p3 = a_hi*c_hi */
	add	eax, [ebp-48]
	adc	edx, 0
	add	eax, [ebp-52]
	adc	edx, 0
	add	eax, ecx
	adc	edx, 0
	add	[ebp-8], eax
	adc	[ebp-12], edx

	/* ---- b += high64(unsigned b*d) ---- */
	mov	eax, [ebp-16]
	mul	dword ptr [ebp-32]
	mov	[ebp-40], edx
	mov	eax, [ebp-16]
	mul	dword ptr [ebp-36]
	mov	[ebp-44], eax
	mov	[ebp-48], edx
	mov	eax, [ebp-20]
	mul	dword ptr [ebp-32]
	mov	[ebp-52], edx
	add	eax, [ebp-44]
	mov	ecx, 0
	adc	ecx, 0
	add	eax, [ebp-40]
	adc	ecx, 0
	mov	eax, [ebp-20]
	mul	dword ptr [ebp-36]
	add	eax, [ebp-48]
	adc	edx, 0
	add	eax, [ebp-52]
	adc	edx, 0
	add	eax, ecx
	adc	edx, 0
	add	[ebp-16], eax
	adc	[ebp-20], edx

	/* ---- a += c/m ; b += d/m : divisor fits in 32 bits, so two native
	 * `div`s (hi/m first, remainder:lo second) replace a 64-by-64 divide */
	mov	eax, [ebp-28]
	mov	edx, 0
	div	ebx
	mov	ecx, eax		/* q1 */
	mov	eax, [ebp-24]
	div	ebx			/* edx (r1) : eax (c_lo) still set from above */
	add	[ebp-8], eax
	adc	[ebp-12], ecx

	mov	eax, [ebp-36]
	mov	edx, 0
	div	ebx
	mov	ecx, eax
	mov	eax, [ebp-32]
	div	ebx
	add	[ebp-16], eax
	adc	[ebp-20], ecx

	/* ---- b = ror64(b,11) ---- */
	mov	eax, [ebp-16]
	mov	edx, [ebp-20]
	mov	ecx, eax
	shrd	eax, edx, 11
	shr	edx, 11
	shl	ecx, 21
	or	edx, ecx
	mov	[ebp-16], eax
	mov	[ebp-20], edx

	/* ---- a = (a<<23)|(b>>41) ---- */
	mov	eax, [ebp-8]
	mov	edx, [ebp-12]
	shld	edx, eax, 23
	shl	eax, 23
	mov	ecx, [ebp-20]
	shr	ecx, 9
	or	eax, ecx
	mov	[ebp-8], eax
	mov	[ebp-12], edx

	sub	dword ptr [ebp+8], 1
	sbb	dword ptr [ebp+12], 0
	mov	eax, [ebp+8]
	or	eax, [ebp+12]
	jnz	.Lim_loop

	mov	eax, [ebp-8]
	mov	edx, [ebp-12]
	xor	eax, [ebp-16]
	xor	edx, [ebp-20]
	xor	eax, [ebp-24]
	xor	edx, [ebp-28]
	xor	eax, [ebp-32]
	xor	edx, [ebp-36]
	add	esp, 48
	pop	ebx
	pop	ebp
	ret

.Lim_zero:
	xor	eax, eax
	xor	edx, edx
	add	esp, 48
	pop	ebx
	pop	ebp
	ret
FN_END(fb_int_math)


/* ===================================================================
 * uint64_t fb_fp_math(uint64_t iters)   [ [esp+4]:[esp+8] = iters ]
 *
 * Double-precision scalar FP, genuine SSE2 throughout (Pentium 4's SSE2 unit
 * handles mulsd/addsd/minsd/maxsd/divsd/sqrtsd natively - there is no libm
 * call here, unlike the portable C fallback, whose fmin()/fmax() calls force
 * a round trip through the ABI's x87 return convention on every one of the
 * four calls per iteration). 32-bit mode only has xmm0-xmm7, half of
 * amd64's xmm0-xmm15, so unlike that file the four rounding/min/mul/add
 * constants are read directly from memory operands each use instead of
 * being kept pinned in registers - plenty of headroom still remains (this
 * uses at most six of the eight available). Returns the result bit-cast to
 * u64 (edx:eax), matching the uint64_t return type - NOT via the x87
 * ST(0) that a `double` return would use.
 * =================================================================== */
FN_BEGIN(fb_fp_math)
	push	ebp
	mov	ebp, esp
	sub	esp, 8

	mov	eax, [ebp+8]
	or	eax, [ebp+12]
	jz	.Lfp_zero

	movsd	xmm0, [.Lfp_a_init]
	movsd	xmm1, [.Lfp_b_init]
	movsd	xmm2, [.Lfp_c_init]
	movsd	xmm3, [.Lfp_d_init]

.Lfp_loop:
	mulsd	xmm0, [.Lfp_mul]
	addsd	xmm0, [.Lfp_addend]
	minsd	xmm0, [.Lfp_two]

	mulsd	xmm1, [.Lfp_mul]
	addsd	xmm1, [.Lfp_addend]
	minsd	xmm1, [.Lfp_two]

	mulsd	xmm2, [.Lfp_mul]
	addsd	xmm2, [.Lfp_addend]
	minsd	xmm2, [.Lfp_two]
	sqrtsd	xmm4, xmm0
	addsd	xmm2, xmm4

	mulsd	xmm3, [.Lfp_mul]
	addsd	xmm3, [.Lfp_addend]
	minsd	xmm3, [.Lfp_two]
	sqrtsd	xmm5, xmm1
	addsd	xmm3, xmm5
	andpd	xmm3, [.Lfp_absmask]
	maxsd	xmm3, [.Lfp_one]

	movapd	xmm4, xmm2
	addsd	xmm4, [.Lfp_one]
	movsd	xmm5, [.Lfp_one]
	divsd	xmm5, xmm4
	addsd	xmm0, xmm5

	movapd	xmm4, xmm3
	addsd	xmm4, [.Lfp_one]
	movsd	xmm5, [.Lfp_one]
	divsd	xmm5, xmm4
	addsd	xmm1, xmm5

	sub	dword ptr [ebp+8], 1
	sbb	dword ptr [ebp+12], 0
	mov	eax, [ebp+8]
	or	eax, [ebp+12]
	jnz	.Lfp_loop

	addsd	xmm0, xmm1
	addsd	xmm2, xmm3
	addsd	xmm0, xmm2
	movsd	[ebp-8], xmm0
	mov	eax, [ebp-8]
	mov	edx, [ebp-4]
	leave
	ret

.Lfp_zero:
	xor	eax, eax
	xor	edx, edx
	leave
	ret
FN_END(fb_fp_math)

	.p2align 4
.Lfp_a_init:
	.double	1.5
.Lfp_b_init:
	.double	2.5
.Lfp_c_init:
	.double	3.5
.Lfp_d_init:
	.double	0.5
.Lfp_mul:
	.double	1.0625
.Lfp_addend:
	.double	0.0009765625
.Lfp_two:
	.double	2.0
.Lfp_one:
	.double	1.0
	.p2align 4
.Lfp_absmask:
	.quad	0x7fffffffffffffff


/* ===================================================================
 * uint64_t fb_primes(uint64_t limit, uint8_t *sieve)
 *                                        [ [ebp+8]:[ebp+12]=limit, [ebp+16]=sieve ]
 *
 * Sieve of Eratosthenes over [0, limit). Only the low dword of `limit` is
 * used: it is a sieve/buffer size, and a 32-bit process cannot allocate a
 * sieve past 4 GiB anyway, so - like main.c's own CHASE_NODES sizing for
 * UINTPTR_MAX == UINT32_MAX - it is always within 32-bit range in practice.
 * Clears its own scratch (32 bytes/iteration via SSE2), then sieves. Returns
 * the prime count in eax (edx=0: the count is always far under 2^32).
 * =================================================================== */
FN_BEGIN(fb_primes)
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	push	edi

	mov	edi, [ebp+8]		/* limit (low dword) */
	mov	esi, [ebp+16]		/* sieve */
	cmp	edi, 2
	jb	.Lpr_none

	pxor	xmm0, xmm0
	xor	eax, eax
	mov	ecx, edi
	and	ecx, -32
.Lpr_clear32:
	cmp	eax, ecx
	jae	.Lpr_clear1
	movdqu	[esi+eax], xmm0
	movdqu	[esi+eax+16], xmm0
	add	eax, 32
	jmp	.Lpr_clear32
.Lpr_clear1:
	cmp	eax, edi
	jae	.Lpr_clear_done
	mov	byte ptr [esi+eax], 0
	inc	eax
	jmp	.Lpr_clear1
.Lpr_clear_done:

	mov	byte ptr [esi], 1
	mov	byte ptr [esi+1], 1

	mov	ebx, 2			/* i */
.Lpr_outer:
	mov	eax, ebx
	imul	eax, ebx		/* i*i (fits 32 bits: i <= sqrt(limit)) */
	cmp	eax, edi
	jae	.Lpr_count

	movzx	edx, byte ptr [esi+ebx]
	test	dl, dl
	jnz	.Lpr_outer_next

	mov	ecx, eax		/* j = i*i */
.Lpr_inner:
	cmp	ecx, edi
	jae	.Lpr_outer_next
	mov	byte ptr [esi+ecx], 1
	add	ecx, ebx
	jmp	.Lpr_inner

.Lpr_outer_next:
	inc	ebx
	jmp	.Lpr_outer

.Lpr_count:
	xor	eax, eax
	mov	ecx, 2
.Lpr_count_loop:
	cmp	ecx, edi
	jae	.Lpr_done
	cmp	byte ptr [esi+ecx], 0
	jne	.Lpr_count_next
	inc	eax
.Lpr_count_next:
	inc	ecx
	jmp	.Lpr_count_loop

.Lpr_done:
	xor	edx, edx
	pop	edi
	pop	esi
	pop	ebx
	pop	ebp
	ret

.Lpr_none:
	xor	eax, eax
	xor	edx, edx
	pop	edi
	pop	esi
	pop	ebx
	pop	ebp
	ret
FN_END(fb_primes)


/* ===================================================================
 * uint64_t fb_simd(uint64_t iters, void *buf)
 *                                  [ [ebp+8]:[ebp+12]=iters, [ebp+16]=buf ]
 *
 * "Extended instructions": SSE2, architecturally mandatory baseline for this
 * whole file (Pentium 4). 32-bit mode only has xmm0-xmm7 - half of amd64's
 * xmm0-xmm15 - so unlike that file this can't keep eight seed vectors plus
 * scratch plus a separate float pipeline all live at once. Four state
 * vectors (xmm0-3) plus one scratch (xmm5) replace amd64's eight-vector
 * state, but every instruction category survives: packed 16-bit
 * multiply-accumulate, widening 16->32 multiply-add, high-multiply, packed
 * shift/logic funnel, saturating/averaging/min-max arithmetic plus
 * sum-of-absolute-differences, a lane shuffle, and the packed single-
 * precision float path (multiply-add plus the reciprocal/rsqrt estimates).
 *
 * buf must be at least 96 bytes. Returns a checksum (edx=0).
 * =================================================================== */
FN_BEGIN(fb_simd)
	push	ebp
	mov	ebp, esp
	push	esi

	mov	eax, [ebp+8]
	or	eax, [ebp+12]
	jz	.Lsd_zero

	mov	esi, [ebp+16]

	movdqu	xmm0, [esi]		/* seed four integer state vectors */
	movdqu	xmm1, [esi+16]
	movdqu	xmm2, [esi+32]
	movdqu	xmm3, [esi+48]
	movdqu	xmm6, [esi+64]		/* float operands: convert integer seeds to */
	movdqu	xmm7, [esi+80]		/* finite floats, not reinterpreted bit patterns */
	cvtdq2ps xmm6, xmm6
	cvtdq2ps xmm7, xmm7
	pxor	xmm4, xmm4		/* saturating/averaging accumulator */

.Lsd_loop:
	/* 16-bit integer multiply-accumulate across independent vectors */
	pmullw	xmm0, xmm1
	paddw	xmm0, xmm2
	pmullw	xmm1, xmm2
	paddw	xmm1, xmm3
	pmullw	xmm2, xmm3
	paddw	xmm2, xmm0

	/* widening multiply-add: 16->32 bit lanes */
	movdqa	xmm5, xmm0
	pmaddwd	xmm5, xmm1
	paddd	xmm3, xmm5

	/* high-half multiply */
	movdqa	xmm5, xmm0
	pmulhw	xmm5, xmm1
	pxor	xmm2, xmm5

	/* shifts and logic funnel */
	movdqa	xmm5, xmm2
	pslld	xmm5, 3
	psrld	xmm2, 29
	por	xmm2, xmm5
	pand	xmm3, xmm0

	/* saturating/averaging arithmetic, min/max, sum-of-abs-differences */
	paddsw	xmm4, xmm0
	psubusw	xmm4, xmm1
	pmaxsw	xmm4, xmm2
	pminsw	xmm4, xmm3
	pavgb	xmm4, xmm0
	movdqa	xmm5, xmm1
	psadbw	xmm5, xmm4
	paddw	xmm4, xmm5

	/* lane shuffle: reverse the four 32-bit lanes */
	pshufd	xmm0, xmm0, 0x1B
	pxor	xmm1, xmm0

	/* single-precision float SIMD: multiply-add plus reciprocal/rsqrt */
	movaps	xmm5, xmm6
	mulps	xmm5, xmm7
	addps	xmm6, xmm5
	rcpps	xmm5, xmm7
	addps	xmm6, xmm5
	rsqrtps	xmm5, xmm6
	mulps	xmm7, xmm5

	sub	dword ptr [ebp+8], 1
	sbb	dword ptr [ebp+12], 0
	mov	eax, [ebp+8]
	or	eax, [ebp+12]
	jnz	.Lsd_loop

	/* fold the integer state together */
	pxor	xmm0, xmm1
	pxor	xmm2, xmm3
	pxor	xmm0, xmm2
	pxor	xmm0, xmm4

	/* fold in the float accumulator (truncate to int lanes) */
	cvttps2dq xmm6, xmm6
	pxor	xmm0, xmm6

	/* horizontal add of the four 32-bit lanes -> single checksum */
	pshufd	xmm1, xmm0, 0x4E
	paddd	xmm0, xmm1
	pshufd	xmm1, xmm0, 0xB1
	paddd	xmm0, xmm1
	movd	eax, xmm0
	xor	edx, edx
	pop	esi
	pop	ebp
	ret

.Lsd_zero:
	xor	eax, eax
	xor	edx, edx
	pop	esi
	pop	ebp
	ret
FN_END(fb_simd)


/* ===================================================================
 * uint64_t fb_compress(const uint8_t *src, uint64_t len, uint32_t *ht)
 *                       [ [ebp+8]=src, [ebp+12]:[ebp+16]=len, [ebp+20]=ht ]
 *
 * The LZ77 fast-match inner loop (LZ4-style): hash the next 4 bytes, probe a
 * single-entry-per-bucket table, verify, then extend. Only the low dword of
 * `len` is used (a buffer size - see fb_primes). This one has the tightest
 * register budget in the file: ip, ref, end and the match length all need
 * to be live across the byte-by-byte extend loop, which leaves nothing to
 * hold ht/src/anchor/mflimit/outsize in registers too, so those live on the
 * stack frame instead and get reloaded each outer iteration - the extend
 * loop itself (the actual hot part) stays all-register.
 *
 * ht must hold 1<<16 uint32_t (256 KiB); this routine clears it itself.
 * Returns the encoded size in bytes (edx=0).
 * =================================================================== */
FN_BEGIN(fb_compress)
	push	ebp
	mov	ebp, esp
	push	ebx
	push	edi
	push	esi
	sub	esp, 20

	/* frame: ht=[ebp-16] src=[ebp-20] anchor=[ebp-24] mflimit=[ebp-28]
	 *        outsize=[ebp-32]
	 * persistent regs: edi=ip, ebx=end */

	mov	eax, [ebp+8]		/* src */
	mov	[ebp-20], eax
	mov	edi, eax
	mov	eax, [ebp+20]		/* ht */
	mov	[ebp-16], eax

	/* clear the hash table: 1<<16 entries * 4 bytes = 262144 bytes */
	pxor	xmm0, xmm0
	xor	eax, eax
	mov	ecx, [ebp-16]
.Lcm_clear:
	movdqu	[ecx+eax], xmm0
	movdqu	[ecx+eax+16], xmm0
	movdqu	[ecx+eax+32], xmm0
	movdqu	[ecx+eax+48], xmm0
	add	eax, 64
	cmp	eax, 262144
	jb	.Lcm_clear

	mov	eax, [ebp+12]		/* len (low dword) */
	cmp	eax, 16
	jb	.Lcm_tiny

	mov	[ebp-24], edi		/* anchor = ip (still == src here) */
	mov	ebx, edi
	add	ebx, eax		/* end = src+len */
	mov	ecx, ebx
	sub	ecx, 12
	mov	[ebp-28], ecx		/* mflimit = end-12 */
	mov	dword ptr [ebp-32], 0	/* outsize */

.Lcm_loop:
	cmp	edi, [ebp-28]
	jae	.Lcm_flush

	mov	eax, [edi]		/* seq = load32(ip) */
	imul	eax, eax, 0x9E3779B1
	shr	eax, 16			/* h = (seq*prime) >> 16 */

	mov	edx, [ebp-16]		/* ht */
	mov	ecx, [edx+eax*4]	/* ref_off = ht[h] */
	mov	esi, edi
	sub	esi, [ebp-20]		/* cur_off = ip - src */
	mov	[edx+eax*4], esi	/* ht[h] = cur_off */

	mov	esi, [ebp-20]
	add	esi, ecx		/* ref = src + ref_off */
	cmp	esi, edi
	jae	.Lcm_no_match		/* ref must be strictly behind ip */

	mov	eax, edi
	sub	eax, esi		/* distance */
	cmp	eax, 65536
	jae	.Lcm_no_match		/* 16-bit offset window */

	mov	eax, [esi]
	cmp	eax, [edi]		/* verify the 4-byte match */
	jne	.Lcm_no_match

	/* match confirmed: extend it byte by byte (edi=ip, esi=ref, ebx=end) */
	mov	ecx, 4			/* ml */
.Lcm_extend:
	lea	eax, [edi+ecx]
	cmp	eax, ebx		/* ip + ml vs end */
	jae	.Lcm_emit
	mov	dl, [edi+ecx]
	cmp	dl, [esi+ecx]
	jne	.Lcm_emit
	inc	ecx
	jmp	.Lcm_extend

.Lcm_emit:
	/* token(1) + offset(2) + literals + varint extensions */
	mov	eax, edi
	sub	eax, [ebp-24]		/* literal run length */
	add	[ebp-32], eax
	add	dword ptr [ebp-32], 3
	cmp	eax, 15
	jb	.Lcm_no_lit_ext
	inc	dword ptr [ebp-32]	/* literal-length extension byte */
.Lcm_no_lit_ext:
	cmp	ecx, 19
	jb	.Lcm_no_ml_ext
	inc	dword ptr [ebp-32]	/* match-length extension byte */
.Lcm_no_ml_ext:
	add	edi, ecx		/* ip += ml */
	mov	[ebp-24], edi		/* anchor = ip */
	jmp	.Lcm_loop

.Lcm_no_match:
	inc	edi
	jmp	.Lcm_loop

.Lcm_flush:
	/* trailing literals */
	mov	eax, ebx
	sub	eax, [ebp-24]		/* end - anchor */
	add	eax, [ebp-32]
	add	eax, 1
	jmp	.Lcm_ret

.Lcm_tiny:
	lea	eax, [eax+1]		/* len + 1 */

.Lcm_ret:
	xor	edx, edx
	add	esp, 20
	pop	esi
	pop	edi
	pop	ebx
	pop	ebp
	ret
FN_END(fb_compress)


/* rotate each 32-bit lane of v left by n, via shift-left + shift-right + or.
 * xmm7 is scratch (dedicated - see fb_chacha20's register map below). */
.macro	ROL32_I386 v, n
	movdqa	xmm7, \v
	pslld	\v, \n
	psrld	xmm7, (32 - \n)
	por	\v, xmm7
.endm

/* one ChaCha quarter-round over rows a,b,c,d */
.macro	QROUND_I386 a, b, c, d
	paddd	\a, \b
	pxor	\d, \a
	ROL32_I386 \d, 16
	paddd	\c, \d
	pxor	\b, \c
	ROL32_I386 \b, 12
	paddd	\a, \b
	pxor	\d, \a
	ROL32_I386 \d, 8
	paddd	\c, \d
	pxor	\b, \c
	ROL32_I386 \b, 7
.endm

/* ===================================================================
 * uint64_t fb_chacha20(uint8_t *buf, uint64_t len,
 *                       const uint8_t key[32], uint64_t passes)
 *      [ [ebp+8]=buf, [ebp+12]:[ebp+16]=len, [ebp+20]=key, [ebp+24]:[ebp+28]=passes ]
 *
 * ChaCha20, SSE2, four 128-bit state rows - same 32-bit-mode register
 * squeeze as fb_simd: xmm0-3 are the working state (rows A-D, mutated every
 * round), xmm4-6 pin the constant/key base rows (re-copied into xmm0-2 each
 * block) and xmm7 is the ROL32 scratch - that is all eight xmm registers
 * with none left over, so unlike the amd64 file, the pre-round state (needed
 * for the feed-forward add) and the running keystream checksum live on the
 * stack instead of in xmm8-13.
 *
 * len is rounded down to a multiple of 64 (buffer size - see fb_primes: low
 * dword only). Returns a checksum of the keystream output (edx=0).
 * =================================================================== */
FN_BEGIN(fb_chacha20)
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	push	edi
	sub	esp, 80

	/* frame: orig0=[ebp-28] orig1=[ebp-44] orig2=[ebp-60] orig3=[ebp-76]
	 *        checksum=[ebp-92] (each a 16-byte slot)
	 * persistent regs: edi=buf  ebx=len(rounded)  edx=block counter */

	mov	eax, [ebp+12]		/* len (low dword) */
	and	eax, -64
	jz	.Lcc_zero
	mov	ebx, eax

	mov	eax, [ebp+24]
	or	eax, [ebp+28]
	jz	.Lcc_zero

	mov	edi, [ebp+8]		/* buf */
	mov	eax, [ebp+20]		/* key */
	movdqa	xmm4, [.Lcc_sigma]	/* "expand 32-byte k" */
	movdqu	xmm5, [eax]		/* key[0..15]  */
	movdqu	xmm6, [eax+16]		/* key[16..31] */

	pxor	xmm7, xmm7
	movdqu	[ebp-92], xmm7		/* running checksum = 0 */
	xor	edx, edx		/* block counter value */

.Lcc_pass:
	xor	esi, esi		/* byte offset into buf */

.Lcc_block:
	/* working state = base state, block counter in lane 0 of row D */
	movdqa	xmm0, xmm4
	movdqa	xmm1, xmm5
	movdqa	xmm2, xmm6
	movd	xmm3, edx

	/* keep originals on the stack for the final feed-forward add */
	movdqu	[ebp-28], xmm0
	movdqu	[ebp-44], xmm1
	movdqu	[ebp-60], xmm2
	movdqu	[ebp-76], xmm3

	mov	ecx, 10			/* 10 double rounds = 20 rounds */
.Lcc_rounds:
	/* column round */
	QROUND_I386 xmm0, xmm1, xmm2, xmm3

	/* rotate lanes to form the diagonals */
	pshufd	xmm1, xmm1, 0x39
	pshufd	xmm2, xmm2, 0x4E
	pshufd	xmm3, xmm3, 0x93

	/* diagonal round */
	QROUND_I386 xmm0, xmm1, xmm2, xmm3

	/* undo the lane rotation */
	pshufd	xmm1, xmm1, 0x93
	pshufd	xmm2, xmm2, 0x4E
	pshufd	xmm3, xmm3, 0x39

	dec	ecx
	jnz	.Lcc_rounds

	/* feed-forward: keystream = working + original. paddd's memory form
	 * requires 16-byte alignment, which this stack slot isn't guaranteed
	 * to have (unlike the amd64 ABI, i386 doesn't guarantee 16-byte ESP
	 * alignment at entry), so load through xmm7 (free again post-rounds)
	 * with the alignment-agnostic movdqu instead of adding memory directly. */
	movdqu	xmm7, [ebp-28]
	paddd	xmm0, xmm7
	movdqu	xmm7, [ebp-44]
	paddd	xmm1, xmm7
	movdqu	xmm7, [ebp-60]
	paddd	xmm2, xmm7
	movdqu	xmm7, [ebp-76]
	paddd	xmm3, xmm7

	/* XOR the keystream into the buffer */
	lea	eax, [edi+esi]
	movdqu	xmm7, [eax]
	pxor	xmm7, xmm0
	movdqu	[eax], xmm7
	movdqu	xmm7, [eax+16]
	pxor	xmm7, xmm1
	movdqu	[eax+16], xmm7
	movdqu	xmm7, [eax+32]
	pxor	xmm7, xmm2
	movdqu	[eax+32], xmm7
	movdqu	xmm7, [eax+48]
	pxor	xmm7, xmm3
	movdqu	[eax+48], xmm7

	/* accumulate a checksum of the keystream */
	movdqu	xmm7, [ebp-92]
	pxor	xmm7, xmm0
	pxor	xmm7, xmm3
	movdqu	[ebp-92], xmm7

	inc	edx			/* counter++ */
	add	esi, 64
	cmp	esi, ebx
	jb	.Lcc_block

	sub	dword ptr [ebp+24], 1
	sbb	dword ptr [ebp+28], 0
	mov	eax, [ebp+24]
	or	eax, [ebp+28]
	jnz	.Lcc_pass

	/* horizontal add of the checksum lanes */
	movdqu	xmm0, [ebp-92]
	pshufd	xmm1, xmm0, 0x4E
	paddd	xmm0, xmm1
	pshufd	xmm1, xmm0, 0xB1
	paddd	xmm0, xmm1
	movd	eax, xmm0
	xor	edx, edx
	add	esp, 80
	pop	edi
	pop	esi
	pop	ebx
	pop	ebp
	ret

.Lcc_zero:
	xor	eax, eax
	xor	edx, edx
	add	esp, 80
	pop	edi
	pop	esi
	pop	ebx
	pop	ebp
	ret
FN_END(fb_chacha20)

	.p2align 4
.Lcc_sigma:
	.long	0x61707865, 0x3320646e, 0x79622d32, 0x6b206574


/* ===================================================================
 * uint64_t fb_physics(double *bodies, uint64_t n, uint64_t steps)
 *      [ [ebp+8]=bodies, [ebp+12]:[ebp+16]=n, [ebp+20]:[ebp+24]=steps ]
 *
 * Direct-summation N-body gravity, O(n^2) per step, double precision, real
 * sqrtsd+divsd (not an rsqrt estimate). Layout per body, 8 doubles (64
 * bytes): [x y z mass vx vy vz pad]. `n` uses only its low dword (a body
 * count - see fb_primes). xmm0-2 hold body i's position for the whole inner
 * loop, xmm3-5 accumulate its acceleration, and xmm6-7 are the only scratch
 * left - not enough to hold dx/dy/dz simultaneously alongside r/1/r/m-over-r3,
 * so the three deltas spill to three stack doubles between being computed
 * and being used in the final ax+=dx*q step. Returns a velocity checksum
 * (edx=0).
 * =================================================================== */
FN_BEGIN(fb_physics)
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	push	edi
	sub	esp, 24

	/* frame: dx=[ebp-20] dy=[ebp-28] dz=[ebp-36]
	 * persistent regs: edi=bodies  ebx=n */

	mov	ebx, [ebp+12]		/* n (low dword) */
	test	ebx, ebx
	jz	.Lph_zero
	mov	eax, [ebp+20]
	or	eax, [ebp+24]
	jz	.Lph_zero

	mov	edi, [ebp+8]		/* bodies */

.Lph_step:
	xor	eax, eax		/* i */

.Lph_body_i:
	mov	ecx, eax
	shl	ecx, 6			/* i * 64 */
	lea	esi, [edi+ecx]		/* &bodies[i] */

	movsd	xmm0, [esi]		/* xi */
	movsd	xmm1, [esi+8]		/* yi */
	movsd	xmm2, [esi+16]		/* zi */

	xorpd	xmm3, xmm3		/* ax */
	xorpd	xmm4, xmm4		/* ay */
	xorpd	xmm5, xmm5		/* az */

	xor	ecx, ecx		/* j */
	mov	edx, edi		/* &bodies[j] */

.Lph_body_j:
	movsd	xmm6, [edx]
	subsd	xmm6, xmm0		/* dx */
	movsd	[ebp-20], xmm6
	movsd	xmm6, [edx+8]
	subsd	xmm6, xmm1		/* dy */
	movsd	[ebp-28], xmm6
	movsd	xmm6, [edx+16]
	subsd	xmm6, xmm2		/* dz */
	movsd	[ebp-36], xmm6

	/* r2 = dx*dx + dy*dy + dz*dz + eps^2 */
	movsd	xmm6, [ebp-20]
	mulsd	xmm6, xmm6
	movsd	xmm7, [ebp-28]
	mulsd	xmm7, xmm7
	addsd	xmm6, xmm7
	movsd	xmm7, [ebp-36]
	mulsd	xmm7, xmm7
	addsd	xmm6, xmm7
	addsd	xmm6, [.Lph_eps2]

	sqrtsd	xmm6, xmm6		/* r     */
	movsd	xmm7, [.Lph_one]
	divsd	xmm7, xmm6		/* 1/r   */
	movsd	xmm6, xmm7
	mulsd	xmm6, xmm7		/* 1/r^2 */
	mulsd	xmm6, xmm7		/* 1/r^3 */
	mulsd	xmm6, [edx+24]		/* m/r^3 */

	movsd	xmm7, [ebp-20]
	mulsd	xmm7, xmm6		/* dx * m/r^3 */
	addsd	xmm3, xmm7
	movsd	xmm7, [ebp-28]
	mulsd	xmm7, xmm6
	addsd	xmm4, xmm7
	movsd	xmm7, [ebp-36]
	mulsd	xmm7, xmm6
	addsd	xmm5, xmm7

	add	edx, 64
	inc	ecx
	cmp	ecx, ebx
	jb	.Lph_body_j

	/* v += a * dt */
	movsd	xmm6, [esi+32]		/* vx */
	mulsd	xmm3, [.Lph_dt]
	addsd	xmm6, xmm3
	movsd	[esi+32], xmm6
	movsd	xmm6, [esi+40]		/* vy */
	mulsd	xmm4, [.Lph_dt]
	addsd	xmm6, xmm4
	movsd	[esi+40], xmm6
	movsd	xmm6, [esi+48]		/* vz */
	mulsd	xmm5, [.Lph_dt]
	addsd	xmm6, xmm5
	movsd	[esi+48], xmm6

	inc	eax
	cmp	eax, ebx
	jb	.Lph_body_i

	/* second pass: x += v * dt (positions move only after all forces) */
	xor	eax, eax
	mov	edx, edi
.Lph_integrate:
	movsd	xmm0, [edx]
	movsd	xmm1, [edx+8]
	movsd	xmm2, [edx+16]
	movsd	xmm6, [edx+32]
	mulsd	xmm6, [.Lph_dt]
	addsd	xmm0, xmm6
	movsd	xmm7, [edx+40]
	mulsd	xmm7, [.Lph_dt]
	addsd	xmm1, xmm7
	movsd	xmm6, [edx+48]
	mulsd	xmm6, [.Lph_dt]
	addsd	xmm2, xmm6
	movsd	[edx], xmm0
	movsd	[edx+8], xmm1
	movsd	[edx+16], xmm2
	add	edx, 64
	inc	eax
	cmp	eax, ebx
	jb	.Lph_integrate

	sub	dword ptr [ebp+20], 1
	sbb	dword ptr [ebp+24], 0
	mov	eax, [ebp+20]
	or	eax, [ebp+24]
	jnz	.Lph_step

	/* checksum: sum of all velocity components */
	xorpd	xmm0, xmm0
	xor	eax, eax
	mov	edx, edi
.Lph_sum:
	movsd	xmm6, [edx+32]
	addsd	xmm0, xmm6
	movsd	xmm6, [edx+40]
	addsd	xmm0, xmm6
	movsd	xmm6, [edx+48]
	addsd	xmm0, xmm6
	add	edx, 64
	inc	eax
	cmp	eax, ebx
	jb	.Lph_sum

	movsd	[ebp-20], xmm0
	mov	eax, [ebp-20]
	mov	edx, [ebp-16]
	add	esp, 24
	pop	edi
	pop	esi
	pop	ebx
	pop	ebp
	ret

.Lph_zero:
	xor	eax, eax
	xor	edx, edx
	add	esp, 24
	pop	edi
	pop	esi
	pop	ebx
	pop	ebp
	ret
FN_END(fb_physics)

	.p2align 4
.Lph_dt:
	.double	0.0078125			/* dt    */
.Lph_eps2:
	.double	0.0625				/* eps^2 */
.Lph_one:
	.double	1.0


/* ===================================================================
 * uint64_t fb_sort(uint32_t *a, uint64_t n)   [ [ebp+8]=a, [ebp+12]:[ebp+16]=n ]
 *
 * In-place heapsort, same shape as the amd64 file: no recursion, an
 * order-sensitive checksum that doubles as a correctness check. `n` uses
 * only its low dword (an element count - see fb_primes). The internal
 * siftdown is reached with `call`/`ret` sharing this function's own frame
 * (no separate prologue) exactly like the amd64 version; it borrows ebx and
 * esi as scratch for the duration of one call via push/pop, since i386 has
 * too few registers to dedicate two more to root/child bookkeeping on top of
 * a, root, end and a value temporary. The checksum itself is 32-bit (i386
 * has no 64-bit rotate) - test_kernels.c only requires it be deterministic
 * and permutation-sensitive, which this is.
 * =================================================================== */
FN_BEGIN(fb_sort)
	push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	push	edi

	mov	ebx, [ebp+12]		/* n (low dword) */
	cmp	ebx, 2
	jb	.Lst_trivial

	/* ---- build the max-heap: for i = n/2 - 1 down to 0 ---- */
	mov	esi, ebx
	shr	esi, 1			/* i = n/2 */
.Lst_build:
	test	esi, esi
	jz	.Lst_extract
	dec	esi			/* i-- */
	mov	ecx, esi		/* root */
	mov	edx, ebx		/* end  */
	call	.Lst_siftdown
	test	esi, esi
	jnz	.Lst_build

	/* ---- extract: for end = n-1 down to 1 ---- */
.Lst_extract:
	mov	esi, ebx
	dec	esi			/* end = n-1 */
.Lst_extract_loop:
	test	esi, esi
	jz	.Lst_checksum

	/* swap a[0] and a[end] */
	mov	edi, [ebp+8]
	mov	eax, [edi]
	mov	ecx, [edi+esi*4]
	mov	[edi], ecx
	mov	[edi+esi*4], eax

	xor	ecx, ecx		/* root = 0  */
	mov	edx, esi		/* end = end */
	call	.Lst_siftdown

	dec	esi
	jmp	.Lst_extract_loop

	/* ---- order-sensitive checksum ---- */
.Lst_checksum:
	xor	eax, eax
	xor	ecx, ecx		/* index */
	mov	edi, [ebp+8]
.Lst_cksum_loop:
	mov	edx, [edi+ecx*4]
	xor	eax, edx
	ror	eax, 7
	add	eax, edx
	inc	ecx
	cmp	ecx, ebx
	jb	.Lst_cksum_loop
	xor	edx, edx
	pop	edi
	pop	esi
	pop	ebx
	pop	ebp
	ret

.Lst_trivial:
	xor	eax, eax
	xor	edx, edx
	test	ebx, ebx
	jz	.Lst_trivial_ret
	mov	edi, [ebp+8]
	mov	eax, [edi]
.Lst_trivial_ret:
	pop	edi
	pop	esi
	pop	ebx
	pop	ebp
	ret

	/* ---- local helper: siftdown(root = ecx, end = edx)
	 * base a is reloaded from [ebp+8] each call (edi is otherwise free);
	 * ebx/esi are borrowed as scratch and restored before return, since
	 * the caller's ebx (n) and esi (build/extract index) must survive. ---- */
.Lst_siftdown:
	push	ebx
	push	esi
	mov	edi, [ebp+8]		/* a */
.Lst_sift_loop:
	lea	ebx, [ecx+ecx+1]	/* child = 2*root + 1 */
	cmp	ebx, edx
	jae	.Lst_sift_done		/* no children */

	lea	esi, [ebx+1]		/* right = child + 1 */
	cmp	esi, edx
	jae	.Lst_sift_have_child	/* no right child */
	mov	eax, [edi+esi*4]	/* a[right] */
	cmp	eax, [edi+ebx*4]	/* a[right] vs a[child] */
	jbe	.Lst_sift_have_child	/* keep child if a[right] <= it */
	mov	ebx, esi		/* else child = right */

.Lst_sift_have_child:
	mov	eax, [edi+ecx*4]	/* a[root]  */
	mov	esi, [edi+ebx*4]	/* a[child] */
	cmp	eax, esi
	jae	.Lst_sift_done		/* heap property holds */

	/* swap and descend */
	mov	[edi+ecx*4], esi
	mov	[edi+ebx*4], eax
	mov	ecx, ebx
	jmp	.Lst_sift_loop

.Lst_sift_done:
	pop	esi
	pop	ebx
	ret
FN_END(fb_sort)


/* ===================================================================
 * uint64_t fb_chase(void **ptrs, uint64_t steps)
 *                                  [ [esp+4]=ptrs, [esp+8]:[esp+12]=steps ]
 *
 * Pointer chase around a randomised cycle. Every load depends on the
 * previous one, so nothing can be prefetched, overlapped or reordered - the
 * truest single-threaded memory-latency test in the suite. Needs no
 * callee-saved registers at all (eax/ecx/edx suffice), so unlike every other
 * kernel here it has no prologue - args stay at their original [esp+N]
 * offsets since esp never moves.
 * =================================================================== */
FN_BEGIN(fb_chase)
	mov	ecx, [esp+8]
	or	ecx, [esp+12]
	jz	.Lch_zero

	mov	eax, [esp+4]		/* p = ptrs */
.Lch_loop:
	mov	eax, [eax]
	sub	dword ptr [esp+8], 1
	sbb	dword ptr [esp+12], 0
	mov	ecx, [esp+8]
	or	ecx, [esp+12]
	jnz	.Lch_loop

	sub	eax, [esp+4]		/* final offset, keeps p live */
	xor	edx, edx
	ret

.Lch_zero:
	xor	eax, eax
	xor	edx, edx
	ret
FN_END(fb_chase)


#if defined(__ELF__)
	.section	.note.GNU-stack, "", @progbits
#endif
