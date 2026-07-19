	.file	"fossbench-ppc64le.S"
	.machine power8
	.machine altivec
	.abiversion 2
	.section	".text"
	.align 2
	.p2align 4,,15
	.type	sift, @function
sift:
.LFB11:
	.cfi_startproc
	sldi 10,4,1
	addi 10,10,1
	cmpld 0,5,10
	blelr 0
	sldi 9,4,2
	lwzx 11,3,9
	b .L4
	.p2align 4,,15
.L9:
	lwzx 7,3,7
	cmplw 0,7,8
	ble 0,.L5
	mr 8,7
	sldi 10,9,1
	cmplw 0,11,8
	addi 10,10,1
	sldi 7,4,2
	cmpld 7,10,5
	mr 6,0
	mr 4,9
	bgelr 0
.L10:
	stwx 8,3,7
	stw 11,0(6)
	bgelr 7
.L4:
	addi 9,4,1
	sldi 8,10,2
	sldi 7,9,3
	sldi 9,9,1
	cmpld 0,9,5
	add 6,3,8
	lwzx 8,3,8
	add 0,3,7
	blt 0,.L9
.L5:
	cmplw 0,11,8
	mr 9,10
	sldi 10,9,1
	sldi 7,4,2
	addi 10,10,1
	mr 4,9
	cmpld 7,10,5
	blt 0,.L10
	blr
	.long 0
	.byte 0,0,0,0,0,0,0,0
	.cfi_endproc
.LFE11:
	.size	sift,.-sift
	.align 2
	.p2align 4,,15
	.globl fb_int_math
	.type	fb_int_math, @function
fb_int_math:
.LFB1:
	.cfi_startproc
	cmpdi 0,3,0
	beq 0,.L14
	mtctr 3
	lis 7,0x4f6c
	lis 5,0x2545
	ori 7,7,0xdd1d
	ori 5,5,0xf491
	lis 6,0xdfc9
	rldimi 7,5,32,0
	lis 5,0x9327
	lis 8,0x1331
	lis 12,0x94d0
	lis 10,0x1ce4
	lis 0,0xbf58
	lis 9,0x7f4a
	lis 4,0x9e37
	lis 11,0xdead
	ori 6,6,0x94b
	ori 5,5,0x5ab2
	ori 8,8,0x11eb
	ori 12,12,0x49bb
	ori 10,10,0xe5b9
	ori 0,0,0x476d
	ori 9,9,0x7c15
	ori 4,4,0x79b9
	ori 11,11,0xbeef
	rldimi 6,5,32,0
	rldimi 8,12,32,0
	rldimi 10,0,32,0
	rldimi 9,4,32,0
	rldicl 11,11,0,32
	mr 3,6
	.p2align 4,,15
.L13:
	mulld 9,9,11
	mulld 6,8,11
	mulld 4,7,11
	mulld 5,10,11
	add 9,9,10
	add 10,6,7
	add 4,4,9
	add 8,5,8
	srdi 6,10,29
	sldi 5,4,17
	xor 6,6,9
	xor 5,5,8
	srdi 7,5,7
	rotldi 8,6,33
	xor 8,8,10
	xor 7,7,4
	mulhdu 10,7,3
	mulhdu 9,8,3
	srdi 10,10,31
	srdi 9,9,31
	add 10,10,5
	add 9,9,6
	bdnz .L13
	xor 3,8,7
	xor 3,3,9
	xor 3,3,10
	blr
	.p2align 4,,15
.L14:
	li 3,0
	blr
	.long 0
	.byte 0,0,0,0,0,0,0,0
	.cfi_endproc
.LFE1:
	.size	fb_int_math,.-fb_int_math
	.align 2
	.p2align 4,,15
	.globl fb_fp_math
	.type	fb_fp_math, @function
fb_fp_math:
.LFB2:
	.cfi_startproc
.LCF2:
0:	addis 2,12,.TOC.-.LCF2@ha
	addi 2,2,.TOC.-.LCF2@l
	.localentry	fb_fp_math,.-fb_fp_math
	std 31,-72(1)
	.cfi_offset 31, -72
	mr. 31,3
	stdu 1,-128(1)
	.cfi_def_cfa_offset 128
	beq 0,.L20
	mflr 0
	.cfi_register 65, 0
	addis 9,2,.LC5@toc@ha
	stfd 29,104(1)
	.cfi_offset 61, -24
	stfd 30,112(1)
	.cfi_offset 62, -16
	stfd 31,120(1)
	.cfi_offset 63, -8
	stfd 24,64(1)
	.cfi_offset 56, -64
	lfd 29,.LC5@toc@l(9)
	addis 9,2,.LC7@toc@ha
	stfd 25,72(1)
	.cfi_offset 57, -56
	stfd 26,80(1)
	.cfi_offset 58, -48
	stfd 27,88(1)
	.cfi_offset 59, -40
	stfd 28,96(1)
	.cfi_offset 60, -32
	lfd 30,.LC7@toc@l(9)
	addis 9,2,.LC9@toc@ha
	std 30,48(1)
	.cfi_offset 30, -80
	addis 30,2,.LC19@toc@ha
	std 0,144(1)
	.cfi_offset 65, 16
	addi 30,30,.LC19@toc@l
	lfd 31,.LC9@toc@l(9)
	addis 9,2,.LC11@toc@ha
	lfd 0,.LC11@toc@l(9)
	addis 9,2,.LC13@toc@ha
	lfd 24,.LC13@toc@l(9)
	addis 9,2,.LC15@toc@ha
	lfd 25,.LC15@toc@l(9)
	addis 9,2,.LC17@toc@ha
	lfd 26,.LC17@toc@l(9)
	.p2align 4,,15
.L19:
	fmadd 1,0,24,25
	fmr 2,26
	bl fmin
	nop
	fmr 27,1
	fmr 2,26
	fmadd 1,31,24,25
	bl fmin
	nop
	fmr 28,1
	fmr 2,26
	fmadd 1,30,24,25
	bl fmin
	nop
	fmr 30,1
	fmr 1,27
	bl sqrt
	nop
	fmr 0,1
	fmr 2,26
	fmadd 1,29,24,25
	fadd 30,30,0
	bl fmin
	nop
	fmr 31,1
	fmr 1,28
	bl sqrt
	nop
	fadd 1,31,1
	bl fabs
	nop
	lfd 31,0(30)
	fmr 2,31
	bl fmax
	nop
	addic. 31,31,-1
	fadd 0,30,31
	fadd 12,1,31
	fmr 29,1
	fdiv 0,31,0
	fdiv 31,31,12
	fadd 0,0,27
	fadd 31,31,28
	bne 0,.L19
	fadd 0,0,31
	addi 4,1,40
	li 5,8
	addi 3,1,32
	fadd 0,0,30
	fadd 0,0,1
	stfd 0,40(1)
	bl memcpy
	nop
	ld 0,144(1)
	ld 3,32(1)
	lfd 24,64(1)
	.cfi_restore 56
	lfd 25,72(1)
	.cfi_restore 57
	lfd 26,80(1)
	.cfi_restore 58
	lfd 27,88(1)
	.cfi_restore 59
	ld 30,48(1)
	.cfi_restore 30
	lfd 28,96(1)
	.cfi_restore 60
	lfd 29,104(1)
	.cfi_restore 61
	mtlr 0
	.cfi_restore 65
	lfd 30,112(1)
	.cfi_restore 62
	lfd 31,120(1)
	.cfi_restore 63
	addi 1,1,128
	.cfi_def_cfa_offset 0
	ld 31,-72(1)
	.cfi_restore 31
	blr
	.p2align 4,,15
