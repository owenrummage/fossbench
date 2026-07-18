/*
 * fossbench_x86_64.S - x86-64 (AMD64) CPU benchmark kernels
 *
 * The AMD64 counterpart to fossbench.S. Same nine routines, same contract: each
 * is a pure function of its arguments under the System V AMD64 ABI, contains no
 * syscalls, no libc calls and no external data relocations, so it assembles and
 * runs on Linux (ELF), macOS (Mach-O) and the BSDs. The portable C driver in
 * main.c is shared unchanged between this file and the AArch64 one.
 *
 * Only baseline instructions are used: general-purpose AMD64 plus SSE2, which
 * is architecturally mandatory on x86-64. The optional extensions (SSE4, AVX,
 * FMA, AES-NI, POPCNT/BMI) are deliberately avoided - using them unguarded
 * would fault (#UD) on cores that lack them - so, exactly as the NEON file
 * sticks to mandatory ASIMD and shuns the optional AES/SHA/DotProd, this file
 * sticks to mandatory SSE2 and shuns everything above it. FMA in particular is
 * optional here, so every fused multiply-add is written as a separate multiply
 * and add.
 *
 * Register conventions (System V AMD64):
 *   integer args   rdi, rsi, rdx, rcx, r8, r9   (return in rax)
 *   callee-saved   rbx, rbp, r12, r13, r14, r15 (saved when used)
 *   all of xmm0-15 are caller-saved, so no vector register need be preserved.
 */

	.intel_syntax noprefix

#if defined(__APPLE__)
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
 * uint64_t fb_int_math(uint64_t iters)          [rdi = iters]
 *
 * Four independent multiply-accumulate chains for instruction-level
 * parallelism, mixed with the long-latency serialising ops (mul/div) and
 * bit-manipulation. Returns a checksum so nothing can be elided.
 * =================================================================== */
FN_BEGIN(fb_int_math)
	test	rdi, rdi
	jz	.Lim_zero

	mov	r8,  0x9E3779B97F4A7C15		/* a */
	mov	r9,  0xBF58476D1CE4E5B9		/* b */
	mov	r10, 0x94D049BB133111EB		/* c */
	mov	r11, 0x2545F4914F6CDD1D		/* d */
	mov	rsi, 0x00000000DEADBEEF		/* odd multiplier, never zero */

.Lim_loop:
	/* four independent multiply-accumulate chains */
	imul	r8, rsi
	add	r8, r9
	imul	r9, rsi
	add	r9, r10
	imul	r10, rsi
	add	r10, r11
	imul	r11, rsi
	add	r11, r8

	/* cross-mix with shifts and logic ops */
	mov	rax, r10
	shr	rax, 29
	xor	r8, rax
	mov	rax, r11
	shl	rax, 17
	xor	r9, rax
	mov	rax, r8
	ror	rax, 31
	xor	r10, rax
	mov	rax, r9
	sar	rax, 7
	not	rax
	and	r11, rax			/* r11 &= ~(r9 >> 7 arith) */

	/* wide multiplies: the long-latency 128-bit multiplier path */
	mov	rax, r8
	mul	r10				/* rdx:rax = a*c, high in rdx */
	add	r8, rdx
	mov	rax, r9
	imul	r11				/* rdx:rax = b*d signed, high rdx */
	add	r9, rdx

	/* bit manipulation: byte reverse */
	mov	rax, r10
	bswap	rax
	xor	r8, rax
	mov	rax, r11
	bswap	rax
	xor	r9, rax

	/* division: fully serialising, not pipelined */
	mov	rcx, rsi
	or	rcx, 1				/* guarantee a non-zero divisor */
	mov	rax, r8
	xor	edx, edx
	div	rcx				/* rax = a / rcx (unsigned) */
	imul	rax, rcx
	sub	r10, rax			/* c -= (a/div)*div */
	mov	rax, r9
	cqo
	idiv	rcx				/* rax = b / rcx (signed) */
	add	r11, rax

	/* bitfield ops */
	ror	r9, 11
	shld	r8, r9, 23

	dec	rdi
	jnz	.Lim_loop

	mov	rax, r8
	xor	rax, r9
	xor	rax, r10
	xor	rax, r11
	ret

.Lim_zero:
	xor	eax, eax
	ret
FN_END(fb_int_math)


