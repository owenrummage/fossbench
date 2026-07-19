/* fossbench-ppc32be.S - 32-bit big-endian PowerPC benchmark kernels.
 * SysV PPC32 ABI. Includes scalar kernels and guarded paired-single,
 * AltiVec, and VSX SIMD implementations selected through Linux HWCAP. */
        .file   "fossbench-ppc32be.S"
        .machine ppc
        .machine altivec
        .section        ".text"
        .align 2
        .globl fb_int_math
        .type   fb_int_math, @function
fb_int_math:
        .cfi_startproc
        stwu 1,-64(1)
        .cfi_def_cfa_offset 64
        or. 9,3,4
        mflr 0
        stw 29,52(1)
        .cfi_register 65, 0
        .cfi_offset 29, -12
        mr 29,3
        stw 31,60(1)
        .cfi_offset 31, -4
        mr 31,4
        stw 0,68(1)
        .cfi_offset 65, 4
        beq- 0,.L1
        stw 20,16(1)
        .cfi_offset 20, -48
        lis 10,0x4f6c
        lis 9,0x94d0
        stw 24,32(1)
        .cfi_offset 24, -32
        lis 4,0x1331
        lis 8,0xbf58
        stw 28,48(1)
        .cfi_offset 28, -16
        lis 7,0x1ce4
        lis 28,0x2545
        lis 12,0x9e37
        lis 3,0x7f4a
        stw 21,20(1)
        .cfi_offset 21, -44
        stw 22,24(1)
        .cfi_offset 22, -40
        ori 28,28,0xf491
        ori 21,8,0x476d
        stw 23,28(1)
        .cfi_offset 23, -36
        ori 22,3,0x7c15
        ori 23,12,0x79b9
        stw 25,36(1)
        .cfi_offset 25, -28
        ori 25,9,0x49bb
        stw 26,40(1)
        .cfi_offset 26, -24
        ori 26,4,0x11eb
        stw 27,44(1)
        .cfi_offset 27, -20
        ori 27,10,0xdd1d
        ori 10,7,0xe5b9
.L4:
        lis 9,0xdead
        lis 6,0xdead
        ori 9,9,0xbeef
        li 5,0
        mulhwu 4,22,9
        ori 6,6,0xbeef
        mullw 12,23,9
        mullw 3,22,9
        add 12,12,4
        mulhwu 4,10,9
        addc 3,3,10
        mullw 10,10,9
        adde 24,12,21
        mullw 7,21,9
        mulhwu 23,26,9
        addc 12,10,26
        mullw 11,25,9
        add 7,7,4
        adde 25,7,25
        mullw 0,26,9
        mulhwu 10,27,9
        add 11,11,23
        mullw 8,28,9
        addc 0,0,27
        adde 28,11,28
        srwi 7,0,29
        mullw 9,27,9
        slwi 11,28,3
        srwi 23,28,29
        add 11,11,7
        xor 23,23,24
        add 8,8,10
        xor 22,11,3
        srwi 27,23,31
        slwi 10,22,1
        addc 9,9,3
        srwi 3,22,31
        adde 24,8,24
        srwi 7,9,15
        slwi 8,24,17
        slwi 20,9,17
        add 7,7,8
        slwi 8,23,1
        xor 21,7,25
        xor 20,20,12
        add 8,8,3
        add 10,10,27
        xor 25,10,28
        srwi 7,20,7
        xor 26,8,0
        slwi 10,21,25
        add 10,10,7
        srwi 28,21,7
        mr 3,25
        mr 4,26
        xor 27,10,9
        xor 28,28,24
        bl __udivdi3@plt
        lis 6,0xdead
        addc 22,4,22
        mr 12,3
        mr 4,27
        mr 3,28
        li 5,0
        ori 6,6,0xbeef
        adde 23,12,23
        bl __udivdi3@plt
        addc 10,4,20
        adde 21,3,21
        addic 31,31,-1
        addme 29,29
        or. 9,29,31
        bne+ 0,.L4
        xor 3,25,28
        xor 4,26,27
        lwz 20,16(1)
        .cfi_restore 20
        xor 3,3,23
        xor 4,4,22
        lwz 23,28(1)
        .cfi_restore 23
        xor 3,3,21
        lwz 22,24(1)
        .cfi_restore 22
        xor 4,4,10
        lwz 21,20(1)
        .cfi_restore 21
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
.L1:
        lwz 0,68(1)
        lwz 29,52(1)
        lwz 31,60(1)
        mtlr 0
        .cfi_restore 65
        addi 1,1,64
        .cfi_restore 31
        .cfi_restore 29
        .cfi_def_cfa_offset 0
        blr
        .cfi_endproc
        .size   fb_int_math, .-fb_int_math
        .section        ".got2","aw"
        .align 2
.LCTOC1 = .+32768
.LC2:
        .long .LC1
.LC5:
        .long .LC4
.LC8:
        .long .LC7
.LC11:
        .long .LC10
.LC14:
        .long .LC13
.LC17:
        .long .LC16
        .section        ".text"
        .align 2
        .globl fb_fp_math
.LCL1:
        .long .LCTOC1-.LCF1
        .type   fb_fp_math, @function
fb_fp_math:
        .cfi_startproc
        stwu 1,-128(1)
        .cfi_def_cfa_offset 128
        mflr 0
        .cfi_register 65, 0
        bcl 20,31,.LCF1
.LCF1:
        or. 9,3,4
        stw 24,32(1)
        .cfi_offset 24, -96
        mr 24,4
        stw 28,48(1)
        .cfi_offset 28, -80
        mr 28,3
        stw 30,56(1)
        .cfi_offset 30, -72
        mflr 30
        stw 0,132(1)
        .cfi_offset 65, 4
        lwz 0,.LCL1-.LCF1(30)
        add 30,0,30
        beq- 0,.L9
        stw 27,44(1)
        .cfi_offset 27, -84
        lwz 27,.LC2-.LCTOC1(30)
        stfd 29,104(1)
        .cfi_offset 61, -24
        lfs 29,0(27)
        lwz 10,.LC5-.LCTOC1(30)
        lwz 9,.LC8-.LCTOC1(30)
        stw 23,28(1)
        .cfi_offset 23, -100
        stw 25,36(1)
        .cfi_offset 25, -92
        stw 26,40(1)
        .cfi_offset 26, -88
        stw 29,52(1)
        .cfi_offset 29, -76
        li 29,0
        stw 31,60(1)
        .cfi_offset 31, -68
        li 31,0
        stfd 26,80(1)
        .cfi_offset 58, -48
        fmr 26,29
        stfd 27,88(1)
        .cfi_offset 59, -40
        stfd 28,96(1)
        .cfi_offset 60, -32
        stfd 24,64(1)
        .cfi_offset 56, -64
        stfd 25,72(1)
        .cfi_offset 57, -56
        stfd 30,112(1)
        .cfi_offset 62, -16
        stfd 31,120(1)
        .cfi_offset 63, -8
        lfs 27,0(10)
        lfs 28,0(9)
        lwz 25,.LC11-.LCTOC1(30)
        lwz 26,.LC14-.LCTOC1(30)
        lwz 23,.LC17-.LCTOC1(30)
        b .L14
.L16:
        lfs 24,0(25)
        lfs 26,0(26)
        lfs 25,0(27)
        fmul 29,29,24
        fmul 30,30,24
        fmr 2,25
        fadd 1,29,26
        fmul 31,31,24
        bl fmin@plt
        fmr 2,25
        fmr 29,1
        fadd 1,30,26
        bl fmin@plt
        fmr 2,25
        fmr 27,1
        fadd 1,31,26
        bl fmin@plt
        fmr 26,1
.L14:
        fmr 1,27
        bl sqrt@plt
        lfs 0,0(25)
        lfs 12,0(26)
        fadd 29,1,29
        lfs 2,0(27)
        fmul 0,28,0
        fadd 1,0,12
        bl fmin@plt
        fmr 30,1
        fmr 1,26
        bl sqrt@plt
        lfs 31,0(23)
        fadd 1,30,1
        fmr 2,31
        fabs 1,1
        fadd 30,29,31
        bl fmax@plt
        addic 31,31,1
        fadd 0,1,31
        addze 29,29
        fdiv 30,31,30
        cmplw 0,28,29
        fdiv 31,31,0
        fmr 28,1
        fadd 30,30,27
        fadd 31,31,26
        bne+ 0,.L16
        cmplw 0,24,31
        bne+ 0,.L16
        fadd 30,30,31
        lfd 24,64(1)
        .cfi_restore 56
        lfd 25,72(1)
        .cfi_restore 57
        lfd 26,80(1)
        .cfi_restore 58
        fadd 30,30,29
        lfd 27,88(1)
        .cfi_restore 59
        lfd 28,96(1)
        .cfi_restore 60
        lfd 29,104(1)
        .cfi_restore 61
        fadd 0,30,1
        lfd 31,120(1)
        .cfi_restore 63
        lfd 30,112(1)
        .cfi_restore 62
        lwz 23,28(1)
        .cfi_restore 23
        stfd 0,8(1)
        lwz 25,36(1)
        .cfi_restore 25
        lwz 26,40(1)
        .cfi_restore 26
        lwz 3,8(1)
        lwz 4,12(1)
        lwz 27,44(1)
        .cfi_restore 27
        lwz 29,52(1)
        .cfi_restore 29
        lwz 31,60(1)
        .cfi_restore 31