.L20:
	.cfi_def_cfa_offset 128
	.cfi_offset 31, -72
	addi 1,1,128
	.cfi_def_cfa_offset 0
	li 3,0
	ld 31,-72(1)
	.cfi_restore 31
	blr
	.long 0
	.byte 0,0,2,1,136,2,0,0
	.cfi_endproc
.LFE2:
	.size	fb_fp_math,.-fb_fp_math
	.align 2
	.p2align 4,,15
	.globl fb_primes
	.type	fb_primes, @function
fb_primes:
.LFB3:
	.cfi_startproc
.LCF3:
0:	addis 2,12,.TOC.-.LCF3@ha
	addi 2,2,.TOC.-.LCF3@l
	.localentry	fb_primes,.-fb_primes
	cmpldi 0,3,1
	ble 0,.L52
	mflr 0
	mr 8,4
	mr 5,3
	li 4,0
	std 0,16(1)
	stdu 1,-224(1)
	.cfi_def_cfa_offset 224
	.cfi_offset 65, 16
	li 0,48
	stvx 21,1,0
	li 0,64
	stvx 22,1,0
	li 0,80
	stvx 23,1,0
	li 0,96
	stvx 24,1,0
	li 0,112
	stvx 25,1,0
	li 0,128
	stvx 26,1,0
	li 0,144
	stvx 27,1,0
	li 0,160
	stvx 28,1,0
	li 0,176
	stvx 29,1,0
	li 0,192
	stvx 30,1,0
	li 0,208
	stvx 31,1,0
	.cfi_offset 98, -176
	.cfi_offset 99, -160
	.cfi_offset 100, -144
	.cfi_offset 101, -128
	.cfi_offset 102, -112
	.cfi_offset 103, -96
	.cfi_offset 104, -80
	.cfi_offset 105, -64
	.cfi_offset 106, -48
	.cfi_offset 107, -32
	.cfi_offset 108, -16
	std 3,40(1)
	mr 3,8
	std 8,32(1)
	bl memset
	nop
	ld 5,40(1)
	ld 8,32(1)
	li 9,257
	addi 6,5,-1
	sth 9,0(8)
	cmpldi 0,6,3
	ble 0,.L25
	li 10,2
	li 7,1
	b .L28
	.p2align 4,,15
.L26:
	addi 10,10,1
	divdu 9,6,10
	cmpld 0,9,10
	blt 0,.L55
.L28:
	lbzx 9,8,10
	cmpwi 0,9,0
	bne 0,.L26
	mulld 9,10,10
	cmpld 0,9,5
	bge 0,.L26
	.p2align 4,,15
.L27:
	stbx 7,8,9
	add 9,9,10
	cmpld 0,5,9
	bgt 0,.L27
	addi 10,10,1
	divdu 9,6,10
	cmpld 0,9,10
	bge 0,.L28
.L55:
	addi 9,5,-3
	cmpldi 0,9,30
	ble 0,.L30
	addi 4,5,-2
	vspltisw 9,0
	vspltish 12,0
	addi 9,8,2
	srdi 7,4,5
	vspltisw 13,0
	vspltisw 10,0
	vspltisb 29,1
	mtctr 7
	xxlor 34,41,41
	xxlor 35,41,41
	mr 10,7
	xxlor 36,41,41
	xxlor 48,41,41
	li 6,16
	xxlor 49,41,41
	xxlor 50,41,41
	xxlor 51,41,41
	xxlor 62,41,41
	xxlor 40,41,41
	xxlor 63,41,41
	xxlor 37,41,41
	xxlor 46,41,41
	xxlor 39,41,41
	xxlor 47,41,41
	xxlor 38,41,41
	.p2align 4,,15
.L33:
	lxvd2x 33,0,9
	lxvd2x 32,9,6
	addi 10,10,-1
	addi 9,9,32
	xxpermdi 33,33,33,2
	xxpermdi 32,32,32,2
	vcmpequb 1,1,10
	vcmpequb 0,0,10
	xxland 33,33,61
	xxland 32,32,61
	vmrglb 11,10,1
	vmrghb 1,10,1
	vmrglb 28,10,0
	vmrghb 0,10,0
	vmrglh 24,12,11
	vmrglh 25,12,1
	vmrghh 11,12,11
	vmrglh 26,12,28
	vmrglh 27,12,0
	xxmrglw 54,45,56
	xxmrglw 55,45,43
	xxmrglw 53,45,57
	vmrghh 1,12,1
	vmrghh 28,12,28
	vmrghh 0,12,0
	xxmrghw 56,45,56
	xxmrghw 43,45,43
	xxmrghw 57,45,57
	vaddudm 6,6,22
	vaddudm 15,15,24
	xxmrglw 54,45,33
	xxmrglw 56,45,58
	xxmrghw 33,45,33
	xxmrghw 58,45,58
	vaddudm 7,7,23
	vaddudm 14,14,11
	xxmrglw 55,45,60
	xxmrglw 43,45,59
	xxmrghw 60,45,60
	xxmrghw 59,45,59
	vaddudm 5,5,21
	xxmrglw 53,45,32
	xxmrghw 32,45,32
	vaddudm 31,31,25
	vaddudm 8,8,22
	vaddudm 30,30,1
	vaddudm 19,19,24
	vaddudm 18,18,26
	vaddudm 17,17,23
	vaddudm 16,16,28
	vaddudm 4,4,11
	vaddudm 3,3,27
	vaddudm 2,2,21
	vaddudm 9,9,0
	bdnz .L33
	vaddudm 0,8,30
	vaddudm 12,5,31
	sldi 7,7,5
	vaddudm 1,7,14
	vaddudm 13,6,15
	cmpld 0,4,7
	vaddudm 0,0,16
	vaddudm 12,12,17
	vaddudm 1,1,18
	vaddudm 13,13,19
	mtvsrd 0,10
	vaddudm 0,0,9
	vaddudm 12,12,2
	vaddudm 1,1,3
	vaddudm 13,13,4
	vaddudm 0,0,12
	vaddudm 1,1,13
	xxpermdi 0,0,0,0
	vaddudm 0,0,1
	xxsldwi 33,0,32,2
	vaddudm 0,1,0
	xxpermdi 0,32,32,3
	mfvsrd 3,0
	beq 0,.L23
	addi 7,7,2