/* ===================================================================
 * uint64_t fb_fp_math(uint64_t iters)           [rdi = iters]
 *
 * Double-precision scalar FP. Four multiply-add chains for the pipelined
 * path; sqrtsd and divsd for the non-pipelined divide/sqrt unit that usually
 * separates cores. Returns the result bit-cast to u64.
 * =================================================================== */
FN_BEGIN(fb_fp_math)
	test	rdi, rdi
	jz	.Lfp_zero

	movsd	xmm0, [rip + .Lfp_consts + 0]	/* a = 1.5  */
	movsd	xmm1, [rip + .Lfp_consts + 8]	/* b = 2.5  */
	movsd	xmm2, [rip + .Lfp_consts + 16]	/* c = 3.5  */
	movsd	xmm3, [rip + .Lfp_consts + 24]	/* d = 0.5  */
	movsd	xmm4, [rip + .Lfp_consts + 32]	/* mul      */
	movsd	xmm5, [rip + .Lfp_consts + 40]	/* addend   */
	movsd	xmm6, [rip + .Lfp_consts + 48]	/* 2.0      */
	movsd	xmm7, [rip + .Lfp_consts + 56]	/* 1.0      */

.Lfp_loop:
	/* four independent multiply-add chains (no baseline FMA) */
	mulsd	xmm0, xmm4
	addsd	xmm0, xmm5
	mulsd	xmm1, xmm4
	addsd	xmm1, xmm5
	mulsd	xmm2, xmm4
	addsd	xmm2, xmm5
	mulsd	xmm3, xmm4
	addsd	xmm3, xmm5

	/* keep the accumulators bounded so they never reach inf/NaN */
	minsd	xmm0, xmm6
	minsd	xmm1, xmm6
	minsd	xmm2, xmm6
	minsd	xmm3, xmm6

	/* square root: long latency, low throughput */
	sqrtsd	xmm8, xmm0
	sqrtsd	xmm9, xmm1
	addsd	xmm2, xmm8
	addsd	xmm3, xmm9

	/* divide: 1/(c+1), divisor >= 1 so never zero */
	movapd	xmm10, xmm2
	addsd	xmm10, xmm7
	movapd	xmm11, xmm7
	divsd	xmm11, xmm10
	addsd	xmm0, xmm11

	movapd	xmm10, xmm3
	addsd	xmm10, xmm7
	movapd	xmm11, xmm7
	divsd	xmm11, xmm10
	addsd	xmm1, xmm11

	/* abs/neg/max: cheap ops to balance the mix */
	andpd	xmm2, [rip + .Lfp_absmask]	/* fabs(c) */
	xorpd	xmm3, [rip + .Lfp_signmask]	/* fneg(d) */
	andpd	xmm3, [rip + .Lfp_absmask]	/* fabs()  */
	maxsd	xmm3, xmm7

	dec	rdi
	jnz	.Lfp_loop

	addsd	xmm0, xmm1
	addsd	xmm2, xmm3
	addsd	xmm0, xmm2
	movq	rax, xmm0
	ret

.Lfp_zero:
	xor	eax, eax
	ret
FN_END(fb_fp_math)

	.p2align 4
.Lfp_consts:
	.double	1.5, 2.5
	.double	3.5, 0.5
	.double	1.0625, 0.0009765625
	.double	2.0, 1.0
	.p2align 4
.Lfp_absmask:
	.quad	0x7fffffffffffffff, 0x7fffffffffffffff
.Lfp_signmask:
	.quad	0x8000000000000000, 0x8000000000000000


/* ===================================================================
 * uint64_t fb_primes(uint64_t limit, uint8_t *sieve)   [rdi, rsi]
 *
 * Sieve of Eratosthenes over [0, limit). The routine clears the caller's
 * scratch itself, so the clearing pass counts as measured work. Strided stores
 * over a buffer larger than L1 make this a memory-hierarchy test too. Returns
 * the prime count.
 * =================================================================== */
FN_BEGIN(fb_primes)
	cmp	rdi, 2
	jb	.Lpr_none

	/* zero the sieve, 32 bytes per iteration */
	pxor	xmm0, xmm0
	xor	rax, rax			/* index */
	mov	rcx, rdi
	and	rcx, -32			/* bulk portion */