.L9:
        lwz 0,132(1)
        lwz 24,32(1)
        lwz 28,48(1)
        mtlr 0
        .cfi_restore 65
        lwz 30,56(1)
        addi 1,1,128
        .cfi_restore 30
        .cfi_restore 28
        .cfi_restore 24
        .cfi_def_cfa_offset 0
        blr
        .cfi_endproc
        .size   fb_fp_math, .-fb_fp_math
        .align 2
        .globl fb_primes
        .type   fb_primes, @function
fb_primes:
        .cfi_startproc
        stwu 1,-64(1)
        .cfi_def_cfa_offset 64
        mflr 0
        stw 28,48(1)
        .cfi_register 65, 0
        .cfi_offset 28, -16
        mr. 28,3
        stw 23,28(1)
        .cfi_offset 23, -36
        mr 23,5
        stw 29,52(1)
        .cfi_offset 29, -12
        mr 29,4
        stw 31,60(1)
        .cfi_offset 31, -4
        mfcr 31
        stw 0,68(1)
        .cfi_offset 65, 4
        beq- 0,.L41
.L33:
        mr 5,29
        li 4,0
        stw 25,36(1)
        .cfi_offset 25, -28
        mr 3,23
        stw 26,40(1)
        .cfi_offset 26, -24
        bl memset@plt
        addic 25,29,-1
        li 9,257
        addme 26,28
        sth 9,0(23)
        srwi 10,25,1
        srwi. 9,26,1
        slwi 9,26,31
        add 9,9,10
        beq- 0,.L42
.L34:
        stw 24,32(1)
        .cfi_offset 24, -32
        li 31,2
        li 24,0
        stw 27,44(1)
        .cfi_offset 27, -20
        li 27,1
.L37:
        lbzx 9,23,31
        cmpwi 0,9,0
        beq- 0,.L43
.L24:
        addic 31,31,1
        mr 3,26
        addze 24,24
        mr 6,31
        mr 5,24
        mr 4,25
        bl __udivdi3@plt
        cmplw 0,24,3
        bgt- 0,.L40
        bne+ 0,.L37
        cmplw 0,31,4
        ble+ 0,.L37
.L40:
        lwz 24,32(1)
        .cfi_restore 24
        lwz 27,44(1)
        .cfi_restore 27
.L30:
        addic 10,29,-2
        addi 23,23,1
        addme 28,28
        li 3,0
        li 4,0
.L32:
        lbzu 9,1(23)
        cntlzw 9,9
        srwi 9,9,5
        addc 4,9,4
        addze 3,3
        addic 10,10,-1
        addme 28,28
        or. 9,28,10
        bne+ 0,.L32
        lwz 0,68(1)
        lwz 25,36(1)
        .cfi_restore 25
        lwz 26,40(1)
        .cfi_restore 26
        mtlr 0
        .cfi_restore 65
        lwz 23,28(1)
        lwz 28,48(1)
        lwz 29,52(1)
        lwz 31,60(1)
        addi 1,1,64
        .cfi_restore 31
        .cfi_restore 29
        .cfi_restore 28
        .cfi_restore 23
        .cfi_def_cfa_offset 0
        blr
.L43:
        .cfi_def_cfa_offset 64
        .cfi_offset 23, -36
        .cfi_offset 24, -32
        .cfi_offset 25, -28
        .cfi_offset 26, -24
        .cfi_offset 27, -20
        .cfi_offset 28, -16
        .cfi_offset 29, -12
        .cfi_offset 31, -4
        .cfi_offset 65, 4
        mullw 10,24,31
        mulhwu 8,31,31
        slwi 10,10,1
        mullw 9,31,31
        add 10,10,8
        cmplw 0,28,10
        ble- 0,.L44
.L36:
        addc 8,31,9
        stbx 27,23,9
        adde 10,24,10
        mr 9,8
        cmplw 0,28,10
        bgt+ 0,.L36
        cmplw 7,29,8
        bne- 0,.L24
        bgt+ 7,.L36
        b .L24
.L41:
        .cfi_restore 24
        .cfi_restore 25
        .cfi_restore 26
        .cfi_restore 27
        cmplwi 0,4,1
        bgt+ 0,.L33
.L20:
        lwz 0,68(1)
        li 3,0
        li 4,0
        lwz 23,28(1)
        lwz 28,48(1)
        mtlr 0
        .cfi_restore 65
        lwz 29,52(1)
        lwz 31,60(1)
        addi 1,1,64
        .cfi_restore 31
        .cfi_restore 29
        .cfi_restore 28
        .cfi_restore 23
        .cfi_def_cfa_offset 0
        blr
.L44:
        .cfi_def_cfa_offset 64
        .cfi_offset 23, -36
        .cfi_offset 24, -32
        .cfi_offset 25, -28
        .cfi_offset 26, -24
        .cfi_offset 27, -20
        .cfi_offset 28, -16
        .cfi_offset 29, -12
        .cfi_offset 31, -4
        .cfi_offset 65, 4
        bne- 0,.L24
        cmplw 0,29,9
        bgt+ 0,.L36
        b .L24
.L42:
        .cfi_restore 24
        .cfi_restore 27
        cmplwi 0,9,1
        bgt+ 0,.L34
        mtcrf 128,31
        bne- 0,.L30
        cmplwi 0,29,2
        bne- 0,.L30
        lwz 25,36(1)
        .cfi_restore 25
        lwz 26,40(1)
        .cfi_restore 26
        b .L20
        .cfi_endproc
        .size   fb_primes, .-fb_primes
        .section        .rodata.str1.4,"aMS",@progbits,1
        .align 2
.LC19:
        .string "rb"
        .align 2
.LC21:
        .string "/proc/device-tree/compatible"
        .align 2
.LC23:
        .string "/sys/firmware/devicetree/base/compatible"
        .section        ".got2","aw"
.LC18:
        .long .LANCHOR0
.LC20:
        .long .LC19
.LC22:
        .long .LC21
.LC24:
        .long .LC23
.LC26:
        .long fb_simd_ps_kernel
.LC27:
        .long fb_simd_vsx_kernel
.LC28:
        .long fb_simd_altivec_kernel
        .section        ".text"
        .align 2
        .globl fb_simd
.LCL3:
        .long .LCTOC1-.LCF3
        .type   fb_simd, @function
fb_simd:
        .cfi_startproc
        or. 10,3,4
        mr 8,3
        mr 9,4
        beqlr- 0
        stwu 1,-128(1)
        .cfi_def_cfa_offset 128
        mflr 0
        .cfi_register 65, 0
        bcl 20,31,.LCF3
.LCF3:
        stw 30,120(1)
        .cfi_offset 30, -8
        mflr 30
        stw 31,124(1)
        .cfi_offset 31, -4
        mr 31,5
        stw 0,132(1)
        .cfi_offset 65, 4
        lwz 0,.LCL3-.LCF3(30)
        add 30,0,30
        lwz 10,.LC18-.LCTOC1(30)
        lwz 7,0(10)
        cmpw 0,7,7
        bne- 0,$+4
        isync
        cmpwi 0,7,0
        beq- 0,.L72
.L48:
        lwz 10,4(10)
        cmpwi 0,10,0
        beq- 0,.L73
        mr 3,8
        mr 4,9
        mtctr 10
        mr 5,31
        bctrl
        lwz 10,4(31)
        li 8,0
        lwz 9,8(31)
        lwz 7,0(31)
        xor 9,9,10
        lwz 10,12(31)
        xor 9,9,7
        lwz 7,16(31)
        xor 9,9,10
        lwz 10,20(31)
        xor 9,9,7
        lwz 7,24(31)
        xor 9,9,10
        lwz 10,28(31)
        xor 9,9,7
        xor 9,9,10
.L46:
        lwz 0,132(1)
        mr 3,8
        mr 4,9
        lwz 30,120(1)
        lwz 31,124(1)
        mtlr 0
        .cfi_remember_state
        .cfi_restore 65
        addi 1,1,128
        .cfi_restore 31
        .cfi_restore 30
        .cfi_def_cfa_offset 0
        blr