.L32:
	addi 10,7,1
	li 9,1
	subfc 10,10,5
	subfe 10,10,10
	addi 10,10,1
	rlwinm 10,10,0,0xff
	cmpwi 0,10,0
	beq 0,.L35
	subf 9,7,5
.L35:
	andi. 10,9,0x1
	addi 8,8,-1
	add 8,8,7
	addi 6,9,-1
	li 7,0
	beq 0,.L42
	lbzu 10,1(8)
	cmpdi 0,6,0
	cntlzw 10,10
	srwi 10,10,5
	add 3,3,10
	beq 0,.L48
.L42:
	srdi 9,9,1
	mtctr 9
.L36:
	mr 9,8
	lbz 10,1(8)
	addi 8,8,2
	lbz 9,2(9)
	cntlzw 10,10
	cntlzw 9,9
	srwi 10,10,5
	add 3,3,10
	srwi 9,9,5
	add 7,7,9
	bdnz .L36
.L48:
	add 3,3,7
.L23:
	addi 1,1,224
	.cfi_def_cfa_offset 0
	li 0,-176
	lvx 21,1,0
	li 0,-160
	lvx 22,1,0
	li 0,-144
	lvx 23,1,0
	li 0,-128
	lvx 24,1,0
	li 0,-112
	lvx 25,1,0
	li 0,-96
	lvx 26,1,0
	li 0,-80
	lvx 27,1,0
	li 0,-64
	lvx 28,1,0
	li 0,-48
	lvx 29,1,0
	li 0,-32
	lvx 30,1,0
	li 0,-16
	lvx 31,1,0
	ld 0,16(1)
	mtlr 0
	.cfi_restore 65
	.cfi_restore 108
	.cfi_restore 107
	.cfi_restore 106
	.cfi_restore 105
	.cfi_restore 104
	.cfi_restore 103
	.cfi_restore 102
	.cfi_restore 101
	.cfi_restore 100
	.cfi_restore 99
	.cfi_restore 98
	blr
	.p2align 4,,15
.L52:
	li 3,0
	blr
.L25:
	.cfi_def_cfa_offset 224
	.cfi_offset 98, -176
	.cfi_offset 99, -160
	.cfi_offset 100, -144
	.cfi_offset 101, -128
	.cfi_offset 102, -112
	.cfi_offset 103, -96
	.cfi_offset 104, -80
	.cfi_offset 105, -64
	.cfi_offset 106, -48
	.cfi_offset 107, -32
	.cfi_offset 108, -16
	.cfi_offset 65, 16
	cmpldi 0,5,2
	li 3,0
	beq 0,.L23
.L30:
	li 3,0
	li 7,2
	b .L32
	.long 0
	.byte 0,0,0,1,128,0,0,0
	.cfi_endproc
.LFE3:
	.size	fb_primes,.-fb_primes
	.align 2
	.p2align 4,,15
	.globl fb_simd
	.type	fb_simd, @function
fb_simd:
.LFB4:
	.cfi_startproc
.LCF4:
0:	addis 2,12,.TOC.-.LCF4@ha
	addi 2,2,.TOC.-.LCF4@l
	.localentry	fb_simd,.-fb_simd
	mr. 9,3
	bne 0,.L74
	mr 3,9
	blr
	.p2align 4,,15
.L74:
	mflr 0
	std 30,-16(1)
	std 31,-8(1)
	li 5,16
	.cfi_register 65, 0
	.cfi_offset 30, -16
	.cfi_offset 31, -8
	mr 31,4
	std 0,16(1)
	stdu 1,-96(1)
	.cfi_def_cfa_offset 96
	.cfi_offset 65, 16
	addi 3,1,48
	std 9,64(1)
	bl memcpy
	nop
	addi 9,31,16
	li 5,16
	mr 4,9
	addi 3,1,32
	mr 30,9
	bl memcpy
	nop
	ld 9,64(1)
	li 10,32
	li 8,48
	lxvd2x 32,1,10
	lxvd2x 33,1,8
	andi. 7,9,0x1
	addi 10,9,-1
	beq 0,.L63
	vadduwm 1,1,0
	cmpdi 0,10,0
	xxlxor 32,33,32
	vadduwm 1,1,0
	xxlxor 32,32,33
	beq 0,.L68
.L63:
	srdi 9,9,1
	mtctr 9
.L58:
	vadduwm 1,1,0
	xxlxor 32,33,32
	vadduwm 1,1,0
	xxlxor 32,32,33
	vadduwm 1,1,0
	xxlxor 32,33,32
	vadduwm 1,1,0
	xxlxor 32,32,33
	bdnz .L58
.L68:
	li 10,48
	li 9,32
	addi 4,1,48
	li 5,16
	stxvd2x 33,1,10
	mr 3,31
	stxvd2x 32,1,9
	bl memcpy
	nop
	addi 4,1,32
	li 5,16
	mr 3,30
	bl memcpy
	nop
	li 9,16
	lxvd2x 0,0,31
	vspltisw 0,0
	addi 1,1,96
	.cfi_def_cfa_offset 0
	lxvd2x 12,31,9
	ld 0,16(1)
	ld 30,-16(1)
	ld 31,-8(1)
	mtlr 0
	.cfi_restore 65
	xxpermdi 0,0,0,2
	xxpermdi 12,12,12,2
	xxlxor 0,0,12
	xxsldwi 12,32,0,2
	xxlxor 0,12,0
	xxsldwi 32,32,0,3
	xxlxor 32,32,0
	vspltw 0,0,3
	mfvsrwz 9,32
	mr 3,9
	.cfi_restore 31
	.cfi_restore 30
	blr
	.long 0
	.byte 0,0,0,1,128,2,0,0
	.cfi_endproc
.LFE4:
	.size	fb_simd,.-fb_simd
	.align 2
	.p2align 4,,15
	.globl fb_compress
	.type	fb_compress, @function
fb_compress:
.LFB6:
	.cfi_startproc