.Lpr_clear32:
	cmp	rax, rcx
	jae	.Lpr_clear1
	movdqu	[rsi + rax], xmm0
	movdqu	[rsi + rax + 16], xmm0
	add	rax, 32
	jmp	.Lpr_clear32
.Lpr_clear1:
	cmp	rax, rdi
	jae	.Lpr_clear_done
	mov	byte ptr [rsi + rax], 0
	inc	rax
	jmp	.Lpr_clear1
.Lpr_clear_done:

	/* mark 0 and 1 as composite */
	mov	byte ptr [rsi], 1
	mov	byte ptr [rsi + 1], 1

	/* outer loop: i = 2; i*i < limit; i++ */
	mov	r8, 2
.Lpr_outer:
	mov	rax, r8
	imul	rax, r8				/* i*i */
	cmp	rax, rdi
	jae	.Lpr_count

	movzx	edx, byte ptr [rsi + r8]
	test	dl, dl
	jnz	.Lpr_outer_next			/* already composite, skip */

	/* inner loop: mark multiples starting at i*i, stride i */
	mov	r9, rax				/* j = i*i */
.Lpr_inner:
	cmp	r9, rdi
	jae	.Lpr_outer_next
	mov	byte ptr [rsi + r9], 1
	add	r9, r8
	jmp	.Lpr_inner

.Lpr_outer_next:
	inc	r8
	jmp	.Lpr_outer

	/* count the survivors */
.Lpr_count:
	xor	eax, eax			/* count */
	mov	r9, 2
.Lpr_count_loop:
	cmp	r9, rdi
	jae	.Lpr_done
	cmp	byte ptr [rsi + r9], 0
	jne	.Lpr_count_next
	inc	rax
.Lpr_count_next:
	inc	r9
	jmp	.Lpr_count_loop

.Lpr_done:
	ret

.Lpr_none:
	xor	eax, eax
	ret
FN_END(fb_primes)


/* ===================================================================
 * uint64_t fb_simd(uint64_t iters, void *buf)   [rdi = iters, rsi = buf]
 *
 * "Extended instructions": the SSE2 unit, which is architecturally mandatory
 * on x86-64 and therefore safe without runtime feature detection. Packed
 * 16-bit integer arithmetic is used (SSE2's widest integer multiply is 16-bit;
 * 32-bit packed multiply, pmulld, is an SSE4.1 extension and is avoided), plus
 * saturating/averaging ops, widening multiply-add, shuffles and the packed
 * single-precision float path including the reciprocal/rsqrt estimates.
 *
 * buf must be at least 128 bytes. Returns a checksum.
 * =================================================================== */
FN_BEGIN(fb_simd)
	test	rdi, rdi
	jz	.Lsd_zero

	/* seed eight vectors from the scratch buffer */
	movdqu	xmm0, [rsi]
	movdqu	xmm1, [rsi + 16]
	movdqu	xmm2, [rsi + 32]
	movdqu	xmm3, [rsi + 48]
	movdqu	xmm4, [rsi + 64]
	movdqu	xmm5, [rsi + 80]
	movdqu	xmm6, [rsi + 96]
	movdqu	xmm7, [rsi + 112]

	/* float operands: convert the integer seeds to finite floats rather
	 * than reinterpreting bit patterns (which would be NaNs/denormals) */
	cvtdq2ps xmm12, xmm0
	cvtdq2ps xmm13, xmm1
	pxor	xmm14, xmm14			/* float accumulator */

