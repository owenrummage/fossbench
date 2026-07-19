	.file	"fossbench-ppc32le.S"
	.machine ppc
	.section	".text"
	.align 2
	.type	sift, @function
sift:
.LFB14:
	.cfi_startproc
	slwi 10,5,1
	srwi 11,5,31
	stwu 1,-16(1)
	.cfi_def_cfa_offset 16
	addic 10,10,1
	slwi 9,6,1
	adde 11,11,9
	cmplw 0,8,11
	stw 31,12(1)
	.cfi_offset 31, -4
	mr 31,8
	ble- 0,.L15
.L11:
	slwi 9,5,2
	lwzx 8,3,9
.L8:
	addic 9,5,1
	slwi 4,10,2
	addze 6,6
	srwi 12,9,31
	lwzx 0,3,4
	slwi 6,6,1
	add 4,3,4
	add 6,12,6
	slwi 9,9,1
	cmplw 0,31,6
	mr 12,4
	bgt- 0,.L4
	bne- 0,.L7
	cmplw 0,7,9
	ble- 0,.L7
.L4:
	lwz 4,4(4)
	cmplw 0,4,0
	ble- 0,.L7
	slwi 12,9,2
	lwzx 0,3,12
	add 12,3,12
	cmplw 0,8,0
	bge- 0,.L1
.L17:
	slwi 10,9,1
	srwi 11,9,31
	addic 10,10,1
	slwi 4,6,1
	adde 11,11,4
	slwi 5,5,2
	cmplw 0,31,11
	stwx 0,3,5
	stw 8,0(12)
	ble- 0,.L16
	mr 5,9
	b .L8
.L7:
	cmplw 0,8,0
	mr 9,10
	mr 6,11
	blt+ 0,.L17
.L1:
	lwz 31,12(1)
	addi 1,1,16
	.cfi_remember_state
	.cfi_restore 31
	.cfi_def_cfa_offset 0
	blr
.L16:
	.cfi_restore_state
	bne- 0,.L1
	cmplw 0,7,10
	ble- 0,.L1
	mr 5,9
	b .L8
.L15:
	bne- 0,.L1
	cmplw 0,7,10
	bgt+ 0,.L11
	b .L1
	.cfi_endproc
.LFE14:
	.size	sift,.-sift
	.align 2
	.globl fb_int_math
	.type	fb_int_math, @function
fb_int_math:
.LFB1:
	.cfi_startproc
	stwu 1,-64(1)
	.cfi_def_cfa_offset 64
	or. 9,3,4
	stw 29,52(1)
	.cfi_offset 29, -12
	mr 29,3
	stw 30,56(1)
	.cfi_offset 30, -8
	mr 30,4
	beq- 0,.L18
	mflr 0
	.cfi_register 65, 0
	stw 21,20(1)
	.cfi_offset 21, -44
	lis 3,0x1331
	stw 0,68(1)
	.cfi_offset 65, 4
	lis 7,0x94d0
	lis 10,0x1ce4
	stw 22,24(1)
	.cfi_offset 22, -40
	lis 8,0xbf58
	lis 9,0x7f4a
	stw 27,44(1)
	.cfi_offset 27, -20
	lis 11,0x9e37
	lis 27,0x2545
	stw 28,48(1)
	.cfi_offset 28, -16
	lis 28,0xdead
	ori 27,27,0xf491
	stw 31,60(1)
	.cfi_offset 31, -4
	lis 31,0x4f6c
	ori 10,10,0xe5b9
	stw 23,28(1)
	.cfi_offset 23, -36
	ori 31,31,0xdd1d
	ori 8,8,0x476d
	stw 24,32(1)
	.cfi_offset 24, -32
	ori 23,11,0x79b9
	ori 24,9,0x7c15
	stw 25,36(1)
	.cfi_offset 25, -28
	ori 28,28,0xbeef
	ori 25,7,0x49bb
	stw 26,40(1)
	.cfi_offset 26, -24
	ori 26,3,0x11eb
.L21:
	mulhwu 7,24,28
	lis 5,0xdead
	li 6,0
	ori 5,5,0xbeef
	mullw 11,23,28
	mullw 9,24,28
	add 11,11,7
	mullw 12,8,28
	mulhwu 7,10,28
	addc 9,9,10
	adde 8,11,8
	mullw 10,10,28
	mullw 3,26,28
	add 12,12,7
	mullw 0,25,28
	addc 4,10,26
	adde 12,12,25
	mulhwu 7,26,28
	addc 3,3,31
	mulhwu 10,31,28
	mullw 11,27,28
	add 0,0,7
	srwi 7,3,29
	adde 27,0,27
	mullw 31,31,28
	slwi 0,27,3
	srwi 23,27,29
	add 0,0,7
	xor 23,23,8
	add 11,11,10
	xor 24,0,9
	srwi 0,24,31
	srwi 26,23,31
	addc 31,31,9
	slwi 7,24,1
	adde 11,11,8
	srwi 9,31,15
	slwi 10,11,17
	slwi 21,31,17
	add 9,9,10
	slwi 10,23,1
	xor 22,9,12
	add 7,7,26
	add 10,10,0
	xor 21,21,4
	xor 25,7,27
	srwi 8,21,7
	xor 26,10,3
	slwi 9,22,25
	add 9,9,8
	srwi 27,22,7
	mr 3,26
	mr 4,25
	xor 31,9,31
	xor 27,27,11
	bl __udivdi3
	lis 5,0xdead
	addc 24,3,24
	mr 11,4
	li 6,0
	ori 5,5,0xbeef
	mr 3,31
	mr 4,27
	adde 23,11,23
	bl __udivdi3
	addc 10,3,21
	adde 8,4,22
	addic 29,29,-1
	addme 30,30
	or. 9,29,30
	bne+ 0,.L21
	xor 4,25,27
	xor 3,26,31
	lwz 0,68(1)
	xor 4,4,23
	xor 3,3,24
	lwz 21,20(1)
	.cfi_restore 21
	lwz 22,24(1)
	.cfi_restore 22
	xor 4,4,8
	xor 3,3,10
	lwz 23,28(1)
	.cfi_restore 23
	mtlr 0
	.cfi_restore 65
	lwz 24,32(1)
	.cfi_restore 24
	lwz 25,36(1)
	.cfi_restore 25
	lwz 26,40(1)
	.cfi_restore 26
	lwz 27,44(1)
	.cfi_restore 27
	lwz 28,48(1)
	.cfi_restore 28
	lwz 31,60(1)
	.cfi_restore 31
.L18:
	lwz 29,52(1)
	lwz 30,56(1)
	addi 1,1,64
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	blr
	.cfi_endproc
.LFE1:
	.size	fb_int_math,.-fb_int_math
	.align 2
	.globl fb_fp_math
	.type	fb_fp_math, @function