.LCF5:
0:	addis 2,12,.TOC.-.LCF5@ha
	addi 2,2,.TOC.-.LCF5@l
	.localentry	fb_compress,.-fb_compress
	mflr 0
	std 22,-80(1)
	std 25,-56(1)
	.cfi_register 65, 0
	.cfi_offset 22, -80
	.cfi_offset 25, -56
	mr 25,4
	std 28,-32(1)
	std 29,-24(1)
	.cfi_offset 28, -32
	.cfi_offset 29, -24
	mr 28,3
	mr 29,5
	mr 3,5
	li 4,0
	lis 5,0x4
	addi 22,25,1
	std 0,16(1)
	stdu 1,-144(1)
	.cfi_def_cfa_offset 144
	.cfi_offset 65, 16
	bl memset
	nop
	cmpldi 0,25,15
	ble 0,.L75
	std 27,104(1)
	.cfi_offset 27, -40
	std 30,128(1)
	.cfi_offset 30, -16
	std 26,96(1)
	.cfi_offset 26, -48
	lis 26,0x9e37
	std 21,56(1)
	.cfi_offset 21, -88
	li 21,0
	std 23,72(1)
	.cfi_offset 23, -72
	std 24,80(1)
	.cfi_offset 24, -64
	ori 26,26,0x79b1
	addi 24,25,-12
	std 31,136(1)
	.cfi_offset 31, -8
	li 23,0
	li 31,0
	.p2align 4,,15
.L82:
	li 5,4
	add 4,28,31
	addi 3,1,32
	bl memcpy
	nop
	lwz 27,32(1)
	mullw 9,27,26
	rlwinm 9,9,18,14,29
	lwzx 10,29,9
	stwx 31,29,9
	cmpld 0,10,31
	bge 0,.L77
	subf 9,10,31
	cmpldi 0,9,65535
	bgt 0,.L77
	add 30,28,10
	li 5,4
	mr 4,30
	addi 3,1,32
	bl memcpy
	nop
	lwz 9,32(1)
	cmplw 0,27,9
	beq 0,.L102
.L77:
	addi 31,31,1
.L80:
	cmpld 0,31,24
	blt 0,.L82
	add 23,23,22
	ld 24,80(1)
	.cfi_restore 24
	ld 26,96(1)
	.cfi_restore 26
	ld 27,104(1)
	.cfi_restore 27
	ld 30,128(1)
	.cfi_restore 30
	subf 22,21,23
	ld 31,136(1)
	.cfi_restore 31
	ld 21,56(1)
	.cfi_restore 21
	ld 23,72(1)
	.cfi_restore 23
.L75:
	addi 1,1,144
	.cfi_def_cfa_offset 0
	mr 3,22
	ld 0,16(1)
	ld 22,-80(1)
	ld 25,-56(1)
	ld 28,-32(1)
	ld 29,-24(1)
	mtlr 0
	.cfi_restore 65
	.cfi_restore 29
	.cfi_restore 28
	.cfi_restore 25
	.cfi_restore 22
	blr
	.p2align 4,,15
.L102:
	.cfi_def_cfa_offset 144
	.cfi_offset 21, -88
	.cfi_offset 22, -80
	.cfi_offset 23, -72
	.cfi_offset 24, -64
	.cfi_offset 25, -56
	.cfi_offset 26, -48
	.cfi_offset 27, -40
	.cfi_offset 28, -32
	.cfi_offset 29, -24
	.cfi_offset 30, -16
	.cfi_offset 31, -8
	.cfi_offset 65, 16
	addi 9,31,4
	li 10,4
	cmpld 0,25,9
	ble 0,.L97
	lbzx 6,28,9
	lbz 7,4(30)
	not 8,9
	add 8,8,25
	rldicl 5,8,0,63
	cmpw 0,6,7
	bne 0,.L98
	addi 9,31,5
	li 10,5
	cmpld 0,9,25
	bge 0,.L98
	cmpdi 0,5,0
	beq 0,.L91
	lbzx 6,28,9
	lbzx 7,30,10
	cmpw 0,6,7
	bne 0,.L98
	addi 9,31,6
	li 10,6
	cmpld 0,9,25
	bge 0,.L98
.L91:
	srdi 8,8,1
	mtctr 8
	b .L78
	.p2align 4,,15
.L81:
	addi 10,10,1
	addi 9,9,1
	lbzx 8,30,10
	lbzx 7,28,9
	cmpw 0,7,8
	bne 0,.L98
	addi 10,10,1
	addi 9,9,1
	bdz .L98
.L78:
	lbzx 7,28,9
	lbzx 8,30,10
	cmpw 0,7,8
	beq 0,.L81
.L98:
	subfic 10,10,18
	subfe 8,8,8
	neg 8,8
.L79:
	subf 31,21,31
	addi 23,23,3
	subfic 10,31,14
	add 23,23,31
	subfe 10,10,10
	mr 21,9
	subf 9,10,23
	mr 31,21
	add 23,9,8
	b .L80
.L97:
	li 8,0
	b .L79
	.long 0
	.byte 0,0,0,1,128,11,0,0
	.cfi_endproc
.LFE6:
	.size	fb_compress,.-fb_compress
	.align 2
	.p2align 4,,15
	.globl fb_chacha20
	.type	fb_chacha20, @function
fb_chacha20:
.LFB9:
	.cfi_startproc
.LCF6:
0:	addis 2,12,.TOC.-.LCF6@ha
	addi 2,2,.TOC.-.LCF6@l
	.localentry	fb_chacha20,.-fb_chacha20
	std 30,-16(1)
	stdu 1,-464(1)
	.cfi_def_cfa_offset 464
	.cfi_offset 30, -16
	rldicr 30,4,0,57
	li 0,288
	rldicr. 4,4,0,57
	stvx 30,1,0
	li 0,304
	stvx 31,1,0
	std 30,224(1)
	.cfi_offset 107, -176
	.cfi_offset 108, -160
	beq 0,.L103
	cmpdi 0,6,0
	std 28,432(1)
	.cfi_offset 28, -32
	mr 28,6
	bne 0,.L118
	li 9,0
	ld 28,432(1)
	.cfi_restore 28
	std 9,224(1)
.L103:
	ld 3,224(1)
	li 0,-176
	addi 1,1,464
	.cfi_def_cfa_offset 0
	lvx 30,1,0
	li 0,-160
	ld 30,-16(1)
	lvx 31,1,0
	.cfi_restore 30
	.cfi_restore 108
	.cfi_restore 107
	blr