.Lsd_loop:
	/* 16-bit integer multiply-accumulate across independent vectors */
	pmullw	xmm0, xmm1
	paddw	xmm0, xmm2
	pmullw	xmm1, xmm2
	paddw	xmm1, xmm3
	pmullw	xmm2, xmm3
	paddw	xmm2, xmm0

	/* saturating and averaging arithmetic */
	paddsw	xmm4, xmm0
	paddusw	xmm5, xmm1
	psubsw	xmm6, xmm2
	psubusw	xmm7, xmm3

	/* widening multiply-add: 16->32 bit lanes */
	movdqa	xmm8, xmm0
	pmaddwd	xmm8, xmm1
	paddd	xmm3, xmm8

	/* high-half multiply */
	movdqa	xmm9, xmm0
	pmulhw	xmm9, xmm1
	pxor	xmm2, xmm9

	/* shifts and logic */
	movdqa	xmm10, xmm2
	pslld	xmm10, 3
	psrld	xmm2, 29
	por	xmm2, xmm10
	pand	xmm3, xmm4

	/* min/max */
	pmaxsw	xmm5, xmm0
	pminsw	xmm6, xmm1

	/* byte average and sum-of-absolute-differences */
	pavgb	xmm7, xmm4
	movdqa	xmm11, xmm0
	psadbw	xmm11, xmm5
	paddw	xmm4, xmm11

	/* lane shuffle: reverse the four 32-bit lanes */
	pshufd	xmm0, xmm0, 0x1B
	pxor	xmm1, xmm0

	/* single-precision float SIMD: multiply-add plus the reciprocal and
	 * rsqrt estimates that shader-style code leans on */
	movaps	xmm15, xmm12
	mulps	xmm15, xmm13
	addps	xmm14, xmm15
	rcpps	xmm8, xmm12
	rsqrtps	xmm9, xmm14
	addps	xmm14, xmm8
	mulps	xmm12, xmm9

	dec	rdi
	jnz	.Lsd_loop

	/* fold the eight integer vectors together */
	pxor	xmm0, xmm1
	pxor	xmm2, xmm3
	pxor	xmm4, xmm5
	pxor	xmm6, xmm7
	pxor	xmm0, xmm2
	pxor	xmm4, xmm6
	pxor	xmm0, xmm4

	/* fold in the float accumulator (truncate to int lanes) */
	cvttps2dq xmm14, xmm14
	pxor	xmm0, xmm14

	/* horizontal add of the four 32-bit lanes -> single checksum */
	pshufd	xmm1, xmm0, 0x4E
	paddd	xmm0, xmm1
	pshufd	xmm1, xmm0, 0xB1
	paddd	xmm0, xmm1
	movd	eax, xmm0
	ret

.Lsd_zero:
	xor	eax, eax
	ret
FN_END(fb_simd)


/* ===================================================================
 * uint64_t fb_compress(const uint8_t *src, uint64_t len, uint32_t *ht)
 *                                                [rdi, rsi, rdx]
 *
 * The match-finding inner loop of an LZ77 compressor (the LZ4 fast strategy):
 * hash the next 4 bytes, probe a single-entry-per-bucket table, verify, then
 * extend. Branch-heavy with a data-dependent, cache-missing table probe.
 *
 * ht must hold 1<<16 uint32_t (256 KiB); this routine clears it itself.
 * Returns the encoded size in bytes.
 * =================================================================== */
FN_BEGIN(fb_compress)
	push	rbp
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15

	mov	r12, rdi			/* src */
	mov	r13, rdx			/* ht  */

	/* clear the hash table: 1<<16 entries * 4 bytes = 262144 bytes */
	pxor	xmm0, xmm0
	xor	rax, rax
	mov	ecx, 262144
.Lcm_clear:
	movdqu	[r13 + rax], xmm0
	movdqu	[r13 + rax + 16], xmm0
	movdqu	[r13 + rax + 32], xmm0
	movdqu	[r13 + rax + 48], xmm0
	add	rax, 64
	cmp	rax, rcx
	jb	.Lcm_clear

	cmp	rsi, 16
	jb	.Lcm_tiny

	mov	r14, r12			/* ip     */
	mov	r15, r12			/* anchor */
	lea	rbx, [r12 + rsi]		/* end    */
	lea	r10, [rbx - 12]			/* mflimit = end - 12 */
	xor	ebp, ebp			/* outsize */

.Lcm_loop:
	cmp	r14, r10
	jae	.Lcm_flush

	mov	eax, [r14]			/* seq = load32(ip) */
	imul	eax, eax, 0x9E3779B1		/* * Knuth prime 2654435761 */
	shr	eax, 16				/* h = (seq*prime) >> 16 */

	mov	ecx, [r13 + rax*4]		/* ref_off = ht[h] */
	mov	rdx, r14
	sub	rdx, r12			/* cur_off = ip - src */
	mov	[r13 + rax*4], edx		/* ht[h] = cur_off */

	lea	rsi, [r12 + rcx]		/* ref = src + ref_off */
	cmp	rsi, r14
	jae	.Lcm_no_match			/* ref must be strictly behind ip */

	mov	rax, r14
	sub	rax, rsi			/* distance */
	cmp	rax, 65536
	jae	.Lcm_no_match			/* 16-bit offset window */

	mov	eax, [rsi]
	cmp	eax, [r14]			/* verify the 4-byte match */
	jne	.Lcm_no_match

	/* match confirmed: extend it byte by byte */
	mov	r9, 4				/* ml */