fb_fp_math:
.LFB2:
	.cfi_startproc
	stwu 1,-112(1)
	.cfi_def_cfa_offset 112
	or. 9,3,4
	stw 30,48(1)
	.cfi_offset 30, -64
	mr 30,4
	stw 31,52(1)
	.cfi_offset 31, -60
	mr 31,3
	beq- 0,.L25
	lis 9,.LC5@ha
	stfd 31,104(1)
	.cfi_offset 63, -8
	lis 10,.LC1@ha
	lfs 31,.LC5@l(9)
	lis 9,.LC13@ha
	mflr 0
	.cfi_register 65, 0
	lfs 12,.LC13@l(9)
	lis 6,.LC3@ha
	lis 7,.LC7@ha
	stfd 29,88(1)
	.cfi_offset 61, -24
	lis 8,.LC9@ha
	lfs 29,.LC1@l(10)
	lis 10,.LC11@ha
	stfd 25,56(1)
	.cfi_offset 57, -56
	stfd 26,64(1)
	.cfi_offset 58, -48
	stfd 30,96(1)
	.cfi_offset 62, -16
	stw 0,116(1)
	.cfi_offset 65, 4
	stfd 27,72(1)
	.cfi_offset 59, -40
	stfd 28,80(1)
	.cfi_offset 60, -32
	lfs 30,.LC3@l(6)
	lfs 0,.LC7@l(7)
	lfs 25,.LC9@l(8)
	lfs 26,.LC11@l(10)
	stfs 12,24(1)
	stw 29,44(1)
	.cfi_offset 29, -68
	lis 29,.LC15@ha
	la 29,.LC15@l(29)
.L28:
	fmadd 1,0,25,26
	lfs 2,24(1)
	bl fmin
	lfs 2,24(1)
	fmr 28,1
	fmadd 1,31,25,26
	bl fmin
	lfs 2,24(1)
	fmr 27,1
	fmadd 1,30,25,26
	bl fmin
	fmr 30,1
	fmr 1,28
	bl sqrt
	lfs 2,24(1)
	fmr 0,1
	fmadd 1,29,25,26
	fadd 30,30,0
	bl fmin
	fmr 31,1
	fmr 1,27
	bl sqrt
	fadd 1,31,1
	bl fabs
	lfs 31,0(29)
	fmr 2,31
	bl fmax
	fadd 0,30,31
	addic 31,31,-1
	fadd 12,1,31
	addme 30,30
	or. 9,31,30
	fmr 29,1
	fdiv 0,31,0
	fdiv 31,31,12
	fadd 0,0,28
	fadd 31,31,27
	bne+ 0,.L28
	fadd 0,0,31
	addi 4,1,16
	li 5,8
	addi 3,1,8
	fadd 0,0,30
	fadd 0,0,1
	stfd 0,16(1)
	bl memcpy
	lwz 0,116(1)
	lfd 25,56(1)
	.cfi_restore 57
	lfd 26,64(1)
	.cfi_restore 58
	mtlr 0
	.cfi_restore 65
	lfd 27,72(1)
	.cfi_restore 59
	lfd 28,80(1)
	.cfi_restore 60
	lfd 29,88(1)
	.cfi_restore 61
	lfd 30,96(1)
	.cfi_restore 62
	lfd 31,104(1)
	.cfi_restore 63
	lwz 3,8(1)
	lwz 4,12(1)
	lwz 29,44(1)
	.cfi_restore 29
.L25:
	lwz 30,48(1)
	lwz 31,52(1)
	addi 1,1,112
	.cfi_restore 31
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	blr
	.cfi_endproc
.LFE2:
	.size	fb_fp_math,.-fb_fp_math
	.align 2
	.globl fb_primes
	.type	fb_primes, @function
fb_primes:
.LFB3:
	.cfi_startproc
	stwu 1,-48(1)
	.cfi_def_cfa_offset 48
	stw 30,40(1)
	.cfi_offset 30, -8
	mr. 30,4
	stw 27,28(1)
	.cfi_offset 27, -20
	mr 27,5
	stw 29,36(1)
	.cfi_offset 29, -12
	mr 29,3
	stw 31,44(1)
	.cfi_offset 31, -4
	mfcr 31
	beq- 0,.L54
.L46:
	mflr 0
	.cfi_register 65, 0
	mr 5,29
	stw 24,16(1)
	.cfi_offset 24, -32
	li 4,0
	mr 3,27
	stw 25,20(1)
	.cfi_offset 25, -28
	stw 0,52(1)
	.cfi_offset 65, 4
	bl memset
	addic 24,29,-1
	li 9,1
	addme 25,30
	stb 9,1(27)
	srwi 10,24,1
	stb 9,0(27)
	srwi. 9,25,1
	slwi 9,25,31
	add 9,9,10
	beq- 0,.L55
.L47:
	stw 26,24(1)
	.cfi_offset 26, -24
	li 31,2
	li 26,1
	stw 28,32(1)
	.cfi_offset 28, -16
	li 28,0
.L50:
	lbzx 9,27,31
	cmpwi 0,9,0
	beq- 0,.L56
.L37:
	addic 31,31,1
	mr 3,24
	addze 28,28
	mr 5,31
	mr 6,28
	mr 4,25
	bl __udivdi3
	cmplw 0,28,4
	bgt- 0,.L53
	bne+ 0,.L50
	cmplw 0,31,3
	ble+ 0,.L50
.L53:
	lwz 26,24(1)
	.cfi_restore 26
	lwz 28,32(1)
	.cfi_restore 28
.L43:
	addic 8,29,-2
	addi 27,27,1
	addme 9,30
	li 3,0
	li 4,0
.L45:
	lbzu 10,1(27)
	cntlzw 10,10
	srwi 10,10,5
	addc 3,10,3
	addze 4,4
	addic 8,8,-1
	addme 9,9
	or. 10,8,9
	bne+ 0,.L45
	lwz 0,52(1)
	lwz 24,16(1)
	.cfi_restore 24
	lwz 25,20(1)
	.cfi_restore 25
	mtlr 0
	.cfi_restore 65
	lwz 27,28(1)
	lwz 29,36(1)
	lwz 30,40(1)
	lwz 31,44(1)
	addi 1,1,48
	.cfi_restore 31
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 27
	.cfi_def_cfa_offset 0
	blr
.L56:
	.cfi_def_cfa_offset 48
	.cfi_offset 24, -32
	.cfi_offset 25, -28
	.cfi_offset 26, -24
	.cfi_offset 27, -20
	.cfi_offset 28, -16
	.cfi_offset 29, -12
	.cfi_offset 30, -8
	.cfi_offset 31, -4
	.cfi_offset 65, 4
	mullw 10,28,31
	mulhwu 8,31,31
	slwi 10,10,1
	mullw 9,31,31
	add 10,10,8
	cmplw 0,30,10
	ble- 0,.L57
.L49:
	addc 8,31,9
	stbx 26,27,9
	adde 10,28,10
	mr 9,8
	cmplw 0,30,10
	bgt+ 0,.L49
	cmplw 7,29,8
	bne- 0,.L37
	bgt+ 7,.L49
	b .L37