.L72:
        .cfi_restore_state
        stw 3,80(1)
        li 3,16
        stw 10,88(1)
        stw 28,112(1)
        .cfi_offset 28, -16
        stw 29,116(1)
        .cfi_offset 29, -12
        stw 4,84(1)
        bl getauxval@plt
        mr 29,3
        lwz 4,.LC20-.LCTOC1(30)
        lwz 3,.LC22-.LCTOC1(30)
        mr 28,4
        bl fopen@plt
        lwz 8,80(1)
        mr. 6,3
        lwz 9,84(1)
        lwz 10,88(1)
        beq- 0,.L74
.L49:
        addi 3,1,16
        li 5,9
        stw 10,92(1)
        li 4,1
        stw 9,88(1)
        stw 8,84(1)
        stw 6,80(1)
        bl fread@plt
        cmpwi 0,3,9
        lwz 6,80(1)
        lwz 8,84(1)
        lwz 9,88(1)
        lwz 10,92(1)
        beq- 0,.L75
.L51:
        mr 3,6
        stw 10,88(1)
        stw 9,84(1)
        stw 8,80(1)
        bl fclose@plt
        lwz 10,88(1)
        lwz 9,84(1)
        lwz 8,80(1)
.L50:
        mr 7,29
        andi. 7,7,0x80
        bne- 0,.L76
        andis. 7,29,0x1000
        beq- 0,.L54
        lwz 7,.LC28-.LCTOC1(30)
.L54:
        stw 7,4(10)
        lwsync
        li 7,1
        stw 7,0(10)
        lwz 28,112(1)
        .cfi_remember_state
        .cfi_restore 28
        lwz 29,116(1)
        .cfi_restore 29
        b .L48
.L75:
        .cfi_restore_state
        lwz 5,16(1)
        lis 7,0x6e69
        ori 7,7,0x6e74
        cmpw 0,5,7
        bne+ 0,.L51
        lwz 5,20(1)
        lis 7,0x656e
        ori 7,7,0x646f
        cmpw 0,5,7
        bne+ 0,.L51
        lbz 7,24(1)
        cmpwi 0,7,44
        bne+ 0,.L51
        mr 3,6
        stw 10,88(1)
        stw 9,84(1)
        stw 8,80(1)
        bl fclose@plt
        lwz 7,.LC26-.LCTOC1(30)
        lwz 8,80(1)
        lwz 9,84(1)
        lwz 10,88(1)
        b .L54
.L76:
        lwz 7,.LC27-.LCTOC1(30)
        b .L54
.L73:
        .cfi_restore 28
        .cfi_restore 29
        stw 27,108(1)
        .cfi_offset 27, -20
        stw 28,112(1)
        .cfi_offset 28, -16
        stw 29,116(1)
        .cfi_offset 29, -12
        lwz 10,0(31)
        lwz 0,4(31)
        mr 28,10
        lwz 10,8(31)
        lwz 11,12(31)
        mr 27,10
        lwz 10,20(31)
        lwz 3,16(31)
        mtlr 10
        lwz 10,24(31)
        lwz 12,28(31)
        mtctr 10
.L57:
        slwi 10,0,1
        slwi 4,12,3
        add 10,10,0
        add 4,4,12
        add 10,10,28
        mflr 29
        rotlwi 6,10,5
        rlwinm 10,10,7,0,29
        add 10,10,6
        mr 28,6
        slwi 10,10,1
        addic 9,9,-1
        add 12,10,12
        mflr 10
        slwi 6,10,3
        mfctr 10
        slwi 5,11,2
        add 4,4,10
        slwi 10,10,3
        slwi 7,3,1
        add 10,10,29
        add 5,5,11
        addme 8,8
        mtlr 10
        add 7,7,3
        add 5,5,27
        or. 10,8,9
        rotlwi 10,4,11
        slwi 7,7,1
        mtctr 10
        rotlwi 10,5,7
        add 7,7,11
        subf 6,29,6
        slwi 11,27,2
        mr 27,10
        mflr 10
        add 0,11,0
        add 3,6,3
        rotlwi 10,10,10
        rotlwi 12,12,12
        rotlwi 11,7,8
        rotlwi 0,0,6
        rotlwi 3,3,9
        mtlr 10
        bne+ 0,.L57
        mflr 6
        stw 11,28(1)
        li 10,16
        vxor 0,0,0
        stw 6,36(1)
        mfctr 6
        li 7,32
        stw 6,40(1)
        li 9,64
        mflr 6
        stw 0,20(1)
        li 8,0
        stw 27,24(1)
        stw 3,32(1)
        stw 12,44(1)
        stw 28,16(1)
        lwz 11,20(1)
        lwz 4,28(1)
        lvx 1,1,7
        lvx 13,1,10
        lwz 5,32(1)
        vxor 13,13,1
        vsldoi 1,13,0,8
        vxor 1,1,13
        vsldoi 0,1,0,4
        vxor 0,0,1
        stvx 0,1,9
        stw 28,0(31)
        lwz 7,40(1)
        lwz 10,44(1)
        lwz 9,64(1)
        stw 11,4(31)
        stw 27,8(31)
        stw 4,12(31)
        stw 5,16(31)
        stw 6,20(31)
        stw 7,24(31)
        stw 10,28(31)
        lwz 27,108(1)
        .cfi_restore 27
        lwz 28,112(1)
        .cfi_restore 28
        lwz 29,116(1)
        .cfi_restore 29
        b .L46
.L74:
        .cfi_offset 28, -16
        .cfi_offset 29, -12
        lwz 3,.LC24-.LCTOC1(30)
        mr 4,28
        bl fopen@plt
        lwz 8,80(1)
        mr. 6,3
        lwz 9,84(1)
        lwz 10,88(1)
        bne+ 0,.L49
        b .L50
        .cfi_endproc
        .size   fb_simd, .-fb_simd
        .align 2
        .globl fb_compress
        .type   fb_compress, @function
fb_compress:
        .cfi_startproc
        stwu 1,-80(1)
        .cfi_def_cfa_offset 80
        mflr 0
        li 4,0
        stw 28,64(1)
        .cfi_register 65, 0
        .cfi_offset 28, -16
        mr 28,5
        lis 5,0x4
        stw 31,76(1)
        .cfi_offset 31, -4
        mr 31,3
        mr 3,7
        stw 23,44(1)
        stw 27,60(1)
        .cfi_offset 23, -36
        .cfi_offset 27, -20
        mr 27,6
        stw 29,68(1)
        .cfi_offset 29, -12
        mr 29,7
        stw 0,84(1)
        .cfi_offset 65, 4
        bl memset@plt
        cmpwi 0,28,0
        addic 9,27,1
        mtlr 9
        addze 23,28
        beq- 0,.L108
.L98:
        addic 9,27,-12
        stw 19,28(1)
        .cfi_offset 19, -52
        li 3,0
        stw 26,56(1)
        .cfi_offset 26, -24
        mr 19,9
        lis 26,0x9e37
        li 9,0
        stw 24,48(1)
        .cfi_offset 24, -32
        ori 26,26,0x79b1
        stw 25,52(1)
        .cfi_offset 25, -28
        li 7,0
        addme 25,28
        stw 20,32(1)
        .cfi_offset 20, -48
        mtctr 9
        li 4,0
        stw 21,36(1)
        .cfi_offset 21, -44
        li 8,0
        li 24,0
        stw 22,40(1)
        .cfi_offset 22, -40
        b .L105
.L99:
        subfc 6,0,9
        subfe 10,24,8
        cmpwi 0,10,0
        bne- 0,.L80
        cmplwi 0,6,65535
        bgt- 0,.L80
        lwzx 10,31,0
        cmpw 0,10,11
        beq- 0,.L109
.L80:
        addic 9,9,1
        addze 8,8
        cmplw 0,25,8
        ble- 0,.L110
.L105:
        lwzx 11,31,9
        cmplwi 0,8,0
        mullw 10,11,26
        rlwinm 10,10,18,14,29
        lwzx 0,29,10
        stwx 9,29,10
        bgt+ 0,.L99
        bne- 0,.L80
        cmplw 0,9,0
        bgt+ 0,.L99
        b .L80
.L109:
        addic 20,9,4
        addze 6,8
        cmplw 0,28,6
        ble- 0,.L111
.L97:
        li 12,0
        li 10,4
        b .L104
.L90:
        addc 20,5,9
        mr 10,5
        adde 6,21,8
        mr 12,21
        cmplw 0,28,6
        ble- 0,.L112