.L118:
	.cfi_def_cfa_offset 464
	.cfi_offset 28, -32
	.cfi_offset 30, -16
	.cfi_offset 107, -176
	.cfi_offset 108, -160
	mflr 0
	.cfi_register 65, 0
	addis 4,2,.LANCHOR0@toc@ha
	std 24,400(1)
	.cfi_offset 24, -64
	std 31,456(1)
	.cfi_offset 31, -8
	vspltisw 30,0
	mr 24,3
	mr 31,5
	std 14,320(1)
	.cfi_offset 14, -144
	std 15,328(1)
	.cfi_offset 15, -136
	li 5,16
	addi 3,1,96
	std 16,336(1)
	.cfi_offset 16, -128
	std 17,344(1)
	.cfi_offset 17, -120
	addi 4,4,.LANCHOR0@toc@l
	std 18,352(1)
	.cfi_offset 18, -112
	std 19,360(1)
	.cfi_offset 19, -104
	li 18,48
	std 20,368(1)
	.cfi_offset 20, -96
	std 21,376(1)
	.cfi_offset 21, -88
	addi 20,24,48
	addi 21,24,32
	std 22,384(1)
	.cfi_offset 22, -80
	std 23,392(1)
	.cfi_offset 23, -72
	li 23,0
	addi 22,24,16
	std 27,424(1)
	.cfi_offset 27, -40
	std 29,440(1)
	.cfi_offset 29, -24
	li 19,32
	li 29,0
	std 0,480(1)
	.cfi_offset 65, 16
	std 25,408(1)
	.cfi_offset 25, -56
	li 17,80
	li 16,96
	std 26,416(1)
	.cfi_offset 26, -48
	bl memcpy
	nop
	li 9,16
	lxvd2x 12,0,31
	li 8,112
	std 28,280(1)
	li 10,128
	li 6,0
	lxvd2x 0,31,9
	addi 9,30,-1
	li 7,0
	srdi 9,9,6
	stw 6,148(1)
	mr 12,23
	addi 27,9,1
	addis 9,2,.LC29@toc@ha
	std 7,152(1)
	stxvd2x 12,1,8
	addi 9,9,.LC29@toc@l
	li 30,0
	stw 27,276(1)
	li 15,112
	li 14,128
	stxvd2x 0,1,10
	std 9,232(1)
	addis 9,2,.LC30@toc@ha
	vspltish 31,8
	addi 9,9,.LC30@toc@l
	mr 23,24
	std 9,240(1)
	addis 9,2,.LC31@toc@ha
	addi 9,9,.LC31@toc@l
	std 9,248(1)
	addis 9,2,.LC32@toc@ha
	addi 9,9,.LC32@toc@l
	std 9,256(1)
.L105:
	std 30,264(1)
	stw 29,272(1)
	mr 24,29
	li 25,0
	.p2align 4,,15
.L107:
	stw 24,144(1)
	addi 24,24,1
	li 5,64
	stw 12,192(1)
	addi 4,1,96
	addi 3,1,32
	bl memcpy
	nop
	stw 24,160(1)
	lwz 0,72(1)
	lwz 26,44(1)
	li 9,10
	mtctr 9
	lwz 11,76(1)
	lwz 30,32(1)
	lwz 3,48(1)
	lwz 6,80(1)
	lwz 29,64(1)
	lwz 31,36(1)
	lwz 5,52(1)
	lwz 8,84(1)
	lwz 28,68(1)
	lwz 27,40(1)
	lwz 7,56(1)
	lwz 9,88(1)
	lwz 10,60(1)
	lwz 4,92(1)
	lwz 12,192(1)
	std 25,176(1)
	mr 25,26
	mr 26,0
	mr 0,11
	.p2align 4,,15