.L54:
	.cfi_restore 24
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 28
	.cfi_restore 65
	cmplwi 0,3,1
	bgt+ 0,.L46
.L33:
	lwz 27,28(1)
	li 3,0
	li 4,0
	lwz 29,36(1)
	lwz 30,40(1)
	lwz 31,44(1)
	addi 1,1,48
	.cfi_restore 31
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 27
	.cfi_def_cfa_offset 0
	blr
.L57:
	.cfi_def_cfa_offset 48
	.cfi_offset 24, -32
	.cfi_offset 25, -28
	.cfi_offset 26, -24
	.cfi_offset 27, -20
	.cfi_offset 28, -16
	.cfi_offset 29, -12
	.cfi_offset 30, -8
	.cfi_offset 31, -4
	.cfi_offset 65, 4
	bne- 0,.L37
	cmplw 0,29,9
	bgt+ 0,.L49
	b .L37
.L55:
	.cfi_restore 26
	.cfi_restore 28
	cmplwi 0,9,1
	bgt+ 0,.L47
	cmplwi 0,29,2
	bne- 0,.L43
	mtcrf 128,31
	bne- 0,.L43
	lwz 0,52(1)
	lwz 24,16(1)
	.cfi_restore 24
	lwz 25,20(1)
	.cfi_restore 25
	mtlr 0
	.cfi_restore 65
	b .L33
	.cfi_endproc
.LFE3:
	.size	fb_primes,.-fb_primes
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align 2
.LC24:
	.string	"rb"
	.align 2
.LC25:
	.string	"/proc/device-tree/compatible"
	.align 2
.LC26:
	.string	"/sys/firmware/devicetree/base/compatible"
	.section	".text"
	.align 2
	.globl fb_simd
	.type	fb_simd, @function
fb_simd:
.LFB7:
	.cfi_startproc
	or. 9,3,4
	mr 10,3
	mr 11,4
	beqlr- 0
	stwu 1,-80(1)
	.cfi_def_cfa_offset 80
	mflr 0
	lis 9,.LANCHOR0@ha
	stw 31,76(1)
	.cfi_register 65, 0
	.cfi_offset 31, -4
	mr 31,5
	stw 0,84(1)
	lwz 8,.LANCHOR0@l(9)
	cmpw 0,8,8
	bne- 0,$+4
	isync
	cmpwi 0,8,0
	la 8,.LANCHOR0@l(9)
	.cfi_offset 65, 4
	beq- 0,.L95
.L61:
	lwz 9,4(8)
	cmpwi 0,9,0
	beq- 0,.L96
	mr 3,10
	mr 5,31
	mtctr 9
	mr 4,11
	bctrl
	li 8,8
	li 10,0
	mtctr 8
	addi 5,31,-4
.L72:
	lwzu 9,4(5)
	xor 10,10,9
	bdnz .L72
	li 11,0
.L59:
	lwz 0,84(1)
	mr 3,10
	mr 4,11
	lwz 31,76(1)
	addi 1,1,80
	.cfi_remember_state
	.cfi_restore 31
	.cfi_def_cfa_offset 0
	mtlr 0
	.cfi_restore 65
	blr
.L95:
	.cfi_restore_state
	stw 3,40(1)
	li 3,16
	stw 29,68(1)
	.cfi_offset 29, -12
	stw 30,72(1)
	.cfi_offset 30, -8
	stw 4,44(1)
	bl getauxval
	lis 8,.LC24@ha
	mr 7,3
	la 9,.LC24@l(8)
	lis 3,.LC25@ha
	mr 4,9
	la 3,.LC25@l(3)
	mr 29,9
	mr 30,7
	bl fopen
	lwz 10,40(1)
	mr. 6,3
	lwz 11,44(1)
	beq- 0,.L97
.L62:
	addi 3,1,8
	li 5,9
	stw 11,48(1)
	li 4,1
	stw 10,44(1)
	stw 6,40(1)
	bl fread
	cmpwi 0,3,9
	lwz 6,40(1)
	lwz 10,44(1)
	lwz 11,48(1)
	beq- 0,.L98
.L64:
	mr 3,6
	stw 11,44(1)
	stw 10,40(1)
	bl fclose
	lis 9,.LANCHOR0@ha
	lwz 11,44(1)
	lwz 10,40(1)
.L63:
	mr 8,30
	lis 7,fb_simd_vsx_kernel@ha
	andi. 8,8,0x80
	la 7,fb_simd_vsx_kernel@l(7)
	bne- 0,.L65
	andis. 7,30,0x1000
	beq- 0,.L65
	lis 7,fb_simd_altivec_kernel@ha
	la 7,fb_simd_altivec_kernel@l(7)
.L65:
	la 8,.LANCHOR0@l(9)
	stw 7,4(8)
	lwsync
	li 7,1
	stw 7,.LANCHOR0@l(9)
	lwz 29,68(1)
	.cfi_remember_state
	.cfi_restore 29
	lwz 30,72(1)
	.cfi_restore 30
	b .L61
.L97:
	.cfi_restore_state
	lis 3,.LC26@ha
	mr 4,29
	la 3,.LC26@l(3)
	bl fopen
	lwz 10,40(1)
	lis 9,.LANCHOR0@ha
	mr. 6,3
	lwz 11,44(1)
	bne+ 0,.L62
	b .L63
.L96:
	.cfi_restore 29
	.cfi_restore 30
	addi 12,1,8
	li 5,32
	stw 11,44(1)
	mr 3,12
	mr 4,31
	stw 10,40(1)
	bl memcpy
	li 9,0
	lwz 10,40(1)
	li 5,0
	lwz 11,44(1)
	mtlr 9
	addi 12,1,8
.L68:
	addi 3,1,4
	li 9,8
	mr 6,3
	li 7,0
	mtctr 9
.L69:
	mr 8,7
	addi 7,7,1
	lwzu 4,4(6)
	rlwinm 0,7,2,27,29
	addi 9,8,3
	lwzx 0,12,0
	addi 8,8,5
	mullw 9,9,0
	add 9,9,4
	rotlw 9,9,8
	stw 9,0(6)
	bdnz .L69
	addic 5,5,1
	mflr 9
	cmplw 0,10,5
	addze 9,9
	mtlr 9
	bne+ 0,.L68
	cmplw 0,11,9
	bne+ 0,.L68
	li 9,8
	li 10,0
	mtctr 9
.L70:
	lwzu 9,4(3)
	xor 10,10,9
	bdnz .L70
	mr 4,12
	mr 3,31
	stw 10,40(1)
	li 5,32
	bl memcpy
	lwz 10,40(1)
	li 11,0
	b .L59