.L104:
        add 11,31,10
        addic 5,10,1
        lbzx 22,11,9
        addze 21,12
        lbzx 11,11,0
        cmpw 0,22,11
        beq+ 0,.L90
        cmpwi 0,12,0
        li 11,1
        beq- 0,.L113
.L91:
        li 5,0
.L85:
        subfc 4,4,9
        mfctr 10
        subfe 8,10,8
        addic 7,7,3
        cmpwi 0,8,0
        addze 3,3
        addc 7,7,4
        li 9,1
        adde 3,3,8
        bne- 0,.L93
        subfic 4,4,14
        subfe 9,9,9
        rlwinm 9,9,0,31,31
.L93:
        mr 8,6
        addc 7,7,9
        cmplw 0,25,8
        addze 3,3
        addc 7,7,11
        mtctr 6
        mr 4,20
        adde 3,3,5
        mr 9,20
        bgt+ 0,.L105
.L110:
        bne- 0,.L103
        cmplw 0,19,9
        bgt+ 0,.L105
.L103:
        mflr 9
        lwz 0,84(1)
        addc 7,7,9
        lwz 19,28(1)
        .cfi_restore 19
        adde 23,3,23
        subfc 9,4,7
        lwz 20,32(1)
        .cfi_restore 20
        mtlr 9
        mfctr 9
        lwz 21,36(1)
        .cfi_restore 21
        subfe 23,9,23
        mflr 4
        lwz 22,40(1)
        .cfi_restore 22
        mr 3,23
        lwz 24,48(1)
        .cfi_restore 24
        mtlr 0
        .cfi_restore 65
        lwz 25,52(1)
        .cfi_restore 25
        lwz 26,56(1)
        .cfi_restore 26
        lwz 23,44(1)
        lwz 27,60(1)
        lwz 28,64(1)
        lwz 29,68(1)
        lwz 31,76(1)
        addi 1,1,80
        .cfi_restore 31
        .cfi_restore 29
        .cfi_restore 28
        .cfi_restore 27
        .cfi_restore 23
        .cfi_def_cfa_offset 0
        blr
.L108:
        .cfi_def_cfa_offset 80
        .cfi_offset 23, -36
        .cfi_offset 27, -20
        .cfi_offset 28, -16
        .cfi_offset 29, -12
        .cfi_offset 31, -4
        .cfi_offset 65, 4
        cmplwi 0,27,15
        bgt+ 0,.L98
        lwz 0,84(1)
        mr 3,23
        mflr 4
        lwz 23,44(1)
        lwz 27,60(1)
        mtlr 0
        .cfi_restore 65
        lwz 28,64(1)
        lwz 29,68(1)
        lwz 31,76(1)
        addi 1,1,80
        .cfi_restore 31
        .cfi_restore 29
        .cfi_restore 28
        .cfi_restore 27
        .cfi_restore 23
        .cfi_def_cfa_offset 0
        blr
.L112:
        .cfi_def_cfa_offset 80
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
        .cfi_offset 31, -4
        .cfi_offset 65, 4
        cmplw 7,27,20
        bne- 0,.L102
        bgt+ 7,.L104
.L102:
        cmpwi 0,21,0
        li 11,1
        bne- 0,.L91
        subfic 5,5,18
        subfe 10,10,10
        neg 10,10
        neg 10,10
        and 11,11,10
        b .L91
.L113:
        subfic 10,10,18
        subfe 10,10,10
        neg 10,10
        neg 10,10
        and 11,11,10
        b .L91
.L111:
        bne- 0,.L101
        cmplw 0,27,20
        bgt+ 0,.L97
.L101:
        li 5,0
        li 11,0
        b .L85
        .cfi_endproc
        .size   fb_compress, .-fb_compress
        .section        ".got2","aw"
.LC29:
        .long .LANCHOR1
.LC31:
        .long .LC30
.LC33:
        .long .LC32
.LC35:
        .long .LC34
.LC37:
        .long .LC36
.LC39:
        .long .LC38
.LC41:
        .long .LC40
        .section        ".text"
        .align 2
        .globl fb_chacha20
.LCL5:
        .long .LCTOC1-.LCF5
        .type   fb_chacha20, @function
fb_chacha20:
        .cfi_startproc
        stwu 1,-512(1)
        .cfi_def_cfa_offset 512
        mflr 0
        rlwinm 4,6,0,0,25
        .cfi_register 65, 0
        bcl 20,31,.LCF5
.LCF5:
        or. 8,5,4
        stw 0,516(1)
        .cfi_offset 65, 4
        li 0,336
        stw 24,480(1)
        .cfi_offset 24, -32
        mr 24,3
        mr 3,5
        stw 30,504(1)
        stvx 26,1,0
        li 0,352
        .cfi_offset 30, -8
        .cfi_offset 103, -176
        mflr 30
        stvx 27,1,0
        li 0,368
        stvx 28,1,0
        li 0,384
        stvx 29,1,0
        li 0,400
        stvx 30,1,0
        li 0,416
        stvx 31,1,0
        lwz 0,.LCL5-.LCF5(30)
        add 30,0,30
        .cfi_offset 104, -160
        .cfi_offset 105, -144
        .cfi_offset 106, -128
        .cfi_offset 107, -112
        .cfi_offset 108, -96
        beq- 0,.L114
        stw 28,496(1)
        .cfi_offset 28, -16
        mr 28,9
        or. 9,28,10
        stw 16,448(1)
        .cfi_offset 16, -64
        mr 16,10
        beq- 0,.L125
        addic 9,4,-1
        stw 17,452(1)
        .cfi_offset 17, -60
        addi 8,24,64
        vxor 30,30,30
        addme 10,5
        stw 19,460(1)
        .cfi_offset 19, -52
        srwi 9,9,6
        stw 20,464(1)
        .cfi_offset 20, -48
        slwi 10,10,26
        slwi 4,9,6
        stw 21,468(1)
        .cfi_offset 21, -44
        add 9,10,9
        li 10,16
        stw 22,472(1)
        .cfi_offset 22, -40
        li 5,80
        addi 17,9,1
        stw 26,488(1)
        .cfi_offset 26, -24
        add 9,8,4
        li 26,0
        stw 27,492(1)
        .cfi_offset 27, -20
        li 19,0
        li 27,0
        stw 29,500(1)
        .cfi_offset 29, -12
        li 22,16
        li 29,0
        stw 14,440(1)
        .cfi_offset 14, -72
        li 21,32
        li 20,48
        stw 15,444(1)
        .cfi_offset 15, -68
        vspltish 31,8
        stw 18,456(1)
        .cfi_offset 18, -56
        stw 23,476(1)
        .cfi_offset 23, -36
        stw 25,484(1)
        .cfi_offset 25, -28
        stw 31,508(1)
        .cfi_offset 31, -4
        lwz 3,.LC29-.LCTOC1(30)
        lwz 6,.LC31-.LCTOC1(30)
        lvx 1,3,10
        addi 10,7,15
        stvx 1,1,5
        addi 3,7,31
        lvx 0,0,6
        neg 6,7
        lvx 29,0,10
        li 5,96
        lvsr 1,0,6
        li 10,0
        li 6,112
        lvx 28,0,7
        lvx 13,0,3
        vperm 28,28,29,1
        stw 9,304(1)
        vperm 28,28,28,0
        stw 10,140(1)
        vperm 29,29,13,1
        stvx 28,1,5
        vperm 29,29,29,0
        stw 10,136(1)
        stvx 29,1,6
        vor 26,28,28
        vor 27,29,29
        stw 10,132(1)
        stw 24,320(1)
        stw 28,324(1)
        stw 16,332(1)
        stw 17,328(1)
.L118:
        stw 27,308(1)
        mr 17,27
        stw 29,312(1)
        stw 26,316(1)
        lwz 23,320(1)
.L122:
        li 5,64
        addi 4,1,80
        stw 17,128(1)
        addi 3,1,16
        mr 24,17
        bl memcpy@plt
        li 9,10
        lwz 29,16(1)
        addi 17,17,1
        mtctr 9
        lwz 7,32(1)
        mr 8,24
        lwz 31,48(1)
        lwz 27,20(1)
        lwz 6,36(1)
        lwz 5,68(1)
        lwz 0,52(1)
        lwz 28,24(1)
        lwz 9,40(1)
        lwz 3,72(1)
        lwz 25,56(1)
        lwz 11,28(1)
        lwz 10,44(1)
        lwz 4,76(1)
        lwz 26,60(1)