.L106:
	add 30,3,30
	add 31,5,31
	add 27,7,27
	add 25,10,25
	xor 9,27,9
	xor 6,30,6
	xor 8,31,8
	xor 4,25,4
	rotlwi 11,9,16
	rotlwi 6,6,16
	rotlwi 8,8,16
	rotlwi 4,4,16
	add 29,6,29
	add 28,8,28
	add 26,26,11
	add 0,0,4
	xor 3,29,3
	xor 5,28,5
	xor 7,26,7
	xor 10,0,10
	rotlwi 24,3,12
	rotlwi 5,5,12
	rotlwi 7,7,12
	rotlwi 10,10,12
	add 30,30,24
	add 31,31,5
	add 27,27,7
	add 25,25,10
	xor 3,27,11
	xor 6,30,6
	xor 8,31,8
	xor 4,25,4
	rotlwi 6,6,8
	rotlwi 8,8,8
	rotlwi 3,3,8
	rotlwi 4,4,8
	add 29,29,6
	add 28,28,8
	add 26,26,3
	add 0,0,4
	xor 9,29,24
	xor 5,28,5
	xor 7,26,7
	xor 10,0,10
	rotlwi 9,9,7
	rotlwi 5,5,7
	rotlwi 7,7,7
	rotlwi 10,10,7
	add 30,30,5
	add 31,31,7
	add 25,25,9
	add 27,27,10
	xor 3,25,3
	xor 6,31,6
	xor 4,30,4
	xor 8,27,8
	rotlwi 11,3,16
	rotlwi 6,6,16
	rotlwi 4,4,16
	rotlwi 8,8,16
	add 26,26,4
	add 0,0,6
	add 29,29,8
	add 28,28,11
	xor 9,28,9
	xor 5,26,5
	xor 7,0,7
	xor 10,29,10
	rotlwi 24,9,12
	rotlwi 5,5,12
	rotlwi 7,7,12
	rotlwi 10,10,12
	add 30,30,5
	add 31,31,7
	add 27,27,10
	add 25,25,24
	xor 9,25,11
	xor 4,30,4
	xor 6,31,6
	xor 8,27,8
	rotlwi 9,9,8
	rotlwi 4,4,8
	rotlwi 6,6,8
	rotlwi 8,8,8
	add 28,28,9
	add 26,26,4
	add 0,0,6
	add 29,29,8
	xor 3,28,24
	xor 5,26,5
	xor 7,0,7
	xor 10,29,10
	rotlwi 3,3,7
	rotlwi 5,5,7
	rotlwi 7,7,7
	rotlwi 10,10,7
	bdnz .L106
	mr 11,0
	mr 0,26
	stw 4,92(1)
	stw 10,60(1)
	mr 26,25
	stw 9,88(1)
	stw 30,32(1)
	addi 9,1,208
	stw 0,72(1)
	stw 5,52(1)
	li 4,64
	stw 31,36(1)
	stw 6,80(1)
	stw 11,76(1)
	stw 7,56(1)
	stw 27,40(1)
	stw 8,84(1)
	stw 29,64(1)
	stw 26,44(1)
	stw 28,68(1)
	stw 3,48(1)
	lvx 0,1,14
	ld 25,176(1)
	lvx 9,1,15
	lwz 24,160(1)
	lxvd2x 33,23,25
	lxvd2x 38,22,25
	lxvd2x 39,20,25
	xxpermdi 32,32,32,2
	stxvd2x 32,0,9
	ld 9,232(1)
	lxvd2x 32,21,25
	xxpermdi 33,33,33,2
	xxpermdi 38,38,38,2
	xxpermdi 39,39,39,2
	xxpermdi 32,32,32,2
	lvx 4,0,9
	ld 9,240(1)
	lvx 13,0,9
	ld 9,248(1)
	vperm 10,6,1,4
	vperm 4,7,0,4
	lvx 8,0,9
	ld 9,256(1)
	vperm 5,7,0,13
	vperm 11,6,1,13
	lvx 12,0,9
	vperm 4,4,10,13
	addi 9,1,160
	ld 10,224(1)
	vperm 5,5,11,13
	lvx 13,1,17
	vperm 7,7,0,12
	lvx 0,1,19
	vperm 6,6,1,12
	lvx 1,1,18
	xxpermdi 45,45,45,2
	xxpermdi 32,32,32,2
	xxpermdi 33,33,33,2
	stxvd2x 32,0,9
	addi 9,1,176
	lvx 0,1,16
	stxvd2x 33,0,9
	addi 9,1,192
	lvx 1,1,4
	stxvd2x 45,0,9
	addi 9,1,160
	lvx 13,0,9
	addi 9,1,176
	vadduwm 11,0,13
	lvx 0,0,9
	addi 9,1,208
	lvx 13,0,9
	addi 9,1,144
	xxmrghw 42,43,43
	lxvd2x 0,0,9
	addi 9,1,192
	vsrw 10,10,8
	vadduwm 0,9,0
	vadduwm 12,13,1
	lvx 13,0,9
	xxlxor 12,32,43
	vpkuwum 19,0,11
	xxmrglw 34,32,32
	xxpermdi 33,0,0,2
	vsrh 9,19,31
	vsrw 2,2,8
	vadduwm 13,1,13
	xxmrglw 33,43,43
	xxmrghw 43,32,32
	xxmrglw 32,44,44
	xxlxor 0,45,44
	vpkuwum 18,13,12
	xxmrglw 35,45,45
	xxmrghw 44,44,44
	xxmrghw 45,45,45
	xxlxor 12,12,0
	vsrw 12,12,8
	vsrh 17,18,31
	vsrw 13,13,8
	vsrw 1,1,8
	vsrw 11,11,8
	vsrw 0,0,8
	vsrw 3,3,8
	xxsldwi 0,62,12,2
	vpkuwum 1,10,1
	vpkuwum 11,11,2
	vpkuwum 0,12,0
	vpkuhum 19,18,19
	vpkuwum 12,13,3
	vpkuhum 9,17,9
	xxlxor 0,0,12
	xxlxor 37,37,51
	xxlxor 45,41,36
	vpkuhum 1,11,1
	vpkuhum 0,12,0
	xxsldwi 44,62,0,3
	vmrglb 11,13,5
	xxlxor 33,33,38
	vmrghb 13,13,5
	xxlxor 32,32,39
	xxlxor 44,44,0
	vmrglh 10,1,11
	vmrghh 1,1,11
	vmrglh 11,0,13
	vmrghh 0,0,13
	vspltw 13,12,3
	xxpermdi 42,42,42,2
	xxpermdi 33,33,33,2
	xxpermdi 43,43,43,2
	xxpermdi 32,32,32,2
	stxvd2x 42,23,25
	mfvsrwz 9,45
	stxvd2x 33,22,25
	stxvd2x 43,21,25
	stxvd2x 32,20,25
	addi 25,25,64
	cmpld 0,10,25
	xor 12,12,9
	bgt 0,.L107
	lwz 9,276(1)
	lwz 29,272(1)
	ld 30,264(1)
	add 29,29,9
	ld 9,280(1)
	addi 30,30,1
	cmpld 0,9,30
	bne 0,.L105
	rldicl 9,12,0,32
	ld 0,480(1)
	ld 14,320(1)
	.cfi_restore 14
	ld 15,328(1)
	.cfi_restore 15
	ld 16,336(1)
	.cfi_restore 16
	ld 17,344(1)
	.cfi_restore 17
	ld 18,352(1)
	.cfi_restore 18
	ld 19,360(1)
	.cfi_restore 19
	ld 20,368(1)
	.cfi_restore 20
	std 9,224(1)
	ld 21,376(1)
	.cfi_restore 21
	ld 22,384(1)
	.cfi_restore 22
	mtlr 0
	.cfi_restore 65
	ld 23,392(1)
	.cfi_restore 23
	ld 24,400(1)
	.cfi_restore 24
	ld 25,408(1)
	.cfi_restore 25
	ld 26,416(1)
	.cfi_restore 26
	li 0,-176
	ld 27,424(1)
	.cfi_restore 27
	ld 28,432(1)
	.cfi_restore 28
	ld 29,440(1)
	.cfi_restore 29
	ld 31,456(1)
	.cfi_restore 31
	ld 3,224(1)
	addi 1,1,464
	.cfi_def_cfa_offset 0
	lvx 30,1,0
	li 0,-160
	ld 30,-16(1)
	lvx 31,1,0
	.cfi_restore 30
	.cfi_restore 108
	.cfi_restore 107
	blr
	.long 0
	.byte 0,0,0,1,128,18,0,0
	.cfi_endproc
.LFE9:
	.size	fb_chacha20,.-fb_chacha20
	.align 2
	.p2align 4,,15
	.globl fb_physics
	.type	fb_physics, @function
fb_physics:
.LFB10:
	.cfi_startproc
.LCF7:
0:	addis 2,12,.TOC.-.LCF7@ha
	addi 2,2,.TOC.-.LCF7@l
	.localentry	fb_physics,.-fb_physics
	std 25,-80(1)
	stdu 1,-208(1)
	.cfi_def_cfa_offset 208
	.cfi_offset 25, -80
	mr. 25,4
	li 0,48
	xxlxor 0,0,0
	stvx 30,1,0
	li 0,64
	stvx 31,1,0
	stfd 0,32(1)
	.cfi_offset 107, -160
	.cfi_offset 108, -144
	beq 0,.L127
	cmpdi 0,5,0
	std 20,88(1)
	.cfi_offset 20, -120
	std 21,96(1)
	.cfi_offset 21, -112
	mr 20,5
	mr 21,3
	li 3,0
	beq 0,.L143
	mflr 0
	.cfi_register 65, 0
	addis 9,2,.LC38@toc@ha
	stfd 29,184(1)
	.cfi_offset 61, -24
	std 27,144(1)
	.cfi_offset 27, -64
	std 29,160(1)
	.cfi_offset 29, -48
	std 30,168(1)
	.cfi_offset 30, -40
	std 31,176(1)
	.cfi_offset 31, -32
	stfd 30,192(1)
	.cfi_offset 62, -16
	lfd 29,.LC38@toc@l(9)
	stfd 31,200(1)
	.cfi_offset 63, -8
	std 23,112(1)
	.cfi_offset 23, -96
	addis 23,2,.LC40@toc@ha
	std 24,120(1)
	.cfi_offset 24, -88
	std 28,152(1)
	.cfi_offset 28, -56
	addis 24,2,.LC41@toc@ha
	addis 28,2,.LC19@toc@ha
	std 0,224(1)
	.cfi_offset 65, 16
	std 22,104(1)
	.cfi_offset 22, -104
	addi 28,28,.LC19@toc@l
	li 22,0
	std 26,136(1)
	.cfi_offset 26, -72
	addi 23,23,.LC40@toc@l
	addi 24,24,.LC41@toc@l
	li 26,32
	.p2align 4,,15