.L98:
	.cfi_offset 29, -12
	.cfi_offset 30, -8
	lis 4,.LANCHOR1@ha
	addi 3,1,8
	la 4,.LANCHOR1@l(4)
	li 5,9
	bl memcmp
	lis 9,.LANCHOR0@ha
	lwz 6,40(1)
	cmpwi 0,3,0
	lwz 10,44(1)
	mr 29,9
	lwz 11,48(1)
	bne- 0,.L64
	mr 3,6
	stw 11,44(1)
	stw 10,40(1)
	bl fclose
	lis 7,fb_simd_ps_kernel@ha
	mr 9,29
	lwz 10,40(1)
	la 7,fb_simd_ps_kernel@l(7)
	lwz 11,44(1)
	b .L65
	.cfi_endproc
.LFE7:
	.size	fb_simd,.-fb_simd
	.align 2
	.globl fb_compress
	.type	fb_compress, @function
fb_compress:
.LFB9:
	.cfi_startproc
	stwu 1,-96(1)
	.cfi_def_cfa_offset 96
	mflr 0
	li 4,0
	stw 25,68(1)
	.cfi_register 65, 0
	.cfi_offset 25, -28
	mr 25,5
	lis 5,0x4
	stw 26,72(1)
	.cfi_offset 26, -24
	mr 26,6
	stw 28,80(1)
	.cfi_offset 28, -16
	mr 28,3
	mr 3,7
	stw 18,40(1)
	stw 21,52(1)
	stw 29,84(1)
	.cfi_offset 18, -56
	.cfi_offset 21, -44
	.cfi_offset 29, -12
	mr 29,7
	stw 0,100(1)
	.cfi_offset 65, 4
	bl memset
	cmpwi 0,26,0
	addic 21,25,1
	addze 18,26
	beq- 0,.L131
.L120:
	addic 9,25,-12
	stw 24,64(1)
	.cfi_offset 24, -32
	lis 24,0x9e37
	stw 14,24(1)
	.cfi_offset 14, -72
	ori 24,24,0x79b1
	mr 14,9
	stw 17,36(1)
	.cfi_offset 17, -60
	li 17,0
	stw 19,44(1)
	.cfi_offset 19, -52
	li 19,0
	stw 20,48(1)
	.cfi_offset 20, -48
	li 20,0
	stw 22,56(1)
	.cfi_offset 22, -40
	addme 22,26
	stw 23,60(1)
	.cfi_offset 23, -36
	li 23,0
	stw 27,76(1)
	.cfi_offset 27, -20
	li 27,0
	stw 30,88(1)
	.cfi_offset 30, -8
	li 30,0
	stw 31,92(1)
	.cfi_offset 31, -4
	li 31,0
	stw 15,28(1)
	.cfi_offset 15, -68
	stw 16,32(1)
	.cfi_offset 16, -64
	b .L127
.L121:
	subfc 10,16,31
	subfe 9,19,30
	cmpwi 0,9,0
	bne- 0,.L102
	cmplwi 0,10,65535
	bgt- 0,.L102
	li 5,4
	add 4,28,16
	addi 3,1,8
	bl memcpy
	lwz 9,8(1)
	cmplw 0,15,9
	beq- 0,.L132
.L102:
	addic 31,31,1
	addze 30,30
.L108:
	cmplw 0,22,30
	ble- 0,.L133
.L127:
	li 5,4
	add 4,28,31
	addi 3,1,8
	bl memcpy
	lwz 15,8(1)
	cmplwi 0,30,0
	mullw 9,15,24
	rlwinm 9,9,18,14,29
	lwzx 16,29,9
	stwx 31,29,9
	bgt+ 0,.L121
	bne- 0,.L102
	cmplw 0,31,16
	bgt+ 0,.L121
	b .L102
.L133:
	bne- 0,.L125
	cmplw 0,14,31
	bgt+ 0,.L127
.L125:
	addc 21,27,21
	lwz 0,100(1)
	adde 18,23,18
	subfc 21,20,21
	lwz 14,24(1)
	.cfi_remember_state
	.cfi_restore 14
	subfe 18,17,18
	mr 3,21
	lwz 15,28(1)
	.cfi_restore 15
	mr 4,18
	lwz 16,32(1)
	.cfi_restore 16
	mtlr 0
	.cfi_restore 65
	lwz 17,36(1)
	.cfi_restore 17
	lwz 19,44(1)
	.cfi_restore 19
	lwz 20,48(1)
	.cfi_restore 20
	lwz 22,56(1)
	.cfi_restore 22
	lwz 23,60(1)
	.cfi_restore 23
	lwz 24,64(1)
	.cfi_restore 24
	lwz 27,76(1)
	.cfi_restore 27
	lwz 30,88(1)
	.cfi_restore 30
	lwz 31,92(1)
	.cfi_restore 31
	lwz 18,40(1)
	lwz 21,52(1)
	lwz 25,68(1)
	lwz 26,72(1)
	lwz 28,80(1)
	lwz 29,84(1)
	addi 1,1,96
	.cfi_restore 29
	.cfi_restore 28
	.cfi_restore 26
	.cfi_restore 25
	.cfi_restore 21
	.cfi_restore 18
	.cfi_def_cfa_offset 0
	blr
.L132:
	.cfi_restore_state
	addic 3,31,4
	addze 7,30
	cmplw 0,26,7
	ble- 0,.L134
.L119:
	li 9,4
	li 8,0
	b .L126
.L112:
	addc 3,6,31
	mr 9,6
	adde 7,4,30
	mr 8,4
	cmplw 0,26,7
	ble- 0,.L135
.L126:
	add 10,28,9
	addic 6,9,1
	lbzx 5,10,31
	addze 4,8
	lbzx 10,10,16
	cmpw 0,5,10
	beq+ 0,.L112
	cmpwi 0,8,0
	li 10,1
	beq- 0,.L136
	mr 9,10
.L129:
	li 8,0
.L107:
	subfc 31,20,31
	li 10,1
	subfe 30,17,30
	addic 27,27,3
	cmpwi 0,30,0
	addze 23,23
	addc 27,27,31
	adde 23,23,30
	bne- 0,.L115
	subfic 31,31,14
	subfe 10,10,10
	rlwinm 10,10,0,31,31
.L115:
	addc 27,27,10
	mr 20,3
	addze 23,23
	addc 27,27,9
	mr 17,7
	mr 31,3
	adde 23,23,8
	mr 30,7
	b .L108
.L131:
	.cfi_restore 14
	.cfi_restore 15
	.cfi_restore 16
	.cfi_restore 17
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 22
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 27
	.cfi_restore 30
	.cfi_restore 31
	cmplwi 0,25,15
	bgt+ 0,.L120
	lwz 0,100(1)
	mr 3,21
	mr 4,18
	lwz 18,40(1)
	lwz 21,52(1)
	mtlr 0
	.cfi_restore 65
	lwz 25,68(1)
	lwz 26,72(1)
	lwz 28,80(1)
	lwz 29,84(1)
	addi 1,1,96
	.cfi_restore 29
	.cfi_restore 28
	.cfi_restore 26
	.cfi_restore 25
	.cfi_restore 21
	.cfi_restore 18
	.cfi_def_cfa_offset 0
	blr