.Lcm_extend:
	lea	rax, [r14 + r9]
	cmp	rax, rbx			/* ip + ml vs end */
	jae	.Lcm_emit
	mov	cl, [r14 + r9]
	cmp	cl, [rsi + r9]
	jne	.Lcm_emit
	inc	r9
	jmp	.Lcm_extend

.Lcm_emit:
	/* token(1) + offset(2) + literals + varint extensions */
	mov	rax, r14
	sub	rax, r15			/* literal run length */
	add	rbp, rax
	add	rbp, 3
	cmp	rax, 15
	jb	.Lcm_no_lit_ext
	inc	rbp				/* literal-length extension byte */
.Lcm_no_lit_ext:
	cmp	r9, 19
	jb	.Lcm_no_ml_ext
	inc	rbp				/* match-length extension byte */
.Lcm_no_ml_ext:
	add	r14, r9				/* ip += ml */
	mov	r15, r14			/* anchor = ip */
	jmp	.Lcm_loop

.Lcm_no_match:
	inc	r14
	jmp	.Lcm_loop

.Lcm_flush:
	/* trailing literals */
	mov	rax, rbx
	sub	rax, r15			/* end - anchor */
	add	rbp, rax
	add	rbp, 1
	mov	rax, rbp
	jmp	.Lcm_ret

.Lcm_tiny:
	lea	rax, [rsi + 1]			/* len + 1 */

.Lcm_ret:
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	pop	rbp
	ret
FN_END(fb_compress)


/* ===================================================================
 * uint64_t fb_chacha20(uint8_t *buf, uint64_t len,
 *                      const uint8_t key[32], uint64_t rounds)
 *                                        [rdi, rsi, rdx, rcx]
 *
 * ChaCha20 stream cipher, SSE2, four 128-bit state rows. Chosen over AES for
 * the same reason the NEON file chose it: the AES-NI extension is optional, so
 * an AES-instruction benchmark would fault (#UD) on cores without it. ChaCha20
 * needs only baseline SSE2 and is a real, widely deployed cipher.
 *
 * len is rounded down to a multiple of 64. `rounds` = passes over the buffer.
 * Returns a checksum of the keystream output.
 * =================================================================== */

/* rotate each 32-bit lane left by n, via shift-left + shift-right + or */
#define ROL32(v, n)                    \
	movdqa	xmm14, v              ;\
	pslld	v, n                 ;\
	psrld	xmm14, (32 - (n))    ;\
	por	v, xmm14

/* one ChaCha quarter-round over rows a,b,c,d (xmm14 is scratch, via ROL32) */
#define QROUND(a, b, c, d)             \
	paddd	a, b                 ;\
	pxor	d, a                 ;\
	ROL32(d, 16)                 ;\
	paddd	c, d                 ;\
	pxor	b, c                 ;\
	ROL32(b, 12)                 ;\
	paddd	a, b                 ;\
	pxor	d, a                 ;\
	ROL32(d, 8)                  ;\
	paddd	c, d                 ;\
	pxor	b, c                 ;\
	ROL32(b, 7)

FN_BEGIN(fb_chacha20)
	and	rsi, -64			/* whole 64-byte blocks only */
	jz	.Lcc_zero
	test	rcx, rcx
	jz	.Lcc_zero

	/* xmm4..7 hold the base state */
	movdqa	xmm4, [rip + .Lcc_sigma]	/* "expand 32-byte k" */
	movdqu	xmm5, [rdx]			/* key[0..15]  */
	movdqu	xmm6, [rdx + 16]		/* key[16..31] */
	pxor	xmm7, xmm7			/* counter || nonce = 0 */

	pxor	xmm13, xmm13			/* running checksum */
	xor	r8, r8				/* block counter value */

.Lcc_pass:
	xor	r9, r9				/* byte offset into buf */