.L119:
        add 29,29,7
        add 27,27,6
        add 28,9,28
        add 11,10,11
        xor 8,29,8
        xor 5,27,5
        xor 3,28,3
        xor 4,11,4
        rotlwi 8,8,16
        rotlwi 5,5,16
        rotlwi 3,3,16
        rotlwi 4,4,16
        add 31,8,31
        add 0,5,0
        add 25,25,3
        add 26,26,4
        xor 7,31,7
        xor 6,0,6
        xor 9,25,9
        xor 10,26,10
        rotlwi 7,7,12
        rotlwi 6,6,12
        rotlwi 9,9,12
        rotlwi 10,10,12
        add 29,29,7
        add 27,27,6
        add 28,28,9
        add 11,11,10
        xor 8,29,8
        xor 5,27,5
        xor 3,28,3
        xor 4,11,4
        rotlwi 8,8,8
        rotlwi 5,5,8
        rotlwi 3,3,8
        rotlwi 4,4,8
        add 31,31,8
        add 0,0,5
        add 25,25,3
        add 26,26,4
        xor 7,31,7
        xor 6,0,6
        xor 9,25,9
        xor 10,26,10
        rotlwi 7,7,7
        rotlwi 6,6,7
        rotlwi 9,9,7
        rotlwi 10,10,7
        add 29,29,6
        add 27,27,9
        add 11,11,7
        add 28,28,10
        xor 8,27,8
        xor 3,11,3
        xor 4,29,4
        xor 5,28,5
        rotlwi 8,8,16
        rotlwi 3,3,16
        rotlwi 4,4,16
        rotlwi 5,5,16
        add 0,0,3
        add 25,25,4
        add 26,26,8
        add 31,31,5
        xor 7,0,7
        xor 6,25,6
        xor 9,26,9
        xor 10,31,10
        rotlwi 7,7,12
        rotlwi 6,6,12
        rotlwi 9,9,12
        rotlwi 10,10,12
        add 11,11,7
        add 29,29,6
        add 27,27,9
        add 28,28,10
        xor 3,11,3
        xor 4,29,4
        xor 8,27,8
        xor 5,28,5
        rotlwi 3,3,8
        rotlwi 4,4,8
        rotlwi 8,8,8
        rotlwi 5,5,8
        add 0,0,3
        add 25,25,4
        add 26,26,8
        add 31,31,5
        xor 7,0,7
        xor 6,25,6
        xor 9,26,9
        xor 10,31,10
        rotlwi 7,7,7
        rotlwi 6,6,7
        rotlwi 9,9,7
        rotlwi 10,10,7
        bdnz .L119
        andi. 16,23,0xf
        stw 29,16(1)
        stw 4,76(1)
        stw 25,56(1)
        stw 6,36(1)
        stw 27,20(1)
        stw 8,64(1)
        stw 26,60(1)
        stw 9,40(1)
        stw 28,24(1)
        stw 5,68(1)
        stw 31,48(1)
        stw 10,44(1)
        stw 11,28(1)
        stw 3,72(1)
        stw 0,52(1)
        stw 7,32(1)
        bne- 0,.L120
        li 9,64
        lwz 10,.LC33-.LCTOC1(30)
        li 8,128
        lvx 12,1,22
        lvx 0,1,9
        neg 9,23
        lvx 1,1,8
        lvx 13,1,20
        lvsr 8,0,9
        addi 9,23,31
        lvx 11,0,10
        addi 10,23,15
        lvx 9,0,9
        addi 9,23,63
        lvx 4,0,10
        addi 10,23,47
        lvx 5,0,9
        li 9,160
        vadduwm 1,1,0
        vadduwm 13,27,13
        vadduwm 11,12,11
        lvx 0,1,21
        vxor 10,1,11
        vadduwm 0,26,0
        vxor 10,10,0
        vxor 10,10,13
        vsldoi 7,10,30,8
        vxor 7,7,10
        lvx 10,0,10
        vsldoi 6,7,30,4
        vxor 7,6,7
        lvx 6,0,23
        stvx 7,1,9
        lwz 9,160(1)
        vperm 5,10,5,8
        vperm 6,6,4,8
        lwz 10,.LC35-.LCTOC1(30)
        vperm 10,9,10,8
        vpkuwum 7,13,1
        vperm 9,4,9,8
        xor 19,19,9
        lwz 9,.LC39-.LCTOC1(30)
        vpkuwum 11,11,0
        vpkuhum 3,6,9
        lvx 4,0,10
        vsrh 8,11,31
        lwz 10,.LC37-.LCTOC1(30)
        vpkuhum 11,11,7
        vsrh 7,7,31
        vpkuhum 8,8,7
        vperm 7,6,9,4
        vpkuwum 6,6,9
        vperm 9,10,5,4
        vperm 7,7,9,4
        lvx 9,0,9
        lwz 9,.LC41-.LCTOC1(30)
        vpkuhum 2,10,5
        vxor 7,7,11
        vperm 3,3,2,4
        vpkuwum 10,10,5
        vxor 8,8,3
        vmrghw 5,0,0
        lvx 4,0,10
        vmrglw 0,0,0
        vsrw 5,5,9
        vsrw 11,0,9
        vmrghw 0,12,12
        vpkuwum 5,5,11
        vadduwm 0,0,4
        vmrghw 11,13,13
        vmrglw 12,12,12
        vsrw 11,11,9
        lvx 4,0,9
        vsrw 0,0,9
        vadduwm 12,12,4
        vmrglw 13,13,13
        vsrw 12,12,9
        vsrw 13,13,9
        vpkuwum 0,0,12
        vpkuwum 13,11,13
        vmrghw 12,1,1
        vmrglb 11,7,8
        vsrw 12,12,9
        vpkuhum 0,0,5
        vmrglw 1,1,1
        vxor 0,0,6
        vsrw 1,1,9
        vpkuwum 1,12,1
        vmrghb 12,7,8
        vpkuhum 1,13,1
        vmrghh 13,12,0
        vxor 1,1,10
        stvx 13,0,23
        vmrglh 12,12,0
        vmrghh 13,11,1
        vmrglh 11,11,1
        stvx 13,23,21
        stvx 11,23,20
        stvx 12,23,22
.L121:
        lwz 9,304(1)
        addi 23,23,64
        cmplw 0,9,23
        bne+ 0,.L122
        lwz 9,328(1)
        lwz 27,308(1)
        lwz 26,316(1)
        lwz 29,312(1)
        add 27,27,9
        addic 26,26,1
        lwz 9,324(1)
        addze 29,29
        cmplw 0,9,29
        bne+ 0,.L118
        lwz 9,332(1)
        cmplw 0,9,26
        bne+ 0,.L118
        mr 4,19
        lwz 14,440(1)
        .cfi_restore 14
        li 3,0
        lwz 15,444(1)
        .cfi_restore 15
        lwz 16,448(1)
        .cfi_restore 16
        lwz 17,452(1)
        .cfi_restore 17
        lwz 18,456(1)
        .cfi_restore 18
        lwz 19,460(1)
        .cfi_restore 19
        lwz 20,464(1)
        .cfi_restore 20
        lwz 21,468(1)
        .cfi_restore 21
        lwz 22,472(1)
        .cfi_restore 22
        lwz 23,476(1)
        .cfi_restore 23
        lwz 25,484(1)
        .cfi_restore 25
        lwz 26,488(1)
        .cfi_restore 26
        lwz 27,492(1)
        .cfi_restore 27
        lwz 28,496(1)
        .cfi_restore 28
        lwz 29,500(1)
        .cfi_restore 29
        lwz 31,508(1)
        .cfi_restore 31
.L114:
        li 0,336
        lwz 24,480(1)
        lvx 26,1,0
        li 0,352
        lwz 30,504(1)
        lvx 27,1,0
        li 0,368
        lvx 28,1,0
        li 0,384
        lvx 29,1,0
        li 0,400
        lvx 30,1,0
        li 0,416
        lvx 31,1,0
        lwz 0,516(1)
        addi 1,1,512
        .cfi_restore 30
        .cfi_restore 24
        .cfi_restore 108
        .cfi_restore 107
        .cfi_restore 106
        .cfi_restore 105
        .cfi_restore 104
        .cfi_restore 103
        .cfi_def_cfa_offset 0
        mtlr 0
        .cfi_restore 65
        blr
.L125:
        .cfi_def_cfa_offset 512
        .cfi_offset 16, -64
        .cfi_offset 24, -32
        .cfi_offset 28, -16
        .cfi_offset 30, -8
        .cfi_offset 103, -176
        .cfi_offset 104, -160
        .cfi_offset 105, -144
        .cfi_offset 106, -128
        .cfi_offset 107, -112
        .cfi_offset 108, -96
        .cfi_offset 65, 4
        mr 3,28
        lwz 16,448(1)
        .cfi_restore 16
        mr 4,10
        lwz 28,496(1)
        .cfi_restore 28
        b .L114