.L135:
	.cfi_def_cfa_offset 96
	.cfi_offset 14, -72
	.cfi_offset 15, -68
	.cfi_offset 16, -64
	.cfi_offset 17, -60
	.cfi_offset 18, -56
	.cfi_offset 19, -52
	.cfi_offset 20, -48
	.cfi_offset 21, -44
	.cfi_offset 22, -40
	.cfi_offset 23, -36
	.cfi_offset 24, -32
	.cfi_offset 25, -28
	.cfi_offset 26, -24
	.cfi_offset 27, -20
	.cfi_offset 28, -16
	.cfi_offset 29, -12
	.cfi_offset 30, -8
	.cfi_offset 31, -4
	.cfi_offset 65, 4
	cmplw 7,25,3
	bne- 0,.L124
	bgt+ 7,.L126
.L124:
	cmpwi 0,4,0
	li 9,1
	bne- 0,.L129
	subfic 6,6,18
	subfe 10,10,10
	neg 10,10
	neg 10,10
	and 9,9,10
	b .L129
.L136:
	subfic 9,9,18
	subfe 9,9,9
	neg 9,9
	neg 9,9
	and 10,10,9
	mr 9,10
	b .L129
.L134:
	bne- 0,.L123
	cmplw 0,25,3
	bgt+ 0,.L119
.L123:
	li 9,0
	li 8,0
	b .L107
	.cfi_endproc
.LFE9:
	.size	fb_compress,.-fb_compress
	.align 2
	.globl fb_chacha20
	.type	fb_chacha20, @function
fb_chacha20:
.LFB12:
	.cfi_startproc
	stwu 1,-224(1)
	.cfi_def_cfa_offset 224
	mr 4,6
	stw 18,168(1)
	.cfi_offset 18, -56
	rlwinm 18,5,0,0,25
	or. 8,18,6
	beq- 0,.L137
	stw 26,200(1)
	.cfi_offset 26, -24
	mr 26,9
	or. 9,26,10
	stw 25,196(1)
	.cfi_offset 25, -28
	mr 25,10
	bne- 0,.L163
	mr 18,26
	lwz 25,196(1)
	.cfi_restore 25
	mr 4,10
	lwz 26,200(1)
	.cfi_restore 26
.L137:
	mr 3,18
	lwz 18,168(1)
	addi 1,1,224
	.cfi_restore 18
	.cfi_def_cfa_offset 0
	blr
.L163:
	.cfi_def_cfa_offset 224
	.cfi_offset 18, -56
	.cfi_offset 25, -28
	.cfi_offset 26, -24
	lis 4,.LANCHOR1@ha
	stw 21,180(1)
	.cfi_offset 21, -44
	mflr 0
	.cfi_register 65, 0
	la 4,.LANCHOR1@l(4)
	mr 21,3
	stw 22,184(1)
	.cfi_offset 22, -40
	addi 3,1,72
	addi 4,4,12
	stw 23,188(1)
	.cfi_offset 23, -36
	li 5,16
	stw 31,220(1)
	.cfi_offset 31, -4
	mr 22,6
	stw 0,228(1)
	.cfi_offset 65, 4
	mr 31,7
	li 23,8
	stw 14,152(1)
	.cfi_offset 14, -72
	stw 15,156(1)
	.cfi_offset 15, -68
	stw 16,160(1)
	.cfi_offset 16, -64
	stw 17,164(1)
	.cfi_offset 17, -60
	stw 19,172(1)
	.cfi_offset 19, -52
	stw 20,176(1)
	.cfi_offset 20, -48
	stw 24,192(1)
	.cfi_offset 24, -32
	stw 27,204(1)
	.cfi_offset 27, -20
	stw 28,208(1)
	.cfi_offset 28, -16
	stw 29,212(1)
	.cfi_offset 29, -12
	stw 30,216(1)
	.cfi_offset 30, -8
	bl memcpy
	li 9,8
	addi 6,1,84
	mtctr 9
.L141:
	lbz 7,1(31)
	addi 23,23,-1
	addi 31,31,4
	lbz 8,-4(31)
	lbz 10,-2(31)
	lbz 9,-1(31)
	rlwimi 8,7,8,0,31-8
	slwi 10,10,16
	or 10,10,8
	slwi 9,9,24
	or 9,9,10
	stwu 9,4(6)
	bdnz .L141
	li 29,0
	li 28,0
	stw 23,132(1)
	stw 23,128(1)
	mr 17,18
	li 27,0
	stw 23,124(1)
	mr 18,21
	addi 20,1,4
	stw 29,136(1)
	addi 19,1,68
	mr 21,22
	stw 28,140(1)
	stw 25,144(1)
.L142:
	lwz 24,136(1)
	li 25,0
	li 22,0
	mr 14,27
	mr 15,26
.L156:
	li 5,64
	addi 4,1,72
	stw 24,120(1)
	addi 3,1,8
	addi 24,24,1
	bl memcpy
	li 9,10
	lwz 0,8(1)
	mtctr 9
	lwz 4,56(1)
	lwz 9,24(1)
	lwz 31,40(1)
	lwz 29,12(1)
	lwz 7,28(1)
	lwz 5,60(1)
	lwz 28,44(1)
	lwz 30,16(1)
	lwz 8,32(1)
	lwz 6,64(1)
	lwz 26,48(1)
	lwz 11,20(1)
	lwz 10,36(1)
	lwz 3,68(1)
	lwz 27,52(1)
.L143:
	add 0,9,0
	add 29,7,29
	add 30,8,30
	add 11,10,11
	xor 4,0,4
	xor 5,29,5
	xor 6,30,6
	xor 3,11,3
	rotlwi 4,4,16
	rotlwi 5,5,16
	rotlwi 6,6,16
	rotlwi 3,3,16
	add 31,4,31
	add 28,5,28
	add 26,26,6
	add 27,27,3
	xor 9,31,9
	xor 7,28,7
	xor 8,26,8
	xor 10,27,10
	rotlwi 9,9,12
	rotlwi 7,7,12
	rotlwi 8,8,12
	rotlwi 10,10,12
	add 0,0,9
	add 29,29,7
	add 30,30,8
	add 11,11,10
	xor 4,0,4
	xor 5,29,5
	xor 6,30,6
	xor 3,11,3
	rotlwi 4,4,8
	rotlwi 5,5,8
	rotlwi 6,6,8
	rotlwi 3,3,8
	add 31,31,4
	add 28,28,5
	add 26,26,6
	add 27,27,3
	xor 9,31,9
	xor 7,28,7
	xor 8,26,8
	xor 10,27,10
	rotlwi 9,9,7
	rotlwi 7,7,7
	rotlwi 8,8,7
	rotlwi 10,10,7
	add 0,0,7
	add 29,29,8
	add 11,11,9
	add 30,30,10
	xor 4,29,4
	xor 6,11,6
	xor 3,0,3
	xor 5,30,5
	rotlwi 4,4,16
	rotlwi 6,6,16
	rotlwi 3,3,16
	rotlwi 5,5,16
	add 28,28,6
	add 26,26,3
	add 27,27,4
	add 31,31,5
	xor 9,28,9
	xor 7,26,7
	xor 8,27,8
	xor 10,31,10
	rotlwi 9,9,12
	rotlwi 7,7,12
	rotlwi 8,8,12
	rotlwi 10,10,12
	add 11,11,9
	add 0,0,7
	add 29,29,8
	add 30,30,10
	xor 6,11,6
	xor 3,0,3
	xor 4,29,4
	xor 5,30,5
	rotlwi 6,6,8
	rotlwi 3,3,8
	rotlwi 4,4,8
	rotlwi 5,5,8
	add 28,28,6
	add 26,26,3
	add 27,27,4
	add 31,31,5
	xor 9,28,9
	xor 7,26,7
	xor 8,27,8
	xor 10,31,10
	rotlwi 9,9,7
	rotlwi 7,7,7
	rotlwi 8,8,7
	rotlwi 10,10,7
	bdnz .L143
	stw 26,48(1)
	mr 16,20
	mr 12,19
	stw 7,28(1)
	stw 29,12(1)
	stw 4,56(1)
	stw 27,52(1)
	stw 8,32(1)
	stw 30,16(1)
	stw 5,60(1)
	stw 31,40(1)
	stw 10,36(1)
	stw 11,20(1)
	stw 6,64(1)
	stw 28,44(1)
	stw 9,24(1)
	stw 0,8(1)
	li 0,16
	stw 3,68(1)
	mtctr 0
	add 3,18,25