.L121:
	mr 29,21
	li 27,0
	.p2align 4,,15
.L125:
	vspltisw 30,0
	xxlxor 30,30,30
	mr 31,21
	mr 30,25
	.p2align 4,,15
.L122:
	lxvd2x 63,0,31
	lxvd2x 12,0,29
	addi 31,31,64
	lfd 0,16(29)
	lfd 31,-48(31)
	xvsubdp 63,63,12
	fsub 31,31,0
	xxpermdi 0,63,63,3
	xxlor 1,63,63
	fmul 0,0,0
	fmadd 1,1,1,0
	fmadd 1,31,31,1
	fadd 1,1,29
	bl sqrt
	nop
	lfd 0,0(28)
	lfd 12,-40(31)
	addic. 30,30,-1
	fdiv 0,0,1
	fmul 1,0,0
	fmul 1,1,0
	fmul 1,1,12
	xxpermdi 0,1,1,0
	fmadd 30,31,1,30
	xvmaddadp 62,0,63
	bne 0,.L122
	lxvd2x 0,29,26
	lxvd2x 11,0,23
	addi 27,27,1
	lfd 12,48(29)
	lfd 10,0(24)
	cmpld 0,25,27
	xvmaddadp 0,62,11
	fmadd 30,30,10,12
	stxvd2x 0,29,26
	stfd 30,48(29)
	addi 29,29,64
	bne 0,.L125
	mtctr 25
	mr 9,21
	.p2align 4,,15
.L123:
	lxvd2x 12,9,26
	lxvd2x 8,0,9
	lfd 9,16(9)
	lfd 0,48(9)
	xvmaddmdp 12,11,8
	fmadd 0,0,10,9
	stxvd2x 12,0,9
	stfd 0,16(9)
	addi 9,9,64
	bdnz .L123
	addi 22,22,1
	cmpld 0,20,22
	bne 0,.L121
	andi. 9,27,0x1
	lfd 11,32(1)
	addi 9,21,32
	addi 10,27,-1
	beq 0,.L134
	lfd 0,0(9)
	lfd 10,8(9)
	cmpdi 0,10,0
	lfd 12,16(9)
	addi 9,21,96
	fadd 0,0,10
	fadd 0,0,12
	fadd 11,11,0
	beq 0,.L139
.L134:
	srdi 10,27,1
	mtctr 10
.L126:
	lfd 12,0(9)
	lfd 7,8(9)
	mr 10,9
	addi 9,9,128
	lfd 9,-112(9)
	lfd 0,-64(9)
	lfd 8,72(10)
	lfd 10,80(10)
	fadd 12,12,7
	fadd 0,0,8
	fadd 12,12,9
	fadd 0,0,10
	fadd 11,11,12
	fadd 11,11,0
	bdnz .L126
.L139:
	addi 4,1,32
	li 5,8
	stfd 11,32(1)
	addi 3,1,40
	bl memcpy
	nop
	ld 0,224(1)
	ld 3,40(1)
	lfd 29,184(1)
	.cfi_restore 61
	lfd 30,192(1)
	.cfi_restore 62
	lfd 31,200(1)
	.cfi_restore 63
	ld 20,88(1)
	.cfi_restore 20
	ld 21,96(1)
	.cfi_restore 21
	ld 22,104(1)
	.cfi_restore 22
	ld 23,112(1)
	.cfi_restore 23
	ld 24,120(1)
	.cfi_restore 24
	ld 26,136(1)
	.cfi_restore 26
	ld 27,144(1)
	.cfi_restore 27
	mtlr 0
	.cfi_restore 65
	ld 28,152(1)
	.cfi_restore 28
	ld 29,160(1)
	.cfi_restore 29
	ld 30,168(1)
	.cfi_restore 30
	ld 31,176(1)
	.cfi_restore 31
	li 0,-160
	addi 1,1,208
	.cfi_def_cfa_offset 0
	lvx 30,1,0
	li 0,-144
	ld 25,-80(1)
	lvx 31,1,0
	.cfi_restore 25
	.cfi_restore 108
	.cfi_restore 107
	blr
.L143:
	.cfi_def_cfa_offset 208
	.cfi_offset 20, -120
	.cfi_offset 21, -112
	.cfi_offset 25, -80
	.cfi_offset 107, -160
	.cfi_offset 108, -144
	ld 20,88(1)
	.cfi_restore 20
	ld 21,96(1)
	.cfi_restore 21
	li 0,-160
	addi 1,1,208
	.cfi_def_cfa_offset 0
	lvx 30,1,0
	li 0,-144
	ld 25,-80(1)
	lvx 31,1,0
	.cfi_restore 25
	.cfi_restore 108
	.cfi_restore 107
	blr
.L127:
	.cfi_def_cfa_offset 208
	.cfi_offset 25, -80
	.cfi_offset 107, -160
	.cfi_offset 108, -144
	addi 1,1,208
	.cfi_def_cfa_offset 0
	li 0,-160
	li 3,0
	lvx 30,1,0
	li 0,-144
	ld 25,-80(1)
	lvx 31,1,0
	.cfi_restore 25
	.cfi_restore 108
	.cfi_restore 107
	blr
	.long 0
	.byte 0,0,2,1,131,12,0,0
	.cfi_endproc
.LFE10:
	.size	fb_physics,.-fb_physics
	.align 2
	.p2align 4,,15
	.globl fb_sort
	.type	fb_sort, @function
fb_sort:
.LFB12:
	.cfi_startproc