.L120:
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
        .cfi_offset 25, -28
        .cfi_offset 26, -24
        .cfi_offset 27, -20
        .cfi_offset 28, -16
        .cfi_offset 29, -12
        .cfi_offset 31, -4
        lbz 16,2(23)
        addis 29,29,0x6170
        addis 27,27,0x3320
        addi 29,29,30821
        lbz 12,1(23)
        addi 27,27,25710
        mtlr 16
        lbz 16,3(23)
        add 8,8,24
        addis 28,28,0x7962
        lbz 14,5(23)
        addi 28,28,11570
        addis 11,11,0x6b20
        mtctr 16
        srwi 16,29,8
        lbz 15,6(23)
        addi 11,11,25972
        xor 16,16,12
        mflr 12
        lbz 24,7(23)
        stb 16,1(23)
        srwi 16,29,16
        mfctr 18
        xor 16,16,12
        lbz 12,9(23)
        stb 16,2(23)
        srwi 16,29,24
        xor 16,16,18
        lbz 18,10(23)
        stb 16,3(23)
        srwi 16,27,8
        xor 16,16,14
        mtctr 18
        lbz 14,11(23)
        stb 16,5(23)
        srwi 16,27,16
        xor 15,16,15
        mfctr 18
        lbz 16,13(23)
        stb 15,6(23)
        srwi 15,27,24
        xor 24,15,24
        lbz 15,14(23)
        stb 24,7(23)
        srwi 24,28,8
        xor 24,24,12
        lbz 12,15(23)
        stb 24,9(23)
        srwi 24,28,16
        xor 24,24,18
        mtctr 24
        lbz 24,0(23)
        mfctr 18
        xor 24,29,24
        xor 29,29,27
        mtctr 24
        lbz 24,4(23)
        xor 29,29,19
        stb 18,10(23)
        srwi 18,28,24
        xor 29,29,28
        xor 24,27,24
        mfctr 27
        xor 14,18,14
        lbz 19,12(23)
        stb 14,11(23)
        srwi 14,11,8
        xor 14,14,16
        srwi 16,11,16
        stb 24,4(23)
        stb 27,0(23)
        xor 16,16,15
        xor 19,11,19
        lbz 27,8(23)
        srwi 15,8,16
        stb 14,13(23)
        srwi 14,8,24
        xor 27,28,27
        srwi 28,11,24
        stb 16,14(23)
        xor 28,28,12
        xor 11,29,11
        stb 27,8(23)
        li 29,176
        stb 28,15(23)
        xor 11,11,4
        stb 19,12(23)
        stvx 28,1,29
        li 29,192
        xor 11,11,5
        stvx 28,1,29
        li 29,208
        li 28,224
        stvx 28,1,29
        lwz 29,196(1)
        xor 11,11,3
        stvx 28,1,28
        lbz 28,21(23)
        xor 19,11,8
        srwi 16,8,8
        add 6,29,6
        lwz 11,176(1)
        srwi 12,5,8
        srwi 29,6,8
        lwz 27,216(1)
        xor 29,29,28
        lbz 28,22(23)
        add 11,11,7
        lwz 24,236(1)
        srwi 7,6,16
        add 9,27,9
        xor 7,7,28
        lbz 27,23(23)
        lbz 28,25(23)
        add 24,24,10
        srwi 10,6,24
        stb 29,21(23)
        srwi 29,9,8
        xor 10,10,27
        xor 29,29,28
        lbz 28,26(23)
        srwi 27,9,16
        stb 10,23(23)
        lbz 10,20(23)
        xor 27,27,28
        lbz 28,27(23)
        xor 10,6,10
        stb 7,22(23)
        srwi 7,9,24
        xor 7,7,28
        stb 10,20(23)
        srwi 28,11,8
        lbz 10,17(23)
        stb 7,27(23)
        lbz 7,24(23)
        xor 10,28,10
        lbz 28,18(23)
        xor 7,9,7
        stb 29,25(23)
        srwi 29,11,16
        xor 28,29,28
        stb 7,24(23)
        lbz 29,19(23)
        lbz 7,16(23)
        stb 10,17(23)
        lbz 10,28(23)
        xor 7,11,7
        stb 27,26(23)
        srwi 27,11,24
        xor 29,27,29
        xor 10,24,10
        stb 28,18(23)
        stb 29,19(23)
        srwi 28,24,8
        srwi 29,24,16
        stb 7,16(23)
        stb 10,28(23)
        li 10,240
        stvx 29,1,10
        li 10,256
        stvx 29,1,10
        li 10,272
        stvx 29,1,10
        lwz 27,260(1)
        lwz 7,240(1)
        add 0,27,0
        lbz 27,29(23)
        lwz 10,280(1)
        add 7,7,31
        xor 27,28,27
        lbz 28,31(23)
        xor 19,19,7
        add 10,10,25
        lbz 31,30(23)
        srwi 25,24,24
        xor 28,25,28
        lbz 25,33(23)
        xor 19,19,0
        xor 31,29,31
        srwi 29,7,8
        stb 27,29(23)
        stb 31,30(23)
        xor 31,29,25
        srwi 27,7,16
        stb 31,33(23)
        srwi 25,7,24
        xor 19,19,10
        lbz 31,32(23)
        lbz 29,34(23)
        xor 31,7,31
        lbz 7,37(23)
        xor 29,27,29
        stb 28,31(23)
        srwi 28,0,8
        lbz 27,35(23)
        xor 28,28,7
        lbz 7,38(23)
        xor 25,25,27
        stb 31,32(23)
        srwi 27,0,16
        lbz 31,39(23)
        xor 7,27,7
        srwi 27,10,16
        stb 28,37(23)
        lbz 28,36(23)
        stb 29,34(23)
        srwi 29,0,24
        xor 29,29,31
        xor 28,0,28
        lbz 31,41(23)
        lbz 0,40(23)
        stb 7,38(23)
        srwi 7,5,16
        stb 25,35(23)
        mtctr 7
        srwi 25,10,8
        srwi 7,5,24
        xor 31,25,31
        stb 29,39(23)
        xor 0,10,0
        mtlr 7
        stb 28,36(23)
        li 7,288
        stb 31,41(23)
        srwi 10,10,24
        stb 0,40(23)
        srwi 25,3,8
        lbz 0,42(23)
        stvx 29,1,7
        lwz 7,300(1)
        lbz 29,43(23)
        xor 0,27,0
        add 7,7,26
        lbz 31,45(23)
        srwi 26,3,16
        xor 10,10,29
        xor 19,19,7
        lbz 29,46(23)
        srwi 27,7,8
        xor 11,19,11
        stb 0,42(23)
        xor 27,27,31
        srwi 28,7,16
        lbz 31,47(23)
        xor 28,28,29
        xor 6,11,6
        lbz 0,44(23)
        srwi 29,7,24
        xor 6,6,9
        lbz 9,53(23)
        xor 29,29,31
        lbz 31,49(23)
        xor 19,6,24
        lbz 24,48(23)
        xor 12,12,9
        mfctr 9
        lbz 6,54(23)
        xor 31,16,31
        xor 7,7,0
        lbz 16,52(23)
        xor 24,8,24
        lbz 0,50(23)
        xor 6,9,6
        lbz 11,51(23)
        xor 16,5,16
        mflr 5
        lbz 8,55(23)
        xor 0,15,0
        lbz 9,56(23)
        xor 11,14,11
        xor 8,5,8
        stb 10,43(23)
        srwi 10,3,24
        xor 9,3,9
        stb 27,45(23)
        srwi 3,4,24
        stb 28,46(23)
        srwi 27,4,8
        srwi 28,4,16
        stb 7,44(23)
        stb 6,54(23)
        stb 9,56(23)
        stb 29,47(23)
        stb 31,49(23)
        stb 0,50(23)
        stb 11,51(23)
        stb 24,48(23)
        stb 16,52(23)
        stb 12,53(23)
        stb 8,55(23)
        lbz 8,57(23)
        lbz 6,59(23)
        lbz 7,60(23)
        xor 8,25,8
        lbz 9,58(23)
        xor 10,10,6
        lbz 5,61(23)
        xor 4,4,7
        lbz 6,62(23)
        xor 9,26,9
        lbz 7,63(23)
        xor 27,27,5
        xor 28,28,6
        stb 8,57(23)
        xor 3,3,7
        stb 9,58(23)
        stb 10,59(23)
        stb 4,60(23)
        stb 27,61(23)
        stb 28,62(23)
        stb 3,63(23)
        b .L121
        .cfi_endproc
        .size   fb_chacha20, .-fb_chacha20
        .section        ".got2","aw"
.LC44:
        .long .LC43
.LC47:
        .long .LC46
        .set .LC48,.LC17
.LC51:
        .long .LC50
        .section        ".text"
        .align 2
        .globl fb_physics