.Lcc_block:
	/* working state = base state, block counter in lane 0 of row 3.
	 * Row 3 is all-zero (nonce and counter), so a plain movd both sets
	 * the counter lane and clears the nonce lanes. */
	movdqa	xmm0, xmm4
	movdqa	xmm1, xmm5
	movdqa	xmm2, xmm6
	movd	xmm3, r8d

	/* keep originals for the final feed-forward add */
	movdqa	xmm8, xmm0
	movdqa	xmm9, xmm1
	movdqa	xmm10, xmm2
	movdqa	xmm11, xmm3

	mov	r10d, 10			/* 10 double rounds = 20 rounds */
.Lcc_rounds:
	/* column round */
	QROUND(xmm0, xmm1, xmm2, xmm3)

	/* rotate lanes to form the diagonals */
	pshufd	xmm1, xmm1, 0x39		/* <<< 1 lane */
	pshufd	xmm2, xmm2, 0x4E		/* <<< 2 lanes */
	pshufd	xmm3, xmm3, 0x93		/* <<< 3 lanes */

	/* diagonal round */
	QROUND(xmm0, xmm1, xmm2, xmm3)

	/* undo the lane rotation */
	pshufd	xmm1, xmm1, 0x93
	pshufd	xmm2, xmm2, 0x4E
	pshufd	xmm3, xmm3, 0x39

	dec	r10d
	jnz	.Lcc_rounds

	/* feed-forward: keystream = working + original */
	paddd	xmm0, xmm8
	paddd	xmm1, xmm9
	paddd	xmm2, xmm10
	paddd	xmm3, xmm11

	/* XOR the keystream into the buffer */
	lea	rax, [rdi + r9]
	movdqu	xmm12, [rax]
	pxor	xmm12, xmm0
	movdqu	[rax], xmm12
	movdqu	xmm12, [rax + 16]
	pxor	xmm12, xmm1
	movdqu	[rax + 16], xmm12
	movdqu	xmm12, [rax + 32]
	pxor	xmm12, xmm2
	movdqu	[rax + 32], xmm12
	movdqu	xmm12, [rax + 48]
	pxor	xmm12, xmm3
	movdqu	[rax + 48], xmm12

	/* accumulate a checksum of the keystream */
	pxor	xmm13, xmm0
	pxor	xmm13, xmm3

	inc	r8				/* counter++ */
	add	r9, 64
	cmp	r9, rsi
	jb	.Lcc_block

	dec	rcx
	jnz	.Lcc_pass

	/* horizontal add of the checksum lanes */
	pshufd	xmm0, xmm13, 0x4E
	paddd	xmm13, xmm0
	pshufd	xmm0, xmm13, 0xB1
	paddd	xmm13, xmm0
	movd	eax, xmm13
	ret

.Lcc_zero:
	xor	eax, eax
	ret
FN_END(fb_chacha20)

	.p2align 4
.Lcc_sigma:
	.long	0x61707865, 0x3320646e, 0x79622d32, 0x6b206574


/* ===================================================================
 * uint64_t fb_physics(double *bodies, uint64_t n, uint64_t steps)
 *                                                [rdi, rsi, rdx]
 *
 * Direct-summation N-body gravity, O(n^2) per step, double precision.
 * Layout per body, 8 doubles (64 bytes): [x y z mass vx vy vz pad].
 * The 1/sqrt is a real sqrtsd+divsd (not the rsqrt estimate), exercising the
 * divide/sqrt unit the way physics code does. Returns a velocity checksum.
 * =================================================================== */
FN_BEGIN(fb_physics)
	test	rsi, rsi
	jz	.Lph_zero
	test	rdx, rdx
	jz	.Lph_zero

	movsd	xmm13, [rip + .Lph_dt]		/* dt    */
	movsd	xmm14, [rip + .Lph_eps2]	/* eps^2 */
	movsd	xmm15, [rip + .Lph_one]		/* 1.0   */

.Lph_step:
	xor	r8, r8				/* i */

.Lph_body_i:
	mov	rax, r8
	shl	rax, 6				/* i * 64 */
	lea	r9, [rdi + rax]			/* &bodies[i] */

	movsd	xmm0, [r9]			/* xi */
	movsd	xmm1, [r9 + 8]			/* yi */
	movsd	xmm2, [r9 + 16]			/* zi */

	xorpd	xmm3, xmm3			/* ax */
	xorpd	xmm4, xmm4			/* ay */
	xorpd	xmm5, xmm5			/* az */

	xor	r10, r10			/* j */
	mov	r11, rdi			/* &bodies[j] */