.LCF8:
0:	addis 2,12,.TOC.-.LCF8@ha
	addi 2,2,.TOC.-.LCF8@l
	.localentry	fb_sort,.-fb_sort
	cmpldi 0,4,1
	std 29,-24(1)
	std 30,-16(1)
	.cfi_offset 29, -24
	.cfi_offset 30, -16
	mr 29,3
	stdu 1,-64(1)
	.cfi_def_cfa_offset 64
	mr 30,4
	ble 0,.L165
	mflr 0
	.cfi_register 65, 0
	std 31,56(1)
	.cfi_offset 31, -8
	srdi 31,4,1
	std 28,32(1)
	.cfi_offset 28, -32
	andi. 9,31,0x1
	addi 9,31,-1
	std 0,80(1)
	.cfi_offset 65, 16
	beq 0,.L147
	mr 31,9
	mr 5,4
	mr 4,9
	bl sift
	cmpdi 0,31,0
	beq 0,.L168
	.p2align 4,,15
.L147:
	addi 31,31,-1
	mr 5,30
	mr 4,31
	mr 3,29
	bl sift
	addi 31,31,-1
	mr 5,30
	mr 4,31
	mr 3,29
	bl sift
	cmpdi 0,31,0
	bne 0,.L147
.L168:
	addi 28,30,-1
	sldi 30,30,2
	add 30,30,29
	mr 31,28
	.p2align 4,,15
.L148:
	lwzu 10,-4(30)
	lwz 9,0(29)
	mr 5,31
	li 4,0
	mr 3,29
	stw 10,0(29)
	stw 9,0(30)
	bl sift
	addic. 31,31,-1
	bne 0,.L148
	andi. 9,28,0x1
	addi 9,29,-4
	bne 0,.L172
.L156:
	srdi 28,28,1
	addi 10,28,1
	mtctr 10
	b .L149
	.p2align 4,,15
.L173:
	lwz 31,4(10)
	rotldi 3,3,57
	xor 3,31,3
	add 31,31,3
.L149:
	lwz 3,4(9)
	rotldi 31,31,57
	addi 10,9,4
	addi 9,9,8
	xor 31,3,31
	add 3,3,31
	bdnz .L173
	ld 0,80(1)
	ld 28,32(1)
	.cfi_restore 28
	ld 31,56(1)
	.cfi_restore 31
	mtlr 0
	.cfi_restore 65
.L144:
	addi 1,1,64
	.cfi_def_cfa_offset 0
	ld 29,-24(1)
	ld 30,-16(1)
	.cfi_restore 30
	.cfi_restore 29
	blr
	.p2align 4,,15
.L172:
	.cfi_def_cfa_offset 64
	.cfi_offset 28, -32
	.cfi_offset 29, -24
	.cfi_offset 30, -16
	.cfi_offset 31, -8
	.cfi_offset 65, 16
	lwz 31,0(29)
	mr 9,29
	sldi 31,31,1
	b .L156
	.p2align 4,,15
.L165:
	.cfi_restore 28
	.cfi_restore 31
	.cfi_restore 65
	cmpdi 0,4,0
	li 3,0
	beq 0,.L144
	addi 1,1,64
	.cfi_def_cfa_offset 0
	lwz 3,0(29)
	ld 29,-24(1)
	ld 30,-16(1)
	.cfi_restore 30
	.cfi_restore 29
	blr
	.long 0
	.byte 0,0,0,1,128,4,0,0
	.cfi_endproc
.LFE12:
	.size	fb_sort,.-fb_sort
	.align 2
	.p2align 4,,15
	.globl fb_chase
	.type	fb_chase, @function
fb_chase:
.LFB13:
	.cfi_startproc
	cmpdi 0,4,0
	beq 0,.L177
	andi. 8,4,0x3
	mr 9,3
	addi 7,4,-1
	mr 10,4
	beq 0,.L184
	cmpdi 0,8,1
	beq 0,.L188
	cmpdi 0,8,2
	bne 0,.L196
.L189:
	ld 9,0(9)
	addi 4,4,-1
.L188:
	cmpdi 0,4,1
	ld 9,0(9)
	beq 0,.L194
.L184:
	srdi 10,10,2
	mtctr 10
.L176:
	ld 9,0(9)
	ld 9,0(9)
	ld 9,0(9)
	ld 9,0(9)
	bdnz .L176
.L194:
	subf 3,3,9
	blr
	.p2align 4,,15
.L177:
	li 3,0
	blr
	.p2align 4,,15
.L196:
	ld 9,0(3)
	mr 4,7
	b .L189
	.long 0
	.byte 0,0,0,0,0,0,0,0
	.cfi_endproc
.LFE13:
	.size	fb_chase,.-fb_chase
	.section	.rodata.cst8,"aM",@progbits,8
	.align 3
.LC5:
	.long	0
	.long	1071644672
	.align 3
.LC7:
	.long	0
	.long	1074528256
	.align 3
.LC9:
	.long	0
	.long	1074003968
	.align 3
.LC11:
	.long	0
	.long	1073217536
	.align 3
.LC13:
	.long	0
	.long	1072758784
	.align 3
.LC15:
	.long	0
	.long	1062207488
	.align 3
.LC17:
	.long	0
	.long	1073741824
	.align 3
.LC19:
	.long	0
	.long	1072693248
	.section	.rodata.cst16,"aM",@progbits,16
	.align 4
.LC29:
	.byte	30
	.byte	28
	.byte	26
	.byte	24
	.byte	22
	.byte	20
	.byte	18
	.byte	16
	.byte	14
	.byte	12
	.byte	10
	.byte	8
	.byte	6
	.byte	4
	.byte	2
	.byte	0
	.align 4
.LC30:
	.byte	31
	.byte	29
	.byte	27
	.byte	25
	.byte	23
	.byte	21
	.byte	19
	.byte	17
	.byte	15
	.byte	13
	.byte	11
	.byte	9
	.byte	7
	.byte	5
	.byte	3
	.byte	1
	.align 4
.LC31:
	.long	16
	.long	24
	.long	16
	.long	24
	.align 4
.LC32:
	.byte	29
	.byte	28
	.byte	25
	.byte	24
	.byte	21
	.byte	20
	.byte	17
	.byte	16
	.byte	13
	.byte	12
	.byte	9
	.byte	8
	.byte	5
	.byte	4
	.byte	1
	.byte	0
	.section	.rodata.cst8
	.align 3
.LC38:
	.long	0
	.long	1068498944
	.section	.rodata.cst16
	.align 4
.LC40:
	.long	0
	.long	1065353216
	.long	0
	.long	1065353216
	.set	.LC41,.LC40
	.section	.rodata
	.align 4
	.set	.LANCHOR0,. + 0
	.type	sigma.0, @object
	.size	sigma.0, 16
sigma.0:
	.long	1634760805
	.long	857760878
	.long	2036477234
	.long	1797285236
	.ident	"GCC: (GNU) 16.1.1 20260501 (Red Hat Cross 16.1.1-1)"
	.gnu_attribute 4, 1
	.section	.note.GNU-stack,"",@progbits