.LCL6:
        .long .LCTOC1-.LCF6
        .type   fb_physics, @function
fb_physics:
        .cfi_startproc
        stwu 1,-160(1)
        .cfi_def_cfa_offset 160
        mflr 0
        .cfi_register 65, 0
        bcl 20,31,.LCF6
.LCF6:
        or. 9,5,6
        stw 23,44(1)
        .cfi_offset 23, -116
        mr 23,5
        stw 25,52(1)
        .cfi_offset 25, -108
        mr 25,6
        stw 30,72(1)
        .cfi_offset 30, -88
        mflr 30
        stw 0,164(1)
        .cfi_offset 65, 4
        lwz 0,.LCL6-.LCF6(30)
        add 30,0,30
        beq- 0,.L145
        or. 9,7,8
        stw 17,20(1)
        .cfi_offset 17, -140
        mr 17,8
        stw 18,24(1)
        .cfi_offset 18, -136
        mr 18,7
        beq- 0,.L146
        lwz 8,.LC44-.LCTOC1(30)
        slwi 9,6,6
        lwz 10,.LC47-.LCTOC1(30)
        lfs 0,0(8)
        stfd 25,104(1)
        .cfi_offset 57, -56
        stw 27,60(1)
        .cfi_offset 27, -100
        stw 28,64(1)
        .cfi_offset 28, -96
        stw 29,68(1)
        .cfi_offset 29, -92
        stw 31,76(1)
        .cfi_offset 31, -84
        stfd 22,80(1)
        .cfi_offset 54, -80
        stfd 23,88(1)
        .cfi_offset 55, -72
        stfd 24,96(1)
        .cfi_offset 56, -64
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
        lfs 25,0(10)
        stfs 0,8(1)
        stw 21,36(1)
        .cfi_offset 21, -124
        stw 26,56(1)
        .cfi_offset 26, -104
        lwz 21,.LC51-.LCTOC1(30)
        lwz 26,.LC48-.LCTOC1(30)
        stw 16,16(1)
        .cfi_offset 16, -144
        mr 16,8
        stw 19,28(1)
        .cfi_offset 19, -132
        li 19,0
        stw 20,32(1)
        .cfi_offset 20, -128
        li 20,0
        stw 22,40(1)
        .cfi_offset 22, -120
        add 22,3,9
        stw 24,48(1)
        .cfi_offset 24, -112
        mr 24,3
.L138:
        mr 27,24
.L143:
        lfs 22,8(1)
        mr 29,24
        mr 28,23
        lfd 26,0(27)
        mr 31,25
        lfd 27,8(27)
        fmr 23,22
        lfd 28,16(27)
        fmr 24,22
.L139:
        lfd 0,0(29)
        addi 29,29,64
        fsub 29,0,26
        lfd 0,-56(29)
        fsub 30,0,27
        lfd 0,-48(29)
        fmul 1,29,29
        fmul 12,30,30
        fsub 31,0,28
        fadd 1,1,12
        fmul 0,31,31
        fadd 1,1,0
        fadd 1,1,25
        bl sqrt@plt
        lfs 0,0(26)
        addic 31,31,-1
        lfd 12,-40(29)
        addme 28,28
        or. 9,28,31
        fdiv 0,0,1
        fmul 1,0,0
        fmul 1,1,0
        fmul 1,1,12
        fmul 29,29,1
        fmul 30,30,1
        fmul 31,31,1
        fadd 24,24,29
        fadd 23,23,30
        fadd 22,22,31
        bne+ 0,.L139
        lfs 0,0(21)
        addi 27,27,64
        fmr 12,0
        fmul 24,24,12
        fmul 23,23,12
        fmul 22,22,12
        lfd 12,-32(27)
        fadd 10,12,24
        lfd 12,-24(27)
        fadd 11,12,23
        lfd 12,-16(27)
        stfd 10,-32(27)
        fadd 12,12,22
        stfd 11,-24(27)
        stfd 12,-16(27)
        cmplw 0,22,27
        bne+ 0,.L143
        mr 9,24
        mtctr 25
.L140:
        lfd 12,32(9)
        addi 9,9,64
        lfd 9,-64(9)
        fmul 10,12,0
        lfd 12,-24(9)
        fadd 10,9,10
        lfd 9,-56(9)
        fmul 11,12,0
        lfd 12,-16(9)
        stfd 10,-64(9)
        fadd 11,9,11
        lfd 9,-48(9)
        fmul 12,12,0
        stfd 11,-56(9)
        fadd 12,9,12
        stfd 12,-48(9)
        bdnz .L140
        addic 20,20,1
        addze 19,19
        cmplw 0,18,19
        bne+ 0,.L138
        cmplw 0,17,20
        bne+ 0,.L138
        andi. 9,25,0x1
        lfs 0,0(16)
        addi 9,24,32
        addi 10,25,-1
        stfd 0,8(1)
        beq- 0,.L152
        lfd 0,0(9)
        cmpwi 0,10,0
        lfd 11,8(9)
        lfd 12,16(9)
        addi 9,24,96
        fadd 0,0,11
        fadd 0,0,12
        lfd 12,8(1)
        fadd 0,12,0
        stfd 0,8(1)
        beq- 0,.L157
.L152:
        srwi 10,25,1
        mtctr 10
.L144:
        lfd 12,8(9)
        mr 10,9
        addi 9,9,128
        lfd 0,-128(9)
        lfd 10,-56(9)
        lfd 9,-112(9)
        fadd 0,0,12
        lfd 12,-64(9)
        lfd 11,80(10)
        fadd 12,12,10
        lfd 10,8(1)
        fadd 0,0,9
        fadd 12,12,11
        fadd 0,10,0
        fadd 0,0,12
        stfd 0,8(1)
        bdnz .L144
.L157:
        lwz 0,164(1)
        lwz 3,8(1)
        lwz 4,12(1)
        mtlr 0
        .cfi_restore 65
        lfd 22,80(1)
        .cfi_restore 54
        lfd 23,88(1)
        .cfi_restore 55
        lfd 24,96(1)
        .cfi_restore 56
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
        lwz 16,16(1)
        .cfi_restore 16
        lwz 17,20(1)
        .cfi_restore 17
        lwz 18,24(1)
        .cfi_restore 18
        lwz 19,28(1)
        .cfi_restore 19
        lwz 20,32(1)
        .cfi_restore 20
        lwz 21,36(1)
        .cfi_restore 21
        lwz 22,40(1)
        .cfi_restore 22
        lwz 24,48(1)
        .cfi_restore 24
        lwz 26,56(1)
        .cfi_restore 26
        lwz 27,60(1)
        .cfi_restore 27
        lwz 28,64(1)
        .cfi_restore 28
        lwz 29,68(1)
        .cfi_restore 29
        lwz 31,76(1)
        .cfi_restore 31
        lwz 23,44(1)
        lwz 25,52(1)
        lwz 30,72(1)
        addi 1,1,160
        .cfi_restore 30
        .cfi_restore 25
        .cfi_restore 23
        .cfi_def_cfa_offset 0
        blr
.L146:
        .cfi_def_cfa_offset 160
        .cfi_offset 17, -140
        .cfi_offset 18, -136
        .cfi_offset 23, -116
        .cfi_offset 25, -108
        .cfi_offset 30, -88
        .cfi_offset 65, 4
        lwz 0,164(1)
        mr 3,7
        mr 4,8
        lwz 17,20(1)
        .cfi_restore 17
        lwz 18,24(1)
        .cfi_restore 18
        mtlr 0
        .cfi_restore 65
        lwz 23,44(1)
        lwz 25,52(1)
        lwz 30,72(1)
        addi 1,1,160
        .cfi_restore 30
        .cfi_restore 25
        .cfi_restore 23
        .cfi_def_cfa_offset 0
        blr
.L145:
        .cfi_def_cfa_offset 160
        .cfi_offset 23, -116
        .cfi_offset 25, -108
        .cfi_offset 30, -88
        .cfi_offset 65, 4
        lwz 0,164(1)
        mr 3,5
        mr 4,6
        lwz 23,44(1)
        lwz 25,52(1)
        mtlr 0
        .cfi_restore 65
        lwz 30,72(1)
        addi 1,1,160
        .cfi_restore 30
        .cfi_restore 25
        .cfi_restore 23
        .cfi_def_cfa_offset 0
        blr
        .cfi_endproc
        .size   fb_physics, .-fb_physics
        .align 2
        .globl fb_sort
        .type   fb_sort, @function
fb_sort:
        .cfi_startproc
        cmpwi 0,5,0
        beq- 0,.L198