.L144:
	lwzu 10,4(12)
	addi 3,3,4
	lwzu 9,4(16)
	lbz 11,-3(3)
	add 9,9,10
	lbz 4,-2(3)
	lbz 5,-1(3)
	srwi 6,9,8
	srwi 7,9,16
	lbz 10,-4(3)
	srwi 8,9,24
	xor 6,6,11
	xor 7,7,4
	xor 8,8,5
	stb 6,-3(3)
	xor 10,9,10
	stb 7,-2(3)
	xor 23,23,9
	stb 8,-1(3)
	stb 10,-4(3)
	bdnz .L144
	addic 25,25,64
	addze 22,22
	cmplw 0,21,22
	bgt+ 0,.L156
	bne- 0,.L150
	cmplw 0,17,25
	bgt+ 0,.L156
.L150:
	lwz 8,140(1)
	addic 10,17,-1
	mr 26,15
	addme 9,21
	srwi 10,10,6
	addic 28,8,1
	slwi 9,9,26
	cmplw 0,15,28
	add 9,9,10
	lwz 10,136(1)
	addi 9,9,1
	stw 28,140(1)
	addze 27,14
	add 9,10,9
	stw 9,136(1)
	bne+ 0,.L142
	lwz 9,144(1)
	cmplw 0,9,27
	bne+ 0,.L142
	lwz 0,228(1)
	mr 18,23
	li 4,0
	mr 3,18
	lwz 14,152(1)
	.cfi_restore 14
	lwz 15,156(1)
	.cfi_restore 15
	mtlr 0
	.cfi_restore 65
	lwz 16,160(1)
	.cfi_restore 16
	lwz 17,164(1)
	.cfi_restore 17
	lwz 19,172(1)
	.cfi_restore 19
	lwz 20,176(1)
	.cfi_restore 20
	lwz 21,180(1)
	.cfi_restore 21
	lwz 22,184(1)
	.cfi_restore 22
	lwz 23,188(1)
	.cfi_restore 23
	lwz 24,192(1)
	.cfi_restore 24
	lwz 25,196(1)
	.cfi_restore 25
	lwz 26,200(1)
	.cfi_restore 26
	lwz 27,204(1)
	.cfi_restore 27
	lwz 28,208(1)
	.cfi_restore 28
	lwz 29,212(1)
	.cfi_restore 29
	lwz 30,216(1)
	.cfi_restore 30
	lwz 31,220(1)
	.cfi_restore 31
	lwz 18,168(1)
	addi 1,1,224
	.cfi_restore 18
	.cfi_def_cfa_offset 0
	blr
	.cfi_endproc
.LFE12:
	.size	fb_chacha20,.-fb_chacha20
	.align 2
	.globl fb_physics
	.type	fb_physics, @function
fb_physics:
.LFB13:
	.cfi_startproc
	lis 9,.LC28@ha
	stwu 1,-160(1)
	.cfi_def_cfa_offset 160
	lfs 0,.LC28@l(9)
	or. 9,5,6
	stw 23,68(1)
	.cfi_offset 23, -92
	mr 23,6
	stfs 0,24(1)
	stw 25,76(1)
	.cfi_offset 25, -84
	mr 25,5
	lfs 0,24(1)
	stfd 0,8(1)
	beq- 0,.L177
	or. 9,7,8
	stw 18,48(1)
	.cfi_offset 18, -112
	mr 18,8
	stw 20,56(1)
	.cfi_offset 20, -104
	mr 20,7
	beq- 0,.L178
	mflr 0
	.cfi_register 65, 0
	lis 9,.LC30@ha
	stfd 25,104(1)
	.cfi_offset 57, -56
	stw 0,164(1)
	.cfi_offset 65, 4
	stw 17,44(1)
	.cfi_offset 17, -116
	stw 26,80(1)
	.cfi_offset 26, -80
	stw 28,88(1)
	.cfi_offset 28, -72
	stw 29,92(1)
	.cfi_offset 29, -68
	stw 30,96(1)
	.cfi_offset 30, -64
	stw 31,100(1)
	.cfi_offset 31, -60
	stfd 26,112(1)
	.cfi_offset 58, -48
	stfd 27,120(1)
	.cfi_offset 59, -40
	stfd 28,128(1)
	.cfi_offset 60, -32
	stfd 29,136(1)
	.cfi_offset 61, -24
	stfd 30,144(1)
	.cfi_offset 62, -16
	stfd 31,152(1)
	.cfi_offset 63, -8
	lfs 25,.LC30@l(9)
	stw 22,64(1)
	.cfi_offset 22, -96
	lis 22,.LC32@ha
	stw 27,84(1)
	.cfi_offset 27, -76
	lis 27,.LC15@ha
	la 22,.LC32@l(22)
	stw 19,52(1)
	.cfi_offset 19, -108
	la 27,.LC15@l(27)
	li 19,0
	stw 21,60(1)
	.cfi_offset 21, -100
	li 21,0
	stw 24,72(1)
	.cfi_offset 24, -88
	mr 24,3
.L168:
	mr 28,24
	li 26,0
	li 17,0
.L175:
	lfs 26,24(1)
	mr 30,24
	mr 31,25
	mr 29,23
	fmr 27,26
	fmr 28,26
