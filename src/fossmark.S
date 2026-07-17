/*
 * fossmark.S - AArch64 CPU benchmark kernels
 *
 * OS-independent: contains no syscalls, no libc calls, no relocations against
 * external data. Every routine is a pure function of its arguments under the
 * AAPCS64 procedure call standard, so this source assembles and runs correctly
 * on Linux (ELF), macOS (Mach-O), Windows (COFF), and the BSDs.
 *
 * x18 is never used: it is the platform register on Darwin and Windows.
 * v8-v15 are never used: only their low 64 bits are callee-saved, which makes
 * them a trap for 128-bit vector code.
 */

	.arch	armv8-a

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
	.type	\name, %function
#endif
\name:
	.endm

	.macro	FN_END_ASM name
#if defined(__ELF__)
	.size	\name, . - \name
#endif
	.endm

/* Materialise a 64-bit constant without a literal pool, so no relocations and
 * no .ltorg placement worries across object formats. */
#define MOV64(reg, val) MOV64_ASM reg, val

	.macro	MOV64_ASM reg, val
	movz	\reg, #((\val) & 0xffff)
	movk	\reg, #(((\val) >> 16) & 0xffff), lsl #16
	movk	\reg, #(((\val) >> 32) & 0xffff), lsl #32
	movk	\reg, #(((\val) >> 48) & 0xffff), lsl #48
	.endm

	.text

/* ===================================================================
 * uint64_t fm_int_math(uint64_t iters)
 *
 * Four largely independent accumulator chains to expose instruction-level
 * parallelism, mixed with high-latency serialising ops (udiv/sdiv) and the
 * bit-manipulation instructions. Returns a checksum so the compiler and the
 * driver cannot elide the work.
 * =================================================================== */
FN_BEGIN(fm_int_math)
	cbz	x0, .Lim_zero

	MOV64(x1, 0x9E3779B97F4A7C15)		/* a */
	MOV64(x2, 0xBF58476D1CE4E5B9)		/* b */
	MOV64(x3, 0x94D049BB133111EB)		/* c */
	MOV64(x4, 0x2545F4914F6CDD1D)		/* d */
	MOV64(x5, 0x00000000DEADBEEF)		/* odd multiplier, never zero */
	mov	x6, x0				/* trip count */

.Lim_loop:
	/* four independent multiply-accumulate chains */
	madd	x1, x1, x5, x2
	madd	x2, x2, x5, x3
	madd	x3, x3, x5, x4
	madd	x4, x4, x5, x1

	/* cross-mix with shifts and logic ops (free shifter operands) */
	eor	x1, x1, x3, lsr #29
	eor	x2, x2, x4, lsl #17
	eor	x3, x3, x1, ror #31
	bic	x4, x4, x2, asr #7

	/* wide multiplies: umulh/smulh are the long-latency multiplier path */
	umulh	x9, x1, x3
	smulh	x10, x2, x4
	add	x1, x1, x9
	add	x2, x2, x10

	/* bit manipulation */
	rbit	x11, x1
	clz	x12, x2
	rev	x13, x3
	eor	x4, x4, x11
	add	x4, x4, x12
	eor	x1, x1, x13

	/* division: fully serialising, ~10-20 cycle latency, not pipelined */
	orr	x14, x5, #1			/* guarantee a non-zero divisor */
	udiv	x15, x1, x14
	sdiv	x16, x2, x14
	msub	x3, x15, x14, x3
	add	x4, x4, x16

	/* bitfield ops */
	ror	x2, x2, #11
	extr	x1, x1, x2, #23

	subs	x6, x6, #1
	b.ne	.Lim_loop

	eor	x0, x1, x2
	eor	x0, x0, x3
	eor	x0, x0, x4
	ret

.Lim_zero:
	mov	x0, xzr
	ret
FN_END(fm_int_math)


/* ===================================================================
 * uint64_t fm_fp_math(uint64_t iters)
 *
 * Double-precision scalar FP. Four fmadd chains cover the pipelined
 * multiply-add path; fdiv and fsqrt cover the non-pipelined divide/sqrt unit,
 * which is usually the real differentiator between cores.
 * Returns the result bit-cast to u64.
 * =================================================================== */