.L162:
        stwu 1,-48(1)
        .cfi_def_cfa_offset 48
        srwi 10,6,1
        slwi 9,5,31
        add 9,9,10
        stw 27,28(1)
        .cfi_offset 27, -20
        srwi 27,5,1
        slwi 10,27,1
        stw 26,24(1)
        .cfi_offset 26, -24
        srwi 26,9,31
        stw 28,32(1)
        .cfi_offset 28, -16
        addic 28,9,-1
        slwi 9,9,1
        stw 31,44(1)
        addme 27,27
        add 26,26,10
        stw 29,36(1)
        .cfi_offset 31, -4
        .cfi_offset 29, -12
        addic 29,9,-1
        addme 26,26
.L193:
        cmplw 0,5,26
        ble- 0,.L199
.L189:
        slwi 9,28,2
        mr 7,26
        lwzx 31,3,9
        mr 4,29
        mr 9,27
        mr 0,28
.L172:
        addic 10,0,1
        slwi 8,4,2
        addze 9,9
        srwi 11,10,31
        lwzx 12,3,8
        slwi 9,9,1
        add 8,3,8
        add 9,11,9
        slwi 10,10,1
        cmplw 0,5,9
        mr 11,8
        bgt- 0,.L168
        bne- 0,.L171
        cmplw 0,6,10
        ble- 0,.L171
.L168:
        lwz 8,4(8)
        cmplw 0,8,12
        ble- 0,.L171
        slwi 11,10,2
        lwzx 12,3,11
        add 11,3,11
.L170:
        cmplw 0,31,12
        bge- 0,.L166
        slwi 8,10,1
        srwi 7,10,31
        addic 4,8,1
        slwi 8,9,1
        adde 7,7,8
        slwi 0,0,2
        cmplw 0,5,7
        stwx 12,3,0
        stw 31,0(11)
        ble- 0,.L200
.L187:
        mr 0,10
        b .L172
.L200:
        bne- 0,.L166
        cmplw 0,6,4
        bgt+ 0,.L187
.L166:
        addic 28,28,-1
        addme 27,27
        addic 29,29,-2
        cmpwi 0,27,-1
        addme 26,26
        bne+ 0,.L193
        cmpwi 0,28,-1
        bne+ 0,.L193
        addic 28,6,-1
        addi 9,3,4
        addme 31,5
        slwi 27,28,2
        cmpwi 0,31,0
        add 27,27,9
        lwz 9,0(3)
        lwzu 10,-4(27)
        stw 10,0(3)
        stw 9,0(27)
        beq- 0,.L201
.L190:
        lwz 29,0(3)
        li 7,0
        li 4,1
        li 9,0
        li 11,0
.L183:
        addic 10,11,1
        slwi 8,4,2
        addze 9,9
        srwi 0,10,31
        lwzx 26,3,8
        slwi 9,9,1
        add 8,3,8
        add 9,0,9
        slwi 10,10,1
        cmplw 0,31,9
        mr 12,8
        bgt- 0,.L177
        bne- 0,.L180
        cmplw 0,28,10
        ble- 0,.L180
.L177:
        lwz 8,4(8)
        cmplw 0,8,26
        ble- 0,.L180
        slwi 12,10,2
        lwzx 26,3,12
        add 12,3,12
.L179:
        cmplw 0,29,26
        bge- 0,.L181
        slwi 8,10,1
        srwi 7,10,31
        addic 4,8,1
        slwi 8,9,1
        adde 7,7,8
        slwi 11,11,2
        cmplw 0,31,7
        stwx 26,3,11
        stw 29,0(12)
        ble- 0,.L202
.L191:
        mr 11,10
        b .L183
.L202:
        bne- 0,.L181
        cmplw 0,28,4
        bgt+ 0,.L191
.L181:
        addic 28,28,-1
        lwz 9,0(3)
        addme 31,31
        lwzu 10,-4(27)
        cmpwi 0,31,0
        stw 10,0(3)
        stw 9,0(27)
        bne+ 0,.L190
.L201:
        cmplwi 0,28,1
        bne+ 0,.L190
        addi 9,3,-4
        li 4,0
        li 3,0
.L184:
        srwi 7,4,7
        lwzu 8,4(9)
        slwi 10,3,25
        add 10,10,7
        srwi 3,3,7
        xor 10,8,10
        slwi 7,4,25
        addc 4,8,10
        adde 3,7,3
        addic 6,6,-1
        addme 5,5
        or. 10,5,6
        bne+ 0,.L184
        lwz 26,24(1)
        lwz 27,28(1)
        lwz 28,32(1)
        lwz 29,36(1)
        lwz 31,44(1)
        addi 1,1,48
        .cfi_remember_state
        .cfi_restore 31
        .cfi_restore 29
        .cfi_restore 28
        .cfi_restore 27
        .cfi_restore 26
        .cfi_def_cfa_offset 0
        blr
.L171:
        .cfi_restore_state
        mr 9,7
        mr 10,4
        b .L170
.L180:
        mr 9,7
        mr 10,4
        b .L179
.L199:
        bne- 0,.L166
        cmplw 0,6,29
        bgt+ 0,.L189
        b .L166
.L198:
        .cfi_def_cfa_offset 0
        .cfi_restore 26
        .cfi_restore 27
        .cfi_restore 28
        .cfi_restore 29
        .cfi_restore 31
        cmplwi 0,6,1
        bgt+ 0,.L162
        cmpwi 0,6,0
        bne- 0,.L203
        li 3,0
        li 4,0
        blr
.L203:
        lwz 4,0(3)
        li 3,0
        blr
        .cfi_endproc
        .size   fb_sort, .-fb_sort
        .align 2
        .globl fb_chase
        .type   fb_chase, @function
fb_chase:
        .cfi_startproc
        or. 9,5,6
        beq- 0,.L208
        mr 4,3
.L207:
        addic 6,6,-1
        lwz 4,0(4)
        addme 5,5
        or. 10,5,6
        bne+ 0,.L207
        subf 4,3,4
        li 3,0
        blr
.L208:
        mr 3,5
        mr 4,6
        blr
        .cfi_endproc
        .size   fb_chase, .-fb_chase
        .section        .rodata.cst4,"aM",@progbits,4
        .align 2
.LC1:
        .long   1073741824
        .align 2
.LC4:
        .long   1070342144
        .align 2
.LC7:
        .long   1056964608
        .align 2
.LC10:
        .long   1065877504
        .align 2
.LC13:
        .long   981467136
        .align 2
.LC16:
        .long   1065353216
        .section        .rodata.cst16,"aM",@progbits,16
        .align 4
.LC30:
        .byte   3
        .byte   2
        .byte   1
        .byte   0
        .byte   7
        .byte   6
        .byte   5
        .byte   4
        .byte   11
        .byte   10
        .byte   9
        .byte   8
        .byte   15
        .byte   14
        .byte   13
        .byte   12
        .align 4
.LC32:
        .long   1634760805
        .long   857760878
        .long   2036477234
        .long   1797285236
        .align 4
.LC34:
        .byte   0
        .byte   2
        .byte   4
        .byte   6
        .byte   8
        .byte   10
        .byte   12
        .byte   14
        .byte   16
        .byte   18
        .byte   20
        .byte   22
        .byte   24
        .byte   26
        .byte   28
        .byte   30
        .align 4
.LC36:
        .long   1634760805
        .long   1634760805
        .long   857760878
        .long   857760878
        .align 4
.LC38:
        .long   16
        .long   24
        .long   16
        .long   24
        .align 4
.LC40:
        .long   2036477234
        .long   2036477234
        .long   1797285236
        .long   1797285236
        .section        .rodata.cst4
        .align 2
.LC43:
        .long   0
        .align 2
.LC46:
        .long   1031798784
        .align 2
.LC50:
        .long   1006632960
        .section        .rodata
        .align 4
        .set    .LANCHOR1,. + 0
        .type   prefix.1, @object
        .size   prefix.1, 10
prefix.1:
        .string "nintendo,"
        .zero   6
        .type   sigma.0, @object
        .size   sigma.0, 16
sigma.0:
        .long   1634760805
        .long   857760878
        .long   2036477234
        .long   1797285236
        .section        ".bss"
        .align 2
        .set    .LANCHOR0,. + 0
        .type   detected.4, @object
        .size   detected.4, 4
detected.4:
        .zero   4
        .type   kernel.3, @object
        .size   kernel.3, 4
kernel.3:
        .zero   4
        .globl __udivdi3
        .ident  "GCC: (crosstool-NG UNKNOWN) 16.1.0"
        .gnu_attribute 4, 1
        .section        .note.GNU-stack,"",@progbits
/* Optional PPC32 extended-instruction kernels.  No instruction in this file
 * is reached until fb_simd has checked the device tree or AT_HWCAP.
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