.L169:
	lfd 0,8(30)
	addi 30,30,64
	lfd 12,8(28)
	fsub 30,0,12
	lfd 0,-64(30)
	lfd 12,0(28)
	fmul 1,30,30
	fsub 29,0,12
	lfd 0,-48(30)
	lfd 12,16(28)
	fmadd 1,29,29,1
	fsub 31,0,12
	fmadd 1,31,31,1
	fadd 1,1,25
	bl sqrt
	lfs 0,0(27)
	addic 31,31,-1
	lfd 12,-40(30)
	addme 29,29
	or. 9,31,29
	fdiv 0,0,1
	fmul 1,0,0
	fmul 1,1,0
	fmul 1,1,12
	fmadd 28,29,1,28
	fmadd 27,30,1,27
	fmadd 26,31,1,26
	bne+ 0,.L169
	lis 9,.LC31@ha
	lfd 11,32(28)
	addic 26,26,1
	lfd 12,.LC31@l(9)
	cmplw 0,25,26
	addze 17,17
	lfs 0,0(22)
	addi 28,28,64
	fmadd 28,28,12,11
	lfd 11,-24(28)
	fmadd 27,27,12,11
	lfd 11,-16(28)
	stfd 28,-32(28)
	fmadd 26,26,12,11
	stfd 27,-24(28)
	stfd 26,-16(28)
	bne+ 0,.L175
	cmplw 0,23,17
	bne+ 0,.L175
	mr 9,24
	mtctr 25
.L172:
	lfd 11,0(9)
	addi 9,9,64
	lfd 12,-32(9)
	lfd 10,-56(9)
	fmadd 12,12,0,11
	lfd 11,-24(9)
	stfd 12,-64(9)
	fmadd 11,11,0,10
	lfd 12,-16(9)
	lfd 10,-48(9)
	stfd 11,-56(9)
	fmadd 12,12,0,10
	stfd 12,-48(9)
	bdnz .L172
	addic 21,21,1
	cmplw 0,20,21
	addze 19,19
	bne+ 0,.L168
	cmplw 0,18,19
	bne+ 0,.L168
	andi. 9,25,0x1
	lfd 11,8(1)
	addi 9,24,32
	addi 10,25,-1
	beq- 0,.L183
	lfd 0,0(9)
	cmpwi 0,10,0
	lfd 10,8(9)
	lfd 12,16(9)
	addi 9,24,96
	fadd 0,0,10
	fadd 0,0,12
	fadd 11,11,0
	beq- 0,.L189
.L183:
	srwi 10,25,1
	mtctr 10
.L176:
	lfd 0,0(9)
	mr 10,9
	addi 9,9,128
	lfd 12,-120(9)
	lfd 8,-112(9)
	lfd 9,-56(9)
	fadd 12,0,12
	lfd 0,-64(9)
	lfd 10,80(10)
	fadd 12,12,8
	fadd 0,0,9
	fadd 11,11,12
	fadd 0,0,10
	fadd 11,11,0
	bdnz .L176
.L189:
	addi 4,1,8
	addi 3,1,16
	stfd 11,8(1)
	li 5,8
	bl memcpy
	lwz 0,164(1)
	lwz 3,16(1)
	lwz 4,20(1)
	mtlr 0
	.cfi_restore 65
	lfd 25,104(1)
	.cfi_restore 57
	lfd 26,112(1)
	.cfi_restore 58
	lfd 27,120(1)
	.cfi_restore 59
	lfd 28,128(1)
	.cfi_restore 60
	lfd 29,136(1)
	.cfi_restore 61
	lfd 30,144(1)
	.cfi_restore 62
	lfd 31,152(1)
	.cfi_restore 63
	lwz 17,44(1)
	.cfi_restore 17
	lwz 18,48(1)
	.cfi_restore 18
	lwz 19,52(1)
	.cfi_restore 19
	lwz 20,56(1)
	.cfi_restore 20
	lwz 21,60(1)
	.cfi_restore 21
	lwz 22,64(1)
	.cfi_restore 22
	lwz 24,72(1)
	.cfi_restore 24
	lwz 26,80(1)
	.cfi_restore 26
	lwz 27,84(1)
	.cfi_restore 27
	lwz 28,88(1)
	.cfi_restore 28
	lwz 29,92(1)
	.cfi_restore 29
	lwz 30,96(1)
	.cfi_restore 30
	lwz 31,100(1)
	.cfi_restore 31
	lwz 23,68(1)
	lwz 25,76(1)
	addi 1,1,160
	.cfi_restore 25
	.cfi_restore 23
	.cfi_def_cfa_offset 0
	blr
.L178:
	.cfi_def_cfa_offset 160
	.cfi_offset 18, -112
	.cfi_offset 20, -104
	.cfi_offset 23, -92
	.cfi_offset 25, -84
	lwz 18,48(1)
	.cfi_restore 18
	mr 3,7
	mr 4,8
	lwz 20,56(1)
	.cfi_restore 20
	lwz 23,68(1)
	lwz 25,76(1)
	addi 1,1,160
	.cfi_restore 25
	.cfi_restore 23
	.cfi_def_cfa_offset 0
	blr
.L177:
	.cfi_def_cfa_offset 160
	.cfi_offset 23, -92
	.cfi_offset 25, -84
	lwz 23,68(1)
	mr 3,5
	mr 4,6
	lwz 25,76(1)
	addi 1,1,160
	.cfi_restore 25
	.cfi_restore 23
	.cfi_def_cfa_offset 0
	blr
	.cfi_endproc
.LFE13:
	.size	fb_physics,.-fb_physics
	.align 2
	.globl fb_sort
	.type	fb_sort, @function
fb_sort:
.LFB15:
	.cfi_startproc
	stwu 1,-32(1)
	.cfi_def_cfa_offset 32
	stw 28,16(1)
	.cfi_offset 28, -16
	mr. 28,6
	stw 27,12(1)
	.cfi_offset 27, -20
	mr 27,3
	stw 29,20(1)
	.cfi_offset 29, -12
	mr 29,5
	stw 30,24(1)
	stw 31,28(1)
	.cfi_offset 30, -8
	.cfi_offset 31, -4
	beq- 0,.L207
.L194:
	mflr 0
	.cfi_register 65, 0
	stw 26,8(1)
	.cfi_offset 26, -24
	slwi 31,28,31
	stw 0,36(1)
	.cfi_offset 65, 4
	srwi 9,29,1
	srwi 30,28,1
	add 31,31,9
.L198:
	addic 31,31,-1
	mr 7,29
	addme 30,30
	mr 5,31
	mr 6,30
	mr 8,28
	mr 3,27
	bl sift
	or. 9,31,30
	bne+ 0,.L198
	addic 30,29,-1
	addi 9,27,4
	slwi 26,30,2
	addme 31,28
	add 26,26,9
.L199:
	lwz 9,0(27)
	mr 7,30
	mr 8,31
	lwzu 10,-4(26)
	li 6,0
	li 5,0
	mr 3,27
	stw 10,0(27)
	stw 9,0(26)
	bl sift
	addic 30,30,-1
	addme 31,31
	or. 9,30,31
	bne+ 0,.L199
	addi 27,27,-4
