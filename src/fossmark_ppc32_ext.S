/* Optional PPC32 extended-instruction kernels.  No instruction in this file
 * is reached until fossmark_ppc32.c has checked the device tree or AT_HWCAP.
 * Arguments use the PPC32 ABI: iters in r3:r4 and memory in r5. */

	.text
	.align 2

	.globl fm_simd_ps_kernel
	.type fm_simd_ps_kernel,@function
fm_simd_ps_kernel:
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
	.size fm_simd_ps_kernel,.-fm_simd_ps_kernel

	.globl fm_simd_vsx_kernel
	.type fm_simd_vsx_kernel,@function
fm_simd_vsx_kernel:
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
	.size fm_simd_vsx_kernel,.-fm_simd_vsx_kernel

	.globl fm_simd_altivec_kernel
	.type fm_simd_altivec_kernel,@function
fm_simd_altivec_kernel:
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
	.size fm_simd_altivec_kernel,.-fm_simd_altivec_kernel

	.section .note.GNU-stack,"",@progbits