FN_BEGIN(fm_fp_math)
	cbz	x0, .Lfp_zero
	mov	x6, x0

	/* Constants come from a table rather than fmov immediates: the AArch64
	 * 8-bit FP immediate can only encode a narrow set of values, and
	 * several of the ones we want fall outside it. */
	adr	x7, .Lfp_consts
	ldp	d0, d1, [x7]				/* a = 1.5,  b = 2.5      */
	ldp	d2, d3, [x7, #16]			/* c = 3.5,  d = 0.5      */
	ldp	d4, d5, [x7, #32]			/* mul,      small addend */
	ldp	d6, d7, [x7, #48]			/* 2.0,      1.0          */

.Lfp_loop:
	/* four independent fused multiply-add chains */
	fmadd	d0, d0, d4, d5
	fmadd	d1, d1, d4, d5
	fmadd	d2, d2, d4, d5
	fmadd	d3, d3, d4, d5

	/* keep the accumulators bounded so they never reach inf/NaN */
	fmin	d0, d0, d6
	fmin	d1, d1, d6
	fmin	d2, d2, d6
	fmin	d3, d3, d6

	/* square root: long latency, low throughput */
	fsqrt	d16, d0
	fsqrt	d17, d1
	fadd	d2, d2, d16
	fadd	d3, d3, d17

	/* divide: the other long-latency unit */
	fadd	d18, d2, d7				/* divisor >= 1, never zero */
	fdiv	d19, d7, d18
	fadd	d0, d0, d19

	fadd	d20, d3, d7
	fdiv	d21, d7, d20
	fadd	d1, d1, d21

	/* abs/neg/compare-select: cheap ops to balance the mix */
	fabs	d2, d2
	fneg	d22, d3
	fabs	d3, d22
	fmax	d3, d3, d7

	subs	x6, x6, #1
	b.ne	.Lfp_loop

	fadd	d0, d0, d1
	fadd	d2, d2, d3
	fadd	d0, d0, d2
	fmov	x0, d0
	ret

.Lfp_zero:
	mov	x0, xzr
	ret
FN_END(fm_fp_math)

	.p2align 4
.Lfp_consts:
	.double	1.5, 2.5
	.double	3.5, 0.5
	.double	1.0625, 0.0009765625
	.double	2.0, 1.0


/* ===================================================================
 * uint64_t fm_primes(uint64_t limit, uint8_t *sieve)
 *
 * Sieve of Eratosthenes over [0, limit). The caller supplies `limit` bytes of
 * scratch; this routine clears it itself, so the clearing pass is part of the
 * measured work (as it would be in any real use). Returns the prime count.
 *
 * Strided stores over a buffer larger than L1 make this a memory-hierarchy
 * test as much as an arithmetic one.
 * =================================================================== */
FN_BEGIN(fm_primes)
	cmp	x0, #2
	b.lo	.Lpr_none

	mov	x2, x1				/* sieve base */
	mov	x3, x0				/* limit */

	/* zero the sieve, 32 bytes per iteration */
	movi	v0.16b, #0
	mov	x4, xzr
	and	x5, x3, #~31			/* bulk portion */
.Lpr_clear32:
	cmp	x4, x5
	b.hs	.Lpr_clear1
	add	x6, x2, x4
	stp	q0, q0, [x6]
	add	x4, x4, #32
	b	.Lpr_clear32
.Lpr_clear1:
	cmp	x4, x3
	b.hs	.Lpr_clear_done
	strb	wzr, [x2, x4]
	add	x4, x4, #1
	b	.Lpr_clear1
.Lpr_clear_done:

	/* mark 0 and 1 as composite */
	mov	w6, #1
	strb	w6, [x2]
	strb	w6, [x2, #1]

	/* outer loop: i = 2; i*i < limit; i++ */
	mov	x7, #2
.Lpr_outer:
	mul	x9, x7, x7
	cmp	x9, x3
	b.hs	.Lpr_count

	ldrb	w10, [x2, x7]
	cbnz	w10, .Lpr_outer_next		/* already composite, skip */

	/* inner loop: mark multiples starting at i*i, stride i */
	mov	x11, x9
.Lpr_inner:
	cmp	x11, x3
	b.hs	.Lpr_outer_next
	strb	w6, [x2, x11]
	add	x11, x11, x7
	b	.Lpr_inner

.Lpr_outer_next:
	add	x7, x7, #1
	b	.Lpr_outer

	/* count the survivors */
.Lpr_count:
	mov	x0, xzr				/* count */
	mov	x4, #2
.Lpr_count_loop:
	cmp	x4, x3
	b.hs	.Lpr_done
	ldrb	w10, [x2, x4]
	cmp	w10, #0
	cinc	x0, x0, eq
	add	x4, x4, #1
	b	.Lpr_count_loop

.Lpr_done:
	ret

.Lpr_none:
	mov	x0, xzr
	ret
FN_END(fm_primes)


/* ===================================================================
 * uint64_t fm_simd(uint64_t iters, void *buf)
 *
 * "Extended instructions": the ASIMD/NEON unit, which is architecturally
 * mandatory on AArch64 and therefore safe to use without runtime feature
 * detection. (AES, SHA and DotProd are all *optional* extensions; using them
 * unguarded would fault on cores that lack them, so they are deliberately
 * avoided here.)
 *
 * buf must be at least 128 bytes and 16-byte aligned. Returns a checksum.
 * =================================================================== */
FN_BEGIN(fm_simd)
	cbz	x0, .Lsd_zero
	mov	x6, x0

	/* seed eight vectors from the scratch buffer */
	ldp	q0, q1, [x1]
	ldp	q2, q3, [x1, #32]
	ldp	q4, q5, [x1, #64]
	ldp	q6, q7, [x1, #96]

	movi	v28.4s, #3
	movi	v29.4s, #7
	movi	v30.16b, #0x5A

	/* byte-permute table for tbl: reverses the 16 byte lanes */
	adr	x9, .Lsd_perm
	ldr	q31, [x9]

	/* float accumulator and operands: derived from the integer seeds by
	 * conversion, so the FP pipeline sees real finite values rather than
	 * reinterpreted integer bit patterns (which would be NaNs/denormals
	 * and would measure the slow path, not the common one). */
	movi	v22.4s, #0
	scvtf	v26.4s, v0.4s
	scvtf	v27.4s, v1.4s

.Lsd_loop:
	/* integer SIMD: multiply-accumulate across four independent vectors */
	mla	v0.4s, v1.4s, v28.4s
	mla	v1.4s, v2.4s, v29.4s
	mla	v2.4s, v3.4s, v28.4s
	mla	v3.4s, v0.4s, v29.4s

	/* saturating and halving arithmetic */
	sqadd	v4.4s, v4.4s, v0.4s
	uhadd	v5.4s, v5.4s, v1.4s
	srhadd	v6.4s, v6.4s, v2.4s
	sqsub	v7.4s, v7.4s, v3.4s

	/* widening ops: 16->32 bit lane expansion */
	umull	v16.4s, v0.4h, v1.4h
	umull2	v17.4s, v0.8h, v1.8h
	saddw	v2.4s, v2.4s, v16.4h
	ssubw2	v3.4s, v3.4s, v17.8h

	/* pairwise reduction */
	uaddlp	v18.2d, v4.4s
	addp	v19.4s, v5.4s, v6.4s
	add	v4.4s, v4.4s, v19.4s

	/* table lookup: the byte-permute network */
	tbl	v20.16b, {v0.16b}, v31.16b
	eor	v1.16b, v1.16b, v20.16b

	/* shifts, logic, min/max, reverse */
	shl	v21.4s, v2.4s, #3
	usra	v21.4s, v2.4s, #29
	orr	v2.16b, v2.16b, v21.16b
	bic	v3.16b, v3.16b, v30.16b
	umax	v5.4s, v5.4s, v0.4s
	umin	v6.4s, v6.4s, v1.4s
	rev32	v7.16b, v7.16b

	/* single-precision float SIMD: 4-wide fmla, plus the reciprocal and
	 * rsqrt estimate instructions that shader-style code leans on */
	/* v16/v17 are dead after the widening ops above, so they are reused
	 * here as scratch rather than touching the callee-saved v8-v15 bank. */
	fmla	v22.4s, v26.4s, v27.4s
	frecpe	v23.4s, v26.4s
	frsqrte	v16.4s, v22.4s
	fadd	v22.4s, v22.4s, v23.4s
	fmul	v26.4s, v26.4s, v16.4s

	/* population count and leading-zero count */
	cnt	v24.16b, v0.16b
	uaddlv	h25, v24.8b
	clz	v17.4s, v1.4s
	add	v0.4s, v0.4s, v17.4s

	/* fold the reduction results back in so nothing is dead code */
	add	v4.2d, v4.2d, v18.2d

	subs	x6, x6, #1
	b.ne	.Lsd_loop

	/* horizontal fold to a single 64-bit checksum */
	eor	v0.16b, v0.16b, v1.16b
	eor	v2.16b, v2.16b, v3.16b
	eor	v4.16b, v4.16b, v5.16b
	eor	v6.16b, v6.16b, v7.16b
	eor	v0.16b, v0.16b, v2.16b
	eor	v4.16b, v4.16b, v6.16b
	eor	v0.16b, v0.16b, v4.16b
	addv	s0, v0.4s
	fmov	w0, s0
	ret

.Lsd_zero:
	mov	x0, xzr
	ret
FN_END(fm_simd)

	.p2align 4
.Lsd_perm:
	.byte	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0


/* ===================================================================
 * uint64_t fm_compress(const uint8_t *src, uint64_t len, uint32_t *ht)
 *
 * The match-finding inner loop of an LZ77 compressor (the LZ4 fast strategy):
 * hash the next 4 bytes, probe a single-entry-per-bucket table, verify, then
 * extend the match. This is where real compressors spend their time - it is
 * branch-heavy with a data-dependent, cache-missing table probe.
 *
 * ht must hold 1<<16 uint32_t (256 KiB); this routine clears it itself.
 * Returns the encoded size in bytes.
 * =================================================================== */
FN_BEGIN(fm_compress)
	stp	x29, x30, [sp, #-96]!
	mov	x29, sp
	stp	x19, x20, [sp, #16]
	stp	x21, x22, [sp, #32]
	stp	x23, x24, [sp, #48]
	stp	x25, x26, [sp, #64]
	stp	x27, x28, [sp, #80]

	mov	x19, x0				/* src */
	mov	x20, x1				/* len */
	mov	x21, x2				/* ht */

	/* clear the hash table: 1<<16 entries * 4 bytes = 262144 bytes */
	movi	v0.16b, #0
	mov	x9, xzr
	MOV64(x10, 262144)
.Lcm_clear:
	add	x11, x21, x9
	stp	q0, q0, [x11]
	stp	q0, q0, [x11, #32]
	add	x9, x9, #64
	cmp	x9, x10
	b.lo	.Lcm_clear

	cmp	x20, #16
	b.lo	.Lcm_tiny

	mov	x22, x19			/* ip     */
	mov	x23, x19			/* anchor */
	add	x24, x19, x20			/* end    */
	sub	x25, x24, #12			/* mflimit */
	mov	x26, xzr			/* outsize */

	MOV64(x27, 2654435761)			/* Knuth multiplicative hash */

.Lcm_loop:
	cmp	x22, x25
	b.hs	.Lcm_flush

	ldr	w9, [x22]			/* seq = load32(ip) */
	mul	w10, w9, w27
	lsr	w10, w10, #16			/* h = (seq * prime) >> 16 */

	ldr	w11, [x21, x10, lsl #2]		/* ref_off = ht[h] */
	sub	x12, x22, x19			/* cur_off = ip - src */
	str	w12, [x21, x10, lsl #2]		/* ht[h] = cur_off */

	add	x13, x19, x11			/* ref = src + ref_off */
	cmp	x13, x22
	b.hs	.Lcm_no_match			/* ref must be strictly behind ip */

	sub	x14, x22, x13			/* distance */
	MOV64(x15, 65536)
	cmp	x14, x15
	b.hs	.Lcm_no_match			/* 16-bit offset window */

	ldr	w16, [x13]
	cmp	w16, w9
	b.ne	.Lcm_no_match

	/* match confirmed: extend it byte by byte */
	mov	x28, #4				/* ml */
.Lcm_extend:
	add	x9, x22, x28
	cmp	x9, x24
	b.hs	.Lcm_emit
	ldrb	w10, [x22, x28]
	ldrb	w11, [x13, x28]
	cmp	w10, w11
	b.ne	.Lcm_emit
	add	x28, x28, #1
	b	.Lcm_extend

.Lcm_emit:
	/* token(1) + offset(2) + literals + varint extensions */
	sub	x9, x22, x23			/* literal run length */
	add	x26, x26, x9
	add	x26, x26, #3
	cmp	x9, #15
	cinc	x26, x26, hs			/* literal-length extension byte */
	cmp	x28, #19
	cinc	x26, x26, hs			/* match-length extension byte */

	add	x22, x22, x28
	mov	x23, x22
	b	.Lcm_loop

.Lcm_no_match:
	add	x22, x22, #1
	b	.Lcm_loop

.Lcm_flush:
	/* trailing literals */
	sub	x9, x24, x23
	add	x26, x26, x9
	add	x26, x26, #1
	mov	x0, x26
	b	.Lcm_ret

.Lcm_tiny:
	add	x0, x20, #1

.Lcm_ret:
	ldp	x27, x28, [sp, #80]
	ldp	x25, x26, [sp, #64]
	ldp	x23, x24, [sp, #48]
	ldp	x21, x22, [sp, #32]
	ldp	x19, x20, [sp, #16]
	ldp	x29, x30, [sp], #96
	ret
FN_END(fm_compress)


/* ===================================================================
 * uint64_t fm_chacha20(uint8_t *buf, uint64_t len, const uint8_t key[32],
 *                      uint64_t rounds)
 *
 * ChaCha20 stream cipher, NEON, four 128-bit state rows. Chosen over AES
 * deliberately: the ARMv8 AES extension is optional, so an AES-instruction
 * benchmark would fault on cores without it. ChaCha20 needs only baseline
 * ASIMD and is a real, widely deployed cipher (TLS, WireGuard, SSH).
 *
 * len is rounded down to a multiple of 64. `rounds` = number of passes over
 * the buffer. Returns a checksum of the keystream output.
 * =================================================================== */

/* rotate each 32-bit lane left by n, via shl + shift-right-and-insert */
#define VROTL(vd, vs, vt, n) VROTL_ASM vd, vs, vt, n

	.macro	VROTL_ASM vd, vs, vt, n
	shl	\vt\().4s, \vs\().4s, #(\n)
	sri	\vt\().4s, \vs\().4s, #(32 - (\n))
	mov	\vd\().16b, \vt\().16b
	.endm

/* one ChaCha quarter-round over rows a,b,c,d using v24 as scratch */
#define QROUND(a, b, c, d) QROUND_ASM a, b, c, d

	.macro	QROUND_ASM a, b, c, d
	add	\a\().4s, \a\().4s, \b\().4s
	eor	\d\().16b, \d\().16b, \a\().16b
	rev32	\d\().8h, \d\().8h
	add	\c\().4s, \c\().4s, \d\().4s
	eor	\b\().16b, \b\().16b, \c\().16b
	VROTL_ASM \b, \b, v24, 12
	add	\a\().4s, \a\().4s, \b\().4s
	eor	\d\().16b, \d\().16b, \a\().16b
	VROTL_ASM \d, \d, v24, 8
	add	\c\().4s, \c\().4s, \d\().4s
	eor	\b\().16b, \b\().16b, \c\().16b
	VROTL_ASM \b, \b, v24, 7
	.endm

FN_BEGIN(fm_chacha20)
	and	x1, x1, #~63			/* whole 64-byte blocks only */
	cbz	x1, .Lcc_zero
	cbz	x3, .Lcc_zero

	stp	x29, x30, [sp, #-32]!
	mov	x29, sp
	stp	x19, x20, [sp, #16]

	mov	x19, x0				/* buf  */
	mov	x20, x1				/* len  */

	/* v4..v7 hold the base state */
	adr	x9, .Lcc_sigma
	ldr	q4, [x9]			/* "expand 32-byte k" */
	ldp	q5, q6, [x2]			/* key[0..31] */
	movi	v7.4s, #0			/* counter || nonce */

	movi	v25.16b, #0			/* running checksum */
	mov	x10, xzr			/* counter value */

.Lcc_pass:
	mov	x11, xzr			/* byte offset into buf */

.Lcc_block:
	/* working state = base state, with the block counter in lane 0 of v7 */
	mov	v0.16b, v4.16b
	mov	v1.16b, v5.16b
	mov	v2.16b, v6.16b
	mov	v3.16b, v7.16b
	mov	v3.s[0], w10

	/* keep originals for the final feed-forward add */
	mov	v16.16b, v0.16b
	mov	v17.16b, v1.16b
	mov	v18.16b, v2.16b
	mov	v19.16b, v3.16b

	mov	w12, #10			/* 10 double rounds = 20 rounds */
.Lcc_rounds:
	/* column round */
	QROUND(v0, v1, v2, v3)

	/* rotate lanes to form the diagonals */
	ext	v1.16b, v1.16b, v1.16b, #4
	ext	v2.16b, v2.16b, v2.16b, #8
	ext	v3.16b, v3.16b, v3.16b, #12

	/* diagonal round */
	QROUND(v0, v1, v2, v3)

	/* undo the lane rotation */
	ext	v1.16b, v1.16b, v1.16b, #12
	ext	v2.16b, v2.16b, v2.16b, #8
	ext	v3.16b, v3.16b, v3.16b, #4

	subs	w12, w12, #1
	b.ne	.Lcc_rounds

	/* feed-forward: keystream = working + original */
	add	v0.4s, v0.4s, v16.4s
	add	v1.4s, v1.4s, v17.4s
	add	v2.4s, v2.4s, v18.4s
	add	v3.4s, v3.4s, v19.4s

	/* XOR the keystream into the buffer */
	add	x13, x19, x11
	ldp	q20, q21, [x13]
	ldp	q22, q23, [x13, #32]
	eor	v20.16b, v20.16b, v0.16b
	eor	v21.16b, v21.16b, v1.16b
	eor	v22.16b, v22.16b, v2.16b
	eor	v23.16b, v23.16b, v3.16b
	stp	q20, q21, [x13]
	stp	q22, q23, [x13, #32]

	/* accumulate a checksum of the keystream */
	eor	v25.16b, v25.16b, v0.16b
	eor	v25.16b, v25.16b, v3.16b

	add	x10, x10, #1
	add	x11, x11, #64
	cmp	x11, x20
	b.lo	.Lcc_block

	subs	x3, x3, #1
	b.ne	.Lcc_pass

	addv	s25, v25.4s
	fmov	w0, s25

	ldp	x19, x20, [sp, #16]
	ldp	x29, x30, [sp], #32
	ret

.Lcc_zero:
	mov	x0, xzr
	ret
FN_END(fm_chacha20)

	.p2align 4
.Lcc_sigma:
	.word	0x61707865, 0x3320646e, 0x79622d32, 0x6b206574


/* ===================================================================
 * uint64_t fm_physics(double *bodies, uint64_t n, uint64_t steps)
 *
 * Direct-summation N-body gravity, O(n^2) per step, double precision.
 * Layout per body, 8 doubles (64 bytes, one cache line):
 *   [0]=x [1]=y [2]=z [3]=mass [4]=vx [5]=vy [6]=vz [7]=pad
 *
 * The 1/sqrt is done with a real fsqrt+fdiv rather than the frsqrte estimate,
 * so this exercises the divide/sqrt unit the way physics code actually does.
 * Returns a checksum bit-cast from the final velocity sum.
 * =================================================================== */
FN_BEGIN(fm_physics)
	cbz	x1, .Lph_zero
	cbz	x2, .Lph_zero

	stp	x29, x30, [sp, #-64]!
	mov	x29, sp
	stp	x19, x20, [sp, #16]
	stp	x21, x22, [sp, #32]
	stp	x23, x24, [sp, #48]

	mov	x19, x0				/* bodies */
	mov	x20, x1				/* n      */
	mov	x21, x2				/* steps  */

	adr	x9, .Lph_consts
	ldp	d28, d29, [x9]			/* dt, eps^2 */
	ldr	d30, [x9, #16]			/* 1.0       */

.Lph_step:
	mov	x22, xzr			/* i */

.Lph_body_i:
	lsl	x9, x22, #6			/* i * 64 */
	add	x23, x19, x9			/* &bodies[i] */

	ldp	d0, d1, [x23]			/* xi, yi */
	ldr	d2, [x23, #16]			/* zi     */

	movi	d16, #0				/* ax */
	movi	d17, #0				/* ay */
	movi	d18, #0				/* az */

	mov	x24, xzr			/* j */
	mov	x10, x19			/* &bodies[j] */

.Lph_body_j:
	ldp	d3, d4, [x10]			/* xj, yj */
	ldp	d5, d6, [x10, #16]		/* zj, mj */

	fsub	d3, d3, d0			/* dx */
	fsub	d4, d4, d1			/* dy */
	fsub	d5, d5, d2			/* dz */

	/* d2 = dx*dx + dy*dy + dz*dz + eps^2  (always >= eps^2, never zero,
	 * so the i==j self-term is finite and contributes exactly 0 below) */
	fmul	d7, d3, d3
	fmadd	d7, d4, d4, d7
	fmadd	d7, d5, d5, d7
	fadd	d7, d7, d29

	fsqrt	d19, d7				/* r      */
	fdiv	d20, d30, d19			/* 1/r    */
	fmul	d21, d20, d20			/* 1/r^2  */
	fmul	d21, d21, d20			/* 1/r^3  */
	fmul	d21, d21, d6			/* m/r^3  */

	fmadd	d16, d3, d21, d16		/* ax += dx * m/r^3 */
	fmadd	d17, d4, d21, d17
	fmadd	d18, d5, d21, d18

	add	x10, x10, #64
	add	x24, x24, #1
	cmp	x24, x20
	b.lo	.Lph_body_j

	/* v += a * dt */
	ldp	d22, d23, [x23, #32]
	ldr	d24, [x23, #48]
	fmadd	d22, d16, d28, d22
	fmadd	d23, d17, d28, d23
	fmadd	d24, d18, d28, d24
	stp	d22, d23, [x23, #32]
	str	d24, [x23, #48]

	add	x22, x22, #1
	cmp	x22, x20
	b.lo	.Lph_body_i

	/* second pass: x += v * dt (positions updated only after all forces) */
	mov	x22, xzr
	mov	x10, x19
.Lph_integrate:
	ldp	d0, d1, [x10]
	ldr	d2, [x10, #16]
	ldp	d22, d23, [x10, #32]
	ldr	d24, [x10, #48]
	fmadd	d0, d22, d28, d0
	fmadd	d1, d23, d28, d1
	fmadd	d2, d24, d28, d2
	stp	d0, d1, [x10]
	str	d2, [x10, #16]
	add	x10, x10, #64
	add	x22, x22, #1
	cmp	x22, x20
	b.lo	.Lph_integrate

	subs	x21, x21, #1
	b.ne	.Lph_step

	/* checksum: sum of all velocity components */
	movi	d0, #0
	mov	x22, xzr
	mov	x10, x19
.Lph_sum:
	ldp	d22, d23, [x10, #32]
	ldr	d24, [x10, #48]
	fadd	d0, d0, d22
	fadd	d0, d0, d23
	fadd	d0, d0, d24
	add	x10, x10, #64
	add	x22, x22, #1
	cmp	x22, x20
	b.lo	.Lph_sum

	fmov	x0, d0

	ldp	x23, x24, [sp, #48]
	ldp	x21, x22, [sp, #32]
	ldp	x19, x20, [sp, #16]
	ldp	x29, x30, [sp], #64
	ret

.Lph_zero:
	mov	x0, xzr
	ret
FN_END(fm_physics)

	.p2align 4
.Lph_consts:
	.double	0.0078125			/* dt    */
	.double	0.0625				/* eps^2 */
	.double	1.0


/* ===================================================================
 * uint64_t fm_sort(uint32_t *a, uint64_t n)
 *
 * In-place heapsort. Chosen over quicksort because it needs no recursion or
 * explicit stack, yet is aggressively branch-unpredictable and touches memory
 * in a scattered pattern - it stresses the branch predictor and the cache
 * hierarchy, which is what a sort benchmark should measure.
 *
 * Returns an order-sensitive checksum, which also verifies the sort.
 * =================================================================== */
FN_BEGIN(fm_sort)
	cmp	x1, #2
	b.lo	.Lst_trivial

	stp	x29, x30, [sp, #-48]!
	mov	x29, sp
	stp	x19, x20, [sp, #16]
	stp	x21, x22, [sp, #32]

	mov	x19, x0				/* a */
	mov	x20, x1				/* n */

	/* ---- build the max-heap: for i = n/2 - 1 down to 0 ---- */
	lsr	x21, x20, #1			/* i = n/2 */
.Lst_build:
	cbz	x21, .Lst_extract
	sub	x21, x21, #1			/* i-- */
	mov	x0, x21				/* root */
	mov	x1, x20				/* end  */
	bl	.Lst_siftdown
	cbnz	x21, .Lst_build

	/* ---- extract: for end = n-1 down to 1 ---- */
.Lst_extract:
	sub	x22, x20, #1			/* end = n-1 */
.Lst_extract_loop:
	cbz	x22, .Lst_checksum

	/* swap a[0] and a[end] */
	ldr	w9, [x19]
	ldr	w10, [x19, x22, lsl #2]
	str	w10, [x19]
	str	w9, [x19, x22, lsl #2]

	mov	x0, xzr				/* root = 0   */
	mov	x1, x22				/* end = end  */
	bl	.Lst_siftdown

	sub	x22, x22, #1
	b	.Lst_extract_loop

	/* ---- order-sensitive checksum ---- */
.Lst_checksum:
	mov	x0, xzr
	mov	x9, xzr
.Lst_cksum_loop:
	ldr	w10, [x19, x9, lsl #2]
	eor	x0, x0, x10
	ror	x0, x0, #7
	add	x0, x0, x10
	add	x9, x9, #1
	cmp	x9, x20
	b.lo	.Lst_cksum_loop

	ldp	x21, x22, [sp, #32]
	ldp	x19, x20, [sp, #16]
	ldp	x29, x30, [sp], #48
	ret

.Lst_trivial:
	mov	x0, xzr
	cbz	x1, .Lst_trivial_ret
	ldr	w0, [x0]
.Lst_trivial_ret:
	ret

	/* ---- local helper: siftdown(root = x0, end = x1)
	 * clobbers x9-x15 only; x19 (base) is live across the call. ---- */
.Lst_siftdown:
	mov	x11, x0				/* root */
.Lst_sift_loop:
	lsl	x12, x11, #1
	add	x12, x12, #1			/* child = 2*root + 1 */
	cmp	x12, x1
	b.hs	.Lst_sift_done			/* no children */

	/* pick the larger of the two children */
	add	x13, x12, #1			/* child + 1 */
	cmp	x13, x1
	b.hs	.Lst_sift_have_child
	ldr	w14, [x19, x12, lsl #2]
	ldr	w15, [x19, x13, lsl #2]
	cmp	w15, w14
	csel	x12, x13, x12, hi

.Lst_sift_have_child:
	ldr	w14, [x19, x11, lsl #2]		/* a[root]  */
	ldr	w15, [x19, x12, lsl #2]		/* a[child] */
	cmp	w14, w15
	b.hs	.Lst_sift_done			/* heap property holds */

	/* swap and descend */
	str	w15, [x19, x11, lsl #2]
	str	w14, [x19, x12, lsl #2]
	mov	x11, x12
	b	.Lst_sift_loop

.Lst_sift_done:
	ret
FN_END(fm_sort)


/* ===================================================================
 * uint64_t fm_chase(void **ptrs, uint64_t steps)
 *
 * Pointer chase around a randomised cycle. Every load depends on the previous
 * one, so nothing can be prefetched, overlapped or reordered - this measures
 * the pure serial latency of the memory hierarchy, which is the single
 * hardest thing for a wide out-of-order core to hide. It is the truest
 * "single-threaded" test in the suite.
 * =================================================================== */
FN_BEGIN(fm_chase)
	cbz	x1, .Lch_zero
	mov	x2, x0				/* p = ptrs */
	mov	x3, x1

.Lch_loop:
	ldr	x2, [x2]
	subs	x3, x3, #1
	b.ne	.Lch_loop

	sub	x0, x2, x0			/* final offset, keeps p live */
	ret

.Lch_zero:
	mov	x0, xzr
	ret
FN_END(fm_chase)


#if defined(__ELF__)
	.section	.note.GNU-stack, "", %progbits
#endif