.L200:
	srwi 8,30,7
	lwzu 10,4(27)
	slwi 9,31,25
	add 9,9,8
	srwi 31,31,7
	xor 9,10,9
	slwi 8,30,25
	addc 30,10,9
	adde 31,8,31
	addic 29,29,-1
	addme 28,28
	or. 9,29,28
	bne+ 0,.L200
	lwz 0,36(1)
	mr 3,30
	mr 4,31
	lwz 26,8(1)
	.cfi_restore 26
	lwz 27,12(1)
	mtlr 0
	.cfi_restore 65
	lwz 28,16(1)
	lwz 29,20(1)
	lwz 30,24(1)
	lwz 31,28(1)
	addi 1,1,32
	.cfi_restore 31
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 28
	.cfi_restore 27
	.cfi_def_cfa_offset 0
	blr
.L207:
	.cfi_def_cfa_offset 32
	.cfi_offset 27, -20
	.cfi_offset 28, -16
	.cfi_offset 29, -12
	.cfi_offset 30, -8
	.cfi_offset 31, -4
	cmplwi 0,5,1
	bgt+ 0,.L194
	cmpwi 0,5,0
	bne- 0,.L208
	li 30,0
	li 31,0
	lwz 27,12(1)
	mr 3,30
	mr 4,31
	lwz 28,16(1)
	lwz 29,20(1)
	lwz 30,24(1)
	lwz 31,28(1)
	addi 1,1,32
	.cfi_remember_state
	.cfi_restore 31
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 28
	.cfi_restore 27
	.cfi_def_cfa_offset 0
	blr
.L208:
	.cfi_restore_state
	lwz 30,0(3)
	li 31,0
	mr 4,31
	lwz 27,12(1)
	mr 3,30
	lwz 28,16(1)
	lwz 29,20(1)
	lwz 30,24(1)
	lwz 31,28(1)
	addi 1,1,32
	.cfi_restore 31
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 28
	.cfi_restore 27
	.cfi_def_cfa_offset 0
	blr
	.cfi_endproc
.LFE15:
	.size	fb_sort,.-fb_sort
	.align 2
	.globl fb_chase
	.type	fb_chase, @function
fb_chase:
.LFB16:
	.cfi_startproc
	or. 9,5,6
	beq- 0,.L213
	mr 9,3
.L212:
	addic 5,5,-1
	lwz 9,0(9)
	addme 6,6
	or. 10,5,6
	bne+ 0,.L212
	subf 3,3,9
	li 4,0
	blr
.L213:
	mr 3,5
	mr 4,6
	blr
	.cfi_endproc
.LFE16:
	.size	fb_chase,.-fb_chase
	.section	.rodata.cst4,"aM",@progbits,4
	.align 2
.LC1:
	.long	1056964608
	.align 2
.LC3:
	.long	1080033280
	.align 2
.LC5:
	.long	1075838976
	.align 2
.LC7:
	.long	1069547520
	.align 2
.LC9:
	.long	1065877504
	.align 2
.LC11:
	.long	981467136
	.align 2
.LC13:
	.long	1073741824
	.set	.LC15,.LC31+4
	.set	.LC28,.LC31
	.align 2
.LC30:
	.long	1031798784
	.section	.rodata.cst8,"aM",@progbits,8
	.align 3
.LC31:
	.long	0
	.long	1065353216
	.section	.rodata.cst4
	.align 2
.LC32:
	.long	1006632960
	.section	.rodata
	.align 2
	.set	.LANCHOR1,. + 0
	.type	prefix.1, @object
	.size	prefix.1, 10
prefix.1:
	.string	"nintendo,"
	.zero	2
	.type	sigma.0, @object
	.size	sigma.0, 16
sigma.0:
	.long	1634760805
	.long	857760878
	.long	2036477234
	.long	1797285236
	.section	".bss"
	.align 2
	.set	.LANCHOR0,. + 0
	.type	detected.4, @object
	.size	detected.4, 4
detected.4:
	.zero	4
	.type	kernel.3, @object
	.size	kernel.3, 4
kernel.3:
	.zero	4
	.globl __udivdi3
	.ident	"GCC: (GNU) 16.1.1 20260501 (Red Hat Cross 16.1.1-1)"
	.gnu_attribute 4, 1
	.section	.note.GNU-stack,"",@progbits
/* Optional PPC32 extended-instruction kernels.  No instruction in this file
 * is reached until fossbench-powerpc.c has checked the device tree or AT_HWCAP.
 * Arguments use the PPC32 ABI: iters in r3:r4 and memory in r5. */

	.text
	.align 2

	.globl fb_simd_ps_kernel
	.type fb_simd_ps_kernel,@function
fb_simd_ps_kernel:
	/* Raw encodings keep this buildable with standard Linux binutils, whose
	 * opcode tables do not always name Nintendo's Gekko/Broadway extension. */
	.long 0xe0050000 /* psq_l  f0,0(r5),0,0 */
	.long 0xe0250008 /* psq_l  f1,8(r5),0,0 */
1:	.long 0x1000082a /* ps_add f0,f0,f1 */
	.long 0x10210032 /* ps_mul f1,f1,f0 */
	.long 0x1000082a /* ps_add f0,f0,f1 */
	.long 0x10210032 /* ps_mul f1,f1,f0 */
	addic. 4,4,-1
	addme 3,3
	or. 6,3,4
	bne 1b
	.long 0xf0050000 /* psq_st f0,0(r5),0,0 */
	.long 0xf0250008 /* psq_st f1,8(r5),0,0 */
	blr
	.size fb_simd_ps_kernel,.-fb_simd_ps_kernel

	.globl fb_simd_vsx_kernel
	.type fb_simd_vsx_kernel,@function
fb_simd_vsx_kernel:
	.machine power7
	li 6,0
	lxvw4x 0,6,5
	li 6,16
	lxvw4x 1,6,5
1:	xvaddsp 0,0,1
	xvmulsp 1,1,0
	xvaddsp 0,0,1
	xvmulsp 1,1,0
	addic. 4,4,-1
	addme 3,3
	or. 6,3,4
	bne 1b
	li 6,0
	stxvw4x 0,6,5
	li 6,16
	stxvw4x 1,6,5
	blr
	.size fb_simd_vsx_kernel,.-fb_simd_vsx_kernel

	.globl fb_simd_altivec_kernel
	.type fb_simd_altivec_kernel,@function
fb_simd_altivec_kernel:
	.machine altivec
	li 6,0
	lvx 0,6,5
	li 6,16
	lvx 1,6,5
1:	vadduwm 0,0,1
	vxor 1,1,0
	vadduwm 0,0,1
	vxor 1,1,0
	addic. 4,4,-1
	addme 3,3
	or. 6,3,4
	bne 1b
	li 6,0
	stvx 0,6,5
	li 6,16
	stvx 1,6,5
	blr
	.size fb_simd_altivec_kernel,.-fb_simd_altivec_kernel

	.section .note.GNU-stack,"",@progbits