.Lph_body_j:
	movsd	xmm6, [r11]			/* xj */
	movsd	xmm7, [r11 + 8]			/* yj */
	movsd	xmm8, [r11 + 16]		/* zj */
	movsd	xmm9, [r11 + 24]		/* mj */

	subsd	xmm6, xmm0			/* dx */
	subsd	xmm7, xmm1			/* dy */
	subsd	xmm8, xmm2			/* dz */

	/* r2 = dx*dx + dy*dy + dz*dz + eps^2 (>= eps^2, so the i==j self-term
	 * is finite and contributes exactly 0 below) */
	movsd	xmm10, xmm6
	mulsd	xmm10, xmm6
	movsd	xmm11, xmm7
	mulsd	xmm11, xmm7
	addsd	xmm10, xmm11
	movsd	xmm11, xmm8
	mulsd	xmm11, xmm8
	addsd	xmm10, xmm11
	addsd	xmm10, xmm14			/* + eps^2 */

	sqrtsd	xmm10, xmm10			/* r     */
	movsd	xmm11, xmm15
	divsd	xmm11, xmm10			/* 1/r   */
	movsd	xmm12, xmm11
	mulsd	xmm12, xmm11			/* 1/r^2 */
	mulsd	xmm12, xmm11			/* 1/r^3 */
	mulsd	xmm12, xmm9			/* m/r^3 */

	mulsd	xmm6, xmm12			/* dx * m/r^3 */
	addsd	xmm3, xmm6
	mulsd	xmm7, xmm12
	addsd	xmm4, xmm7
	mulsd	xmm8, xmm12
	addsd	xmm5, xmm8

	add	r11, 64
	inc	r10
	cmp	r10, rsi
	jb	.Lph_body_j

	/* v += a * dt */
	movsd	xmm6, [r9 + 32]			/* vx */
	movsd	xmm7, [r9 + 40]			/* vy */
	movsd	xmm8, [r9 + 48]			/* vz */
	mulsd	xmm3, xmm13
	addsd	xmm6, xmm3
	mulsd	xmm4, xmm13
	addsd	xmm7, xmm4
	mulsd	xmm5, xmm13
	addsd	xmm8, xmm5
	movsd	[r9 + 32], xmm6
	movsd	[r9 + 40], xmm7
	movsd	[r9 + 48], xmm8

	inc	r8
	cmp	r8, rsi
	jb	.Lph_body_i

	/* second pass: x += v * dt (positions move only after all forces) */
	xor	r8, r8
	mov	r11, rdi
.Lph_integrate:
	movsd	xmm0, [r11]
	movsd	xmm1, [r11 + 8]
	movsd	xmm2, [r11 + 16]
	movsd	xmm6, [r11 + 32]
	movsd	xmm7, [r11 + 40]
	movsd	xmm8, [r11 + 48]
	mulsd	xmm6, xmm13
	addsd	xmm0, xmm6
	mulsd	xmm7, xmm13
	addsd	xmm1, xmm7
	mulsd	xmm8, xmm13
	addsd	xmm2, xmm8
	movsd	[r11], xmm0
	movsd	[r11 + 8], xmm1
	movsd	[r11 + 16], xmm2
	add	r11, 64
	inc	r8
	cmp	r8, rsi
	jb	.Lph_integrate

	dec	rdx
	jnz	.Lph_step

	/* checksum: sum of all velocity components */
	xorpd	xmm0, xmm0
	xor	r8, r8
	mov	r11, rdi
.Lph_sum:
	movsd	xmm6, [r11 + 32]
	movsd	xmm7, [r11 + 40]
	movsd	xmm8, [r11 + 48]
	addsd	xmm0, xmm6
	addsd	xmm0, xmm7
	addsd	xmm0, xmm8
	add	r11, 64
	inc	r8
	cmp	r8, rsi
	jb	.Lph_sum

	movq	rax, xmm0
	ret

.Lph_zero:
	xor	eax, eax
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
 * uint64_t fb_sort(uint32_t *a, uint64_t n)     [rdi = a, rsi = n]
 *
 * In-place heapsort: no recursion or explicit stack, aggressively
 * branch-unpredictable, with scattered memory access - it stresses the branch
 * predictor and the cache hierarchy. Returns an order-sensitive checksum,
 * which also verifies the sort.
 *
 * Uses only caller-saved registers, so no prologue is needed; the internal
 * siftdown is reached with `call` (contract below).
 * =================================================================== */
FN_BEGIN(fb_sort)
	cmp	rsi, 2
	jb	.Lst_trivial

	/* ---- build the max-heap: for i = n/2 - 1 down to 0 ---- */
	mov	r8, rsi
	shr	r8, 1				/* i = n/2 */
.Lst_build:
	test	r8, r8
	jz	.Lst_extract
	dec	r8				/* i-- */
	mov	rcx, r8				/* root */
	mov	rdx, rsi			/* end  */
	call	.Lst_siftdown
	test	r8, r8
	jnz	.Lst_build

	/* ---- extract: for end = n-1 down to 1 ---- */
.Lst_extract:
	mov	r9, rsi
	dec	r9				/* end = n-1 */
.Lst_extract_loop:
	test	r9, r9
	jz	.Lst_checksum

	/* swap a[0] and a[end] */
	mov	eax, [rdi]
	mov	r10d, [rdi + r9*4]
	mov	[rdi], r10d
	mov	[rdi + r9*4], eax

	xor	ecx, ecx			/* root = 0  */
	mov	rdx, r9				/* end = end */
	call	.Lst_siftdown

	dec	r9
	jmp	.Lst_extract_loop

	/* ---- order-sensitive checksum ---- */
.Lst_checksum:
	xor	eax, eax
	xor	rcx, rcx			/* index */
.Lst_cksum_loop:
	mov	r10d, [rdi + rcx*4]
	xor	rax, r10
	ror	rax, 7
	add	rax, r10
	inc	rcx
	cmp	rcx, rsi
	jb	.Lst_cksum_loop
	ret

.Lst_trivial:
	xor	eax, eax
	test	rsi, rsi
	jz	.Lst_trivial_ret
	mov	eax, [rdi]
.Lst_trivial_ret:
	ret

	/* ---- local helper: siftdown(root = rcx, end = rdx)
	 * base a = rdi; clobbers rax, rcx, r10, r11 only. r8 (build i),
	 * r9 (extract end), rsi (n), rdx (end) all survive. ---- */
.Lst_siftdown:
	mov	r11, rcx			/* root */
.Lst_sift_loop:
	lea	r10, [r11 + r11 + 1]		/* child = 2*root + 1 */
	cmp	r10, rdx
	jae	.Lst_sift_done			/* no children */

	lea	rax, [r10 + 1]			/* right = child + 1 */
	cmp	rax, rdx
	jae	.Lst_sift_have_child		/* no right child */
	mov	ecx, [rdi + rax*4]		/* a[right] */
	cmp	ecx, [rdi + r10*4]		/* a[right] vs a[child] */
	jbe	.Lst_sift_have_child		/* keep child if a[right] <= it */
	mov	r10, rax			/* else child = right */

.Lst_sift_have_child:
	mov	eax, [rdi + r11*4]		/* a[root]  */
	mov	ecx, [rdi + r10*4]		/* a[child] */
	cmp	eax, ecx
	jae	.Lst_sift_done			/* heap property holds */

	/* swap and descend */
	mov	[rdi + r11*4], ecx
	mov	[rdi + r10*4], eax
	mov	r11, r10
	jmp	.Lst_sift_loop

.Lst_sift_done:
	ret
FN_END(fb_sort)


/* ===================================================================
 * uint64_t fb_chase(void **ptrs, uint64_t steps) [rdi = ptrs, rsi = steps]
 *
 * Pointer chase around a randomised cycle. Every load depends on the previous
 * one, so nothing can be prefetched, overlapped or reordered - this measures
 * the pure serial latency of the memory hierarchy. The truest single-threaded
 * test in the suite.
 * =================================================================== */
FN_BEGIN(fb_chase)
	test	rsi, rsi
	jz	.Lch_zero
	mov	rax, rdi			/* p = ptrs */
	mov	rcx, rsi

.Lch_loop:
	mov	rax, [rax]
	dec	rcx
	jnz	.Lch_loop

	sub	rax, rdi			/* final offset, keeps p live */
	ret

.Lch_zero:
	xor	eax, eax
	ret
FN_END(fb_chase)


#if defined(__ELF__)
	.section	.note.GNU-stack, "", @progbits
#endif
