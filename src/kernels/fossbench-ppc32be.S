        .file   "fossbench-ppc32be.S"
        .machine "7450"
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
        stw 22,24(1)
        .cfi_register 65, 0
        .cfi_offset 22, -40
        mr 22,3
        stw 25,36(1)
        .cfi_offset 25, -28
        mr 25,4
        stw 0,68(1)
        .cfi_offset 65, 4
        beq- 0,.L1
        stw 21,20(1)
        .cfi_offset 21, -44
        lis 9,0x94d0
        lis 4,0x1331
        stw 24,32(1)
        .cfi_offset 24, -32
        lis 8,0xbf58
        lis 24,0x2545
        stw 28,48(1)
        .cfi_offset 28, -16
        lis 10,0x1ce4
        lis 28,0x4f6c
        lis 11,0x9e37
        lis 7,0x7f4a
        stw 23,28(1)
        .cfi_offset 23, -36
        stw 26,40(1)
        .cfi_offset 26, -24
        ori 24,24,0xf491
        ori 28,28,0xdd1d
        stw 27,44(1)
        .cfi_offset 27, -20
        ori 26,9,0x49bb
        ori 10,10,0xe5b9
        stw 29,52(1)
        .cfi_offset 29, -12
        ori 23,11,0x79b9
        ori 29,4,0x11eb
        stw 31,60(1)
        .cfi_offset 31, -4
        ori 27,7,0x7c15
        ori 31,8,0x476d
.L4:
        lis 9,0xdead
        lis 6,0xdead
        li 5,0
        ori 9,9,0xbeef
        ori 6,6,0xbeef
        mulhwu 4,27,9
        mullw 11,23,9
        mullw 7,27,9
        mullw 12,31,9
        add 11,11,4
        mulhwu 4,10,9
        addc 7,7,10
        adde 11,11,31
        mullw 10,10,9
        mulhwu 0,29,9
        add 12,12,4
        mullw 3,26,9
        addc 10,10,29
        adde 12,12,26
        mullw 4,29,9
        mullw 8,24,9
        add 3,3,0
        addc 4,4,28
        mulhwu 0,28,9
        adde 3,3,24
        srwi 31,4,29
        mullw 9,28,9
        slwi 27,3,3
        srwi 23,3,29
        add 27,27,31
        xor 23,23,11
        xor 27,27,7
        add 8,8,0
        slwi 0,23,1
        srwi 31,27,31
        srwi 29,23,31
        slwi 26,27,1
        addc 9,9,7
        add 0,0,31
        add 26,26,29
        adde 8,8,11
        srwi 31,9,15
        slwi 21,9,17
        slwi 11,8,17
        xor 21,21,10
        xor 29,0,4
        add 31,31,11
        srwi 10,21,7
        xor 26,26,3
        xor 31,31,12
        mr 3,26
        mr 4,29
        slwi 28,31,25
        srwi 24,31,7
        add 28,28,10
        xor 24,24,8
        xor 28,28,9
        bl __udivdi3@plt
        lis 6,0xdead
        mr 10,4
        mr 11,3
        mr 4,28
        addc 27,10,27
        mr 3,24
        li 5,0
        ori 6,6,0xbeef
        adde 23,11,23
        bl __udivdi3@plt
        addc 10,4,21
        adde 31,3,31
        addic 25,25,-1
        addme 22,22
        or. 9,22,25
        bne+ 0,.L4
        xor 3,26,24
        xor 4,29,28
        lwz 21,20(1)
        .cfi_restore 21
        xor 3,3,23
        xor 4,4,27
        lwz 23,28(1)
        .cfi_restore 23
        xor 3,3,31
        lwz 24,32(1)
        .cfi_restore 24
        xor 4,4,10
        lwz 26,40(1)
        .cfi_restore 26
        lwz 27,44(1)
        .cfi_restore 27
        lwz 28,48(1)
        .cfi_restore 28
        lwz 29,52(1)
        .cfi_restore 29
        lwz 31,60(1)
        .cfi_restore 31
.L1:
        lwz 0,68(1)
        lwz 22,24(1)
        lwz 25,36(1)
        addi 1,1,64
        .cfi_restore 25
        .cfi_restore 22
        .cfi_def_cfa_offset 0
        mtlr 0
        .cfi_restore 65
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
.LC20:
        .long .LC19
.LC23:
        .long .LC22
        .section        ".text"
        .align 2
        .globl fb_fp_math
.LCL1:
        .long .LCTOC1-.LCF1
        .type   fb_fp_math, @function
fb_fp_math:
        .cfi_startproc
        stwu 1,-112(1)
        .cfi_def_cfa_offset 112
        mflr 0
        .cfi_register 65, 0
        bcl 20,31,.LCF1
.LCF1:
        or. 9,3,4
        stw 27,20(1)
        .cfi_offset 27, -92
        mr 27,3
        stw 30,32(1)
        .cfi_offset 30, -80
        mflr 30
        stw 31,36(1)
        .cfi_offset 31, -76
        mr 31,4
        stw 0,116(1)
        .cfi_offset 65, 4
        lwz 0,.LCL1-.LCF1(30)
        add 30,0,30
        beq- 0,.L9
        stw 29,28(1)
        .cfi_offset 29, -84
        lwz 29,.LC20-.LCTOC1(30)
        stfd 29,88(1)
        .cfi_offset 61, -24
        lfs 29,0(29)
        lwz 5,.LC2-.LCTOC1(30)
        lwz 6,.LC5-.LCTOC1(30)
        lwz 7,.LC8-.LCTOC1(30)
        lwz 8,.LC11-.LCTOC1(30)
        lwz 10,.LC14-.LCTOC1(30)
        lwz 9,.LC17-.LCTOC1(30)
        stfd 30,96(1)
        .cfi_offset 62, -16
        fmr 30,29
        stfd 23,40(1)
        .cfi_offset 55, -72
        stfd 24,48(1)
        .cfi_offset 56, -64
        stfd 28,80(1)
        .cfi_offset 60, -32
        stfd 31,104(1)
        .cfi_offset 63, -8
        lfs 28,0(5)
        lfs 31,0(6)
        lfs 0,0(7)
        lfs 12,0(8)
        lfs 23,0(10)
        lfs 24,0(9)
        stw 28,24(1)
        .cfi_offset 28, -88
        stfd 25,56(1)
        .cfi_offset 57, -56
        stfd 26,64(1)
        .cfi_offset 58, -48
        stfd 27,72(1)
        .cfi_offset 59, -40
        lwz 28,.LC23-.LCTOC1(30)
.L22:
        fmul 12,12,23
        fmul 0,0,23
        fmul 31,31,23
        fmul 28,28,23
        fmr 27,30
        fadd 12,12,24
        fadd 0,0,24
        fadd 25,31,24
        fadd 28,28,24
        fcmpu 0,12,30
        bnl- 0,.L13
        fmr 27,12
.L13:
        fcmpu 0,0,29
        fmr 26,30
        bnl- 0,.L15
        fmr 26,0
.L15:
        fmr 1,27
        bl sqrt@plt
        lfs 31,0(29)
        fmr 0,31
        fcmpu 0,25,0
        bnl- 0,.L17
        fmr 31,25
.L17:
        lfs 0,0(29)
        fadd 31,31,1
        fmr 12,0
        fmr 25,0
        fcmpu 0,28,12
        bnl- 0,.L19
        fmr 25,28
.L19:
        fmr 1,26
        bl sqrt@plt
        lfs 11,0(28)
        fadd 1,1,25
        fmr 0,11
        fabs 1,1
        fcmpu 0,1,0
        bng- 0,.L21
        fmr 11,1
.L21:
        lfs 0,0(28)
        addic 31,31,-1
        fmr 28,11
        addme 27,27
        or. 9,27,31
        fadd 12,31,0
        fadd 10,11,0
        fdiv 12,0,12
        fdiv 0,0,10
        fadd 12,12,27
        fadd 0,0,26
        bne+ 0,.L22
        fadd 12,12,0
        lfd 23,40(1)
        .cfi_restore 55
        lfd 24,48(1)
        .cfi_restore 56
        lfd 25,56(1)
        .cfi_restore 57
        lfd 26,64(1)
        .cfi_restore 58
        lfd 27,72(1)
        .cfi_restore 59
        fadd 1,12,31
        lfd 28,80(1)
        .cfi_restore 60
        lfd 29,88(1)
        .cfi_restore 61
        lfd 30,96(1)
        .cfi_restore 62
        lfd 31,104(1)
        .cfi_restore 63
        lwz 28,24(1)
        .cfi_restore 28
        fadd 0,1,11
        lwz 29,28(1)
        .cfi_restore 29
        stfd 0,8(1)
        lwz 3,8(1)
        lwz 4,12(1)
.L9:
        lwz 0,116(1)
        lwz 27,20(1)
        lwz 30,32(1)
        lwz 31,36(1)
        mtlr 0
        .cfi_restore 65
        addi 1,1,112
        .cfi_restore 31
        .cfi_restore 30
        .cfi_restore 27
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
        beq- 0,.L53
.L45:
        mr 5,29
        li 4,0
        mr 3,23
        stw 25,36(1)
        .cfi_offset 25, -28
        stw 26,40(1)
        .cfi_offset 26, -24
        bl memset@plt
        addic 25,29,-1
        li 9,257
        addme 26,28
        srwi 10,25,1
        sth 9,0(23)
        srwi. 9,26,1
        slwi 9,26,31
        add 9,9,10
        beq- 0,.L54
.L46:
        stw 24,32(1)
        .cfi_offset 24, -32
        li 31,2
        li 24,0
        stw 27,44(1)
        .cfi_offset 27, -20
        li 27,1
.L49:
        lbzx 9,23,31
        cmpwi 0,9,0
        beq- 0,.L55
.L36:
        addic 31,31,1
        mr 3,26
        mr 4,25
        addze 24,24
        mr 6,31
        mr 5,24
        bl __udivdi3@plt
        cmplw 0,24,3
        bgt- 0,.L52
        bne+ 0,.L49
        cmplw 0,31,4
        ble+ 0,.L49
.L52:
        lwz 24,32(1)
        .cfi_restore 24
        lwz 27,44(1)
        .cfi_restore 27
.L42:
        addic 10,29,-2
        addi 23,23,1
        li 3,0
        addme 28,28
        li 4,0
.L44:
        lbzu 9,1(23)
        cntlzw 9,9
        srwi 9,9,5
        addc 4,9,4
        addze 3,3
        addic 10,10,-1
        addme 28,28
        or. 9,28,10
        bne+ 0,.L44
        lwz 0,68(1)
        lwz 25,36(1)
        .cfi_restore 25
        lwz 26,40(1)
        .cfi_restore 26
        lwz 23,28(1)
        mtlr 0
        .cfi_restore 65
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
.L55:
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
        ble- 0,.L56
.L48:
        addc 8,31,9
        stbx 27,23,9
        adde 10,24,10
        mr 9,8
        cmplw 0,28,10
        bgt+ 0,.L48
        cmplw 7,29,8
        bne- 0,.L36
        bgt+ 7,.L48
        b .L36
.L53:
        .cfi_restore 24
        .cfi_restore 25
        .cfi_restore 26
        .cfi_restore 27
        cmplwi 0,4,1
        bgt+ 0,.L45
.L32:
        lwz 0,68(1)
        li 3,0
        li 4,0
        lwz 23,28(1)
        lwz 28,48(1)
        lwz 29,52(1)
        mtlr 0
        .cfi_restore 65
        lwz 31,60(1)
        addi 1,1,64
        .cfi_restore 31
        .cfi_restore 29
        .cfi_restore 28
        .cfi_restore 23
        .cfi_def_cfa_offset 0
        blr
.L56:
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
        bne- 0,.L36
        cmplw 0,29,9
        bgt+ 0,.L48
        b .L36
.L54:
        .cfi_restore 24
        .cfi_restore 27
        cmplwi 0,9,1
        bgt+ 0,.L46
        mtcrf 128,31
        bne- 0,.L42
        cmplwi 0,29,2
        bne- 0,.L42
        lwz 25,36(1)
        .cfi_restore 25
        lwz 26,40(1)
        .cfi_restore 26
        b .L32
        .cfi_endproc
        .size   fb_primes, .-fb_primes
        .section        .rodata.str1.4,"aMS",@progbits,1
        .align 2
.LC25:
        .string "rb"
        .align 2
.LC27:
        .string "/proc/device-tree/compatible"
        .align 2
.LC29:
        .string "/sys/firmware/devicetree/base/compatible"
        .section        ".got2","aw"
.LC24:
        .long .LANCHOR0
.LC26:
        .long .LC25
.LC28:
        .long .LC27
.LC30:
        .long .LC29
.LC32:
        .long fb_simd_ps_kernel
.LC33:
        .long fb_simd_vsx_kernel
.LC34:
        .long fb_simd_altivec_kernel
        .section        ".text"
        .align 2
        .globl fb_simd
.LCL3:
        .long .LCTOC1-.LCF3
        .type   fb_simd, @function
fb_simd:
        .cfi_startproc
        or. 8,3,4
        mr 10,3
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
        lwz 8,.LC24-.LCTOC1(30)
        lwz 7,0(8)
        cmpw 0,7,7
        bne- 0,$+4
        isync
        cmpwi 0,7,0
        beq- 0,.L84
.L60:
        lwz 8,4(8)
        cmpwi 0,8,0
        beq- 0,.L85
        mr 3,10
        mr 4,9
        mtctr 8
        mr 5,31
        bctrl
        lwz 8,4(31)
        li 10,0
        lwz 9,8(31)
        lwz 6,0(31)
        lwz 7,12(31)
        xor 9,9,8
        lwz 8,16(31)
        xor 9,9,6
        lwz 6,20(31)
        xor 9,9,7
        lwz 7,24(31)
        xor 9,9,8
        lwz 8,28(31)
        xor 9,9,6
        xor 9,9,7
        xor 9,9,8
.L58:
        lwz 0,132(1)
        mr 3,10
        mr 4,9
        lwz 30,120(1)
        lwz 31,124(1)
        addi 1,1,128
        .cfi_remember_state
        .cfi_restore 31
        .cfi_restore 30
        .cfi_def_cfa_offset 0
        mtlr 0
        .cfi_restore 65
        blr
.L84:
        .cfi_restore_state
        stw 3,80(1)
        li 3,16
        stw 8,88(1)
        stw 28,112(1)
        .cfi_offset 28, -16
        stw 29,116(1)
        .cfi_offset 29, -12
        stw 4,84(1)
        bl getauxval@plt
        mr 29,3
        lwz 4,.LC26-.LCTOC1(30)
        lwz 3,.LC28-.LCTOC1(30)
        mr 28,4
        bl fopen@plt
        lwz 10,80(1)
        mr. 6,3
        lwz 9,84(1)
        lwz 8,88(1)
        beq- 0,.L86
.L61:
        li 5,9
        addi 3,1,16
        li 4,1
        stw 8,92(1)
        stw 9,88(1)
        stw 10,84(1)
        stw 6,80(1)
        bl fread@plt
        cmpwi 0,3,9
        lwz 6,80(1)
        lwz 10,84(1)
        lwz 9,88(1)
        lwz 8,92(1)
        beq- 0,.L87
.L63:
        mr 3,6
        stw 8,88(1)
        stw 9,84(1)
        stw 10,80(1)
        bl fclose@plt
        lwz 8,88(1)
        lwz 9,84(1)
        lwz 10,80(1)
.L62:
        mr 7,29
        andi. 7,7,0x80
        bne- 0,.L88
        andis. 7,29,0x1000
        beq- 0,.L66
        lwz 7,.LC34-.LCTOC1(30)
.L66:
        stw 7,4(8)
        lwsync
        li 7,1
        stw 7,0(8)
        lwz 28,112(1)
        .cfi_remember_state
        .cfi_restore 28
        lwz 29,116(1)
        .cfi_restore 29
        b .L60
.L87:
        .cfi_restore_state
        lwz 5,16(1)
        xoris 7,5,0x6e69
        cmpwi 0,7,28276
        bne 0,.L63
        lwz 5,20(1)
        xoris 7,5,0x656e
        cmpwi 0,7,25711
        bne 0,.L63
        lbz 7,24(1)
        cmpwi 0,7,44
        bne+ 0,.L63
        mr 3,6
        stw 8,88(1)
        stw 9,84(1)
        stw 10,80(1)
        bl fclose@plt
        lwz 7,.LC32-.LCTOC1(30)
        lwz 10,80(1)
        lwz 9,84(1)
        lwz 8,88(1)
        b .L66
.L88:
        lwz 7,.LC33-.LCTOC1(30)
        b .L66
.L85:
        .cfi_restore 28
        .cfi_restore 29
        stw 27,108(1)
        .cfi_offset 27, -20
        stw 28,112(1)
        .cfi_offset 28, -16
        stw 29,116(1)
        .cfi_offset 29, -12
        lwz 8,0(31)
        lwz 7,16(31)
        lwz 12,4(31)
        mtctr 8
        lwz 8,8(31)
        lwz 11,20(31)
        mtlr 7
        lwz 4,24(31)
        mr 27,8
        lwz 0,28(31)
        lwz 8,12(31)
.L69:
        slwi 7,12,1
        mfctr 6
        slwi 5,0,3
        add 7,7,12
        add 5,5,0
        addic 9,9,-1
        add 7,7,6
        mflr 6
        add 5,5,4
        mulli 3,6,6
        rotlwi 7,7,5
        slwi 4,4,3
        mulli 29,7,10
        slwi 6,8,2
        mtctr 7
        slwi 7,11,3
        add 28,4,11
        add 6,6,8
        subf 7,11,7
        mflr 4
        addme 10,10
        add 8,3,8
        add 6,6,27
        slwi 3,27,2
        add 7,7,4
        or. 11,10,9
        add 0,29,0
        add 12,3,12
        rotlwi 6,6,7
        rotlwi 7,7,9
        rotlwi 0,0,12
        rotlwi 4,5,11
        mr 27,6
        rotlwi 12,12,6
        rotlwi 11,28,10
        mtlr 7
        rotlwi 8,8,8
        bne+ 0,.L69
        stw 8,28(1)
        mfctr 9
        mflr 8
        stw 9,16(1)
        li 7,16
        li 9,32
        stw 6,24(1)
        vxor 0,0,0
        li 3,64
        stw 8,32(1)
        mfctr 8
        li 10,0
        stw 11,36(1)
        stw 4,40(1)
        stw 12,20(1)
        stw 0,44(1)
        lwz 5,28(1)
        stw 8,0(31)
        lvx 1,1,9
        mflr 9
        lvx 13,1,7
        stw 12,4(31)
        stw 27,8(31)
        vxor 13,13,1
        lwz 6,36(1)
        vsldoi 1,13,0,8
        lwz 7,40(1)
        vxor 1,1,13
        vsldoi 0,1,0,4
        vxor 0,0,1
        stvx 0,1,3
        stw 5,12(31)
        stw 9,16(31)
        lwz 9,64(1)
        stw 6,20(31)
        stw 7,24(31)
        stw 0,28(31)
        lwz 27,108(1)
        .cfi_restore 27
        lwz 28,112(1)
        .cfi_restore 28
        lwz 29,116(1)
        .cfi_restore 29
        b .L58
.L86:
        .cfi_offset 28, -16
        .cfi_offset 29, -12
        lwz 3,.LC30-.LCTOC1(30)
        mr 4,28
        bl fopen@plt
        lwz 10,80(1)
        mr. 6,3
        lwz 9,84(1)
        lwz 8,88(1)
        bne+ 0,.L61
        b .L62
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
        beq- 0,.L120
.L110:
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
        b .L117
.L111:
        subfc 6,0,9
        subfe 10,24,8
        cmpwi 0,10,0
        bne- 0,.L92
        cmplwi 0,6,65535
        bgt- 0,.L92
        lwzx 10,31,0
        cmpw 0,10,11
        beq- 0,.L121
.L92:
        addic 9,9,1
        addze 8,8
        cmplw 0,25,8
        ble- 0,.L122
.L117:
        lwzx 11,31,9
        cmplwi 0,8,0
        mullw 10,11,26
        rlwinm 10,10,18,14,29
        lwzx 0,29,10
        stwx 9,29,10
        bgt+ 0,.L111
        bne- 0,.L92
        cmplw 0,9,0
        bgt+ 0,.L111
        b .L92
.L121:
        addic 20,9,4
        addze 6,8
        cmplw 0,28,6
        ble- 0,.L123
.L109:
        li 12,0
        li 10,4
        b .L116
.L102:
        addc 20,5,9
        mr 10,5
        mr 12,21
        adde 6,21,8
        cmplw 0,28,6
        ble- 0,.L124
.L116:
        add 11,31,10
        addic 5,10,1
        lbzx 22,11,9
        addze 21,12
        lbzx 11,11,0
        cmpw 0,22,11
        beq+ 0,.L102
        cmpwi 0,12,0
        li 11,1
        beq- 0,.L125
.L103:
        li 5,0
.L97:
        subfc 4,4,9
        mfctr 10
        li 9,1
        subfe 8,10,8
        addic 7,7,3
        cmpwi 0,8,0
        addze 3,3
        addc 7,7,4
        adde 3,3,8
        bne- 0,.L105
        subfic 4,4,14
        subfe 9,9,9
        rlwinm 9,9,0,31,31
.L105:
        mr 8,6
        addc 7,7,9
        mtctr 6
        cmplw 0,25,8
        addze 3,3
        addc 7,7,11
        mr 4,20
        adde 3,3,5
        mr 9,20
        bgt+ 0,.L117
.L122:
        bne- 0,.L115
        cmplw 0,19,9
        bgt+ 0,.L117
.L115:
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
.L120:
        .cfi_def_cfa_offset 80
        .cfi_offset 23, -36
        .cfi_offset 27, -20
        .cfi_offset 28, -16
        .cfi_offset 29, -12
        .cfi_offset 31, -4
        .cfi_offset 65, 4
        cmplwi 0,27,15
        bgt+ 0,.L110
        lwz 0,84(1)
        mr 3,23
        mflr 4
        lwz 23,44(1)
        lwz 27,60(1)
        lwz 28,64(1)
        mtlr 0
        .cfi_restore 65
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
.L124:
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
        bne- 0,.L114
        bgt+ 7,.L116
.L114:
        cmpwi 0,21,0
        li 11,1
        bne- 0,.L103
        subfic 5,5,18
        subfe 10,10,10
        neg 10,10
        neg 10,10
        and 11,11,10
        b .L103
.L125:
        subfic 10,10,18
        subfe 10,10,10
        neg 10,10
        neg 10,10
        and 11,11,10
        b .L103
.L123:
        bne- 0,.L113
        cmplw 0,27,20
        bgt+ 0,.L109
.L113:
        li 5,0
        li 11,0
        b .L97
        .cfi_endproc
        .size   fb_compress, .-fb_compress
        .section        ".got2","aw"
.LC35:
        .long .LANCHOR1
.LC37:
        .long .LC36
.LC39:
        .long .LC38
.LC41:
        .long .LC40
.LC43:
        .long .LC42
.LC45:
        .long .LC44
.LC47:
        .long .LC46
        .section        ".text"
        .align 2
        .globl fb_chacha20
.LCL5:
        .long .LCTOC1-.LCF5
        .type   fb_chacha20, @function
fb_chacha20:
        .cfi_startproc
        stwu 1,-608(1)
        .cfi_def_cfa_offset 608
        mflr 0
        .cfi_register 65, 0
        bcl 20,31,.LCF5
.LCF5:
        rlwinm 4,6,0,0,25
        or. 8,5,4
        stw 0,612(1)
        .cfi_offset 65, 4
        li 0,352
        stw 25,580(1)
        .cfi_offset 25, -28
        mr 25,3
        mr 3,5
        stw 30,600(1)
        .cfi_offset 30, -8
        mflr 30
        stvx 21,1,0
        li 0,368
        stvx 22,1,0
        li 0,384
        stvx 23,1,0
        li 0,400
        stvx 24,1,0
        li 0,416
        stvx 25,1,0
        li 0,432
        stvx 26,1,0
        li 0,448
        stvx 27,1,0
        li 0,464
        stvx 28,1,0
        li 0,480
        stvx 29,1,0
        li 0,496
        stvx 30,1,0
        li 0,512
        stvx 31,1,0
        lwz 0,.LCL5-.LCF5(30)
        add 30,0,30
        .cfi_offset 98, -256
        .cfi_offset 99, -240
        .cfi_offset 100, -224
        .cfi_offset 101, -208
        .cfi_offset 102, -192
        .cfi_offset 103, -176
        .cfi_offset 104, -160
        .cfi_offset 105, -144
        .cfi_offset 106, -128
        .cfi_offset 107, -112
        .cfi_offset 108, -96
        beq- 0,.L126
        stw 26,584(1)
        .cfi_offset 26, -24
        mr 26,9
        or. 9,26,10
        stw 16,544(1)
        .cfi_offset 16, -64
        mr 16,10
        beq- 0,.L137
        stw 29,596(1)
        .cfi_offset 29, -12
        li 10,16
        li 0,80
        lwz 29,.LC35-.LCTOC1(30)
        addi 11,7,15
        addi 3,7,31
        stw 17,548(1)
        .cfi_offset 17, -60
        addic 9,4,-1
        addi 8,25,64
        stw 19,556(1)
        .cfi_offset 19, -52
        srwi 9,9,6
        li 19,0
        lvx 1,29,10
        addme 10,5
        slwi 17,9,6
        stw 20,560(1)
        .cfi_offset 20, -48
        slwi 10,10,26
        li 5,96
        stw 21,564(1)
        .cfi_offset 21, -44
        add 9,10,9
        li 10,0
        stw 22,568(1)
        .cfi_offset 22, -40
        add 17,8,17
        li 29,0
        stw 24,576(1)
        .cfi_offset 24, -32
        addi 24,9,1
        li 22,16
        stw 27,588(1)
        .cfi_offset 27, -20
        li 21,32
        li 27,0
        stw 28,592(1)
        .cfi_offset 28, -16
        li 20,48
        li 28,0
        stw 31,604(1)
        .cfi_offset 31, -4
        neg 31,7
        vspltish 30,8
        stw 14,536(1)
        .cfi_offset 14, -72
        vxor 31,31,31
        stw 15,540(1)
        .cfi_offset 15, -68
        stw 18,552(1)
        .cfi_offset 18, -56
        stw 23,572(1)
        .cfi_offset 23, -36
        stvx 1,1,0
        lwz 6,.LC37-.LCTOC1(30)
        lvsr 1,0,31
        lvx 29,0,11
        lvx 28,0,7
        lvx 13,0,3
        lvx 0,0,6
        li 6,112
        vperm 28,28,29,1
        stw 10,140(1)
        vperm 29,29,13,1
        stw 10,136(1)
        vperm 28,28,28,0
        stw 10,132(1)
        vperm 29,29,29,0
        stw 25,332(1)
        stvx 28,1,5
        vor 26,28,28
        stvx 29,1,6
        vor 27,29,29
        stw 26,336(1)
        stw 24,340(1)
        stw 16,344(1)
        mr 16,17
.L130:
        lwz 23,332(1)
        mr 17,28
        stw 28,320(1)
        stw 29,324(1)
        stw 27,328(1)
.L134:
        li 5,64
        addi 4,1,80
        addi 3,1,16
        stw 17,128(1)
        bl memcpy@plt
        li 9,10
        mtctr 9
        lwz 31,16(1)
        mr 24,17
        lwz 7,32(1)
        addi 17,17,1
        mr 8,24
        lwz 0,48(1)
        lwz 28,20(1)
        lwz 6,36(1)
        lwz 5,68(1)
        lwz 11,52(1)
        lwz 29,24(1)
        lwz 9,40(1)
        lwz 3,72(1)
        lwz 25,56(1)
        lwz 27,28(1)
        lwz 10,44(1)
        lwz 4,76(1)
        lwz 26,60(1)
.L131:
        add 31,31,7
        add 28,28,6
        add 29,9,29
        add 27,10,27
        xor 8,31,8
        xor 5,28,5
        xor 3,29,3
        xor 4,27,4
        rotlwi 8,8,16
        rotlwi 5,5,16
        rotlwi 3,3,16
        rotlwi 4,4,16
        add 0,8,0
        add 11,5,11
        add 25,25,3
        add 26,26,4
        xor 7,0,7
        xor 6,11,6
        xor 9,25,9
        xor 10,26,10
        rotlwi 7,7,12
        rotlwi 6,6,12
        rotlwi 9,9,12
        rotlwi 10,10,12
        add 31,31,7
        add 28,28,6
        add 29,29,9
        add 27,27,10
        xor 8,31,8
        xor 5,28,5
        xor 3,29,3
        xor 4,27,4
        rotlwi 8,8,8
        rotlwi 5,5,8
        rotlwi 3,3,8
        rotlwi 4,4,8
        add 0,0,8
        add 11,11,5
        add 25,25,3
        add 26,26,4
        xor 7,0,7
        xor 6,11,6
        xor 9,25,9
        xor 10,26,10
        rotlwi 7,7,7
        rotlwi 6,6,7
        rotlwi 9,9,7
        rotlwi 10,10,7
        add 31,31,6
        add 28,28,9
        add 27,27,7
        add 29,29,10
        xor 8,28,8
        xor 3,27,3
        xor 4,31,4
        xor 5,29,5
        rotlwi 8,8,16
        rotlwi 3,3,16
        rotlwi 4,4,16
        rotlwi 5,5,16
        add 11,11,3
        add 25,25,4
        add 26,26,8
        add 0,0,5
        xor 7,11,7
        xor 6,25,6
        xor 9,26,9
        xor 10,0,10
        rotlwi 7,7,12
        rotlwi 6,6,12
        rotlwi 9,9,12
        rotlwi 10,10,12
        add 27,27,7
        add 31,31,6
        add 28,28,9
        add 29,29,10
        xor 3,27,3
        xor 4,31,4
        xor 8,28,8
        xor 5,29,5
        rotlwi 3,3,8
        rotlwi 4,4,8
        rotlwi 8,8,8
        rotlwi 5,5,8
        add 11,11,3
        add 25,25,4
        add 26,26,8
        add 0,0,5
        xor 7,11,7
        xor 6,25,6
        xor 9,26,9
        xor 10,0,10
        rotlwi 7,7,7
        rotlwi 6,6,7
        rotlwi 9,9,7
        rotlwi 10,10,7
        bdnz .L131
        andi. 14,23,0xf
        stw 31,16(1)
        stw 4,76(1)
        stw 25,56(1)
        stw 6,36(1)
        stw 28,20(1)
        stw 8,64(1)
        stw 26,60(1)
        stw 9,40(1)
        stw 29,24(1)
        stw 5,68(1)
        stw 0,48(1)
        stw 10,44(1)
        stw 27,28(1)
        stw 3,72(1)
        stw 11,52(1)
        stw 7,32(1)
        bne- 0,.L132
        lwz 10,.LC39-.LCTOC1(30)
        li 9,64
        li 8,128
        lvx 0,1,22
        lvx 1,1,9
        neg 9,23
        lvx 13,0,10
        addi 10,23,15
        vmrghw 8,0,0
        lvsr 10,0,9
        addi 9,23,31
        vmrglw 25,0,0
        lvx 5,0,23
        vadduwm 0,0,13
        lvx 13,1,8
        lvx 9,0,10
        addi 10,23,47
        lvx 6,0,9
        addi 9,23,63
        vadduwm 12,13,1
        lvx 1,1,21
        lvx 11,0,9
        addi 9,1,304
        vxor 13,12,0
        lvx 3,0,10
        vperm 18,9,6,10
        vadduwm 1,26,1
        lwz 10,.LC41-.LCTOC1(30)
        vmrghw 2,12,12
        stvx 5,0,9
        vpkuwum 7,0,1
        vxor 13,13,1
        lvx 0,1,20
        vperm 6,6,3,10
        lwz 9,.LC43-.LCTOC1(30)
        vperm 3,3,11,10
        vsrh 15,7,30
        lvx 16,0,10
        vperm 5,5,9,10
        lwz 10,.LC47-.LCTOC1(30)
        vadduwm 0,27,0
        vmrghw 19,1,1
        lvx 11,0,9
        vxor 13,13,0
        vpkuwum 14,0,12
        lwz 9,.LC45-.LCTOC1(30)
        vsldoi 17,13,31,8
        lvx 22,0,10
        vmrglw 1,1,1
        vsrh 4,14,30
        vadduwm 11,8,11
        vmrglw 9,0,0
        lvx 8,0,9
        vxor 17,17,13
        vmrglw 10,12,12
        vmrghw 13,0,0
        vadduwm 22,25,22
        li 9,160
        vpkuhum 25,5,18
        vpkuhum 23,6,3
        vsrw 12,1,8
        vperm 0,5,18,16
        vsrw 1,11,8
        vperm 21,6,3,16
        vsrw 11,22,8
        vsrw 19,19,8
        vpkuwum 1,1,11
        vsrw 13,13,8
        vpkuwum 19,19,12
        vsrw 9,9,8
        vsldoi 24,17,31,4
        vsrw 2,2,8
        vpkuhum 14,7,14
        vsrw 10,10,8
        vpkuhum 4,15,4
        vperm 25,25,23,16
        vxor 24,24,17
        vperm 0,0,21,16
        stvx 24,1,9
        vpkuwum 13,13,9
        vxor 4,4,25
        vpkuwum 2,2,10
        vxor 0,0,14
        vpkuwum 5,5,18
        lwz 9,160(1)
        vpkuwum 6,6,3
        vpkuhum 1,1,19
        vpkuhum 13,13,2
        xor 19,19,9
        vmrglb 12,0,4
        vxor 1,1,5
        vmrghb 0,0,4
        vxor 13,13,6
        vmrghh 11,12,13
        vmrglh 12,12,13
        vmrghh 13,0,1
        stvx 11,23,21
        vmrglh 0,0,1
        stvx 12,23,20
        stvx 13,0,23
        stvx 0,23,22
.L133:
        addi 23,23,64
        cmplw 0,16,23
        bne+ 0,.L134
        lwz 9,340(1)
        lwz 28,320(1)
        lwz 27,328(1)
        lwz 29,324(1)
        add 28,28,9
        lwz 9,336(1)
        addic 27,27,1
        addze 29,29
        cmplw 0,9,29
        bne+ 0,.L130
        lwz 9,344(1)
        cmplw 0,9,27
        bne+ 0,.L130
        mr 4,19
        lwz 14,536(1)
        .cfi_restore 14
        li 3,0
        lwz 15,540(1)
        .cfi_restore 15
        lwz 16,544(1)
        .cfi_restore 16
        lwz 17,548(1)
        .cfi_restore 17
        lwz 18,552(1)
        .cfi_restore 18
        lwz 19,556(1)
        .cfi_restore 19
        lwz 20,560(1)
        .cfi_restore 20
        lwz 21,564(1)
        .cfi_restore 21
        lwz 22,568(1)
        .cfi_restore 22
        lwz 23,572(1)
        .cfi_restore 23
        lwz 24,576(1)
        .cfi_restore 24
        lwz 26,584(1)
        .cfi_restore 26
        lwz 27,588(1)
        .cfi_restore 27
        lwz 28,592(1)
        .cfi_restore 28
        lwz 29,596(1)
        .cfi_restore 29
        lwz 31,604(1)
        .cfi_restore 31
.L126:
        li 0,352
        lwz 25,580(1)
        lvx 21,1,0
        li 0,368
        lvx 22,1,0
        li 0,384
        lvx 23,1,0
        li 0,400
        lvx 24,1,0
        li 0,416
        lvx 25,1,0
        li 0,432
        lvx 26,1,0
        li 0,448
        lvx 27,1,0
        li 0,464
        lvx 28,1,0
        li 0,480
        lvx 29,1,0
        li 0,496
        lvx 30,1,0
        li 0,512
        lvx 31,1,0
        lwz 0,612(1)
        lwz 30,600(1)
        addi 1,1,608
        .cfi_restore 30
        .cfi_restore 25
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
        .cfi_def_cfa_offset 0
        mtlr 0
        .cfi_restore 65
        blr
.L137:
        .cfi_def_cfa_offset 608
        .cfi_offset 16, -64
        .cfi_offset 25, -28
        .cfi_offset 26, -24
        .cfi_offset 30, -8
        .cfi_offset 98, -256
        .cfi_offset 99, -240
        .cfi_offset 100, -224
        .cfi_offset 101, -208
        .cfi_offset 102, -192
        .cfi_offset 103, -176
        .cfi_offset 104, -160
        .cfi_offset 105, -144
        .cfi_offset 106, -128
        .cfi_offset 107, -112
        .cfi_offset 108, -96
        .cfi_offset 65, 4
        mr 3,26
        lwz 16,544(1)
        .cfi_restore 16
        mr 4,10
        lwz 26,584(1)
        .cfi_restore 26
        b .L126
.L132:
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
        .cfi_offset 26, -24
        .cfi_offset 27, -20
        .cfi_offset 28, -16
        .cfi_offset 29, -12
        .cfi_offset 31, -4
        lbz 15,3(23)
        addis 31,31,0x6170
        addis 28,28,0x3320
        lbz 14,1(23)
        addi 31,31,30821
        addi 28,28,25710
        lbz 12,2(23)
        add 8,8,24
        addis 29,29,0x7962
        mtctr 15
        srwi 15,31,8
        lbz 24,6(23)
        xor 14,15,14
        lbz 15,5(23)
        addi 29,29,11570
        stb 14,1(23)
        srwi 14,31,16
        mfctr 18
        xor 12,14,12
        lbz 14,7(23)
        addis 27,27,0x6b20
        stb 12,2(23)
        srwi 12,31,24
        addi 27,27,25972
        xor 12,12,18
        mtctr 12
        lbz 12,9(23)
        mfctr 18
        stb 18,3(23)
        srwi 18,28,8
        xor 15,18,15
        lbz 18,10(23)
        stb 15,5(23)
        srwi 15,28,16
        xor 24,15,24
        lbz 15,11(23)
        stb 24,6(23)
        srwi 24,28,24
        mtctr 18
        xor 24,24,14
        lbz 14,13(23)
        stb 24,7(23)
        srwi 24,29,8
        mfctr 18
        xor 24,24,12
        lbz 12,14(23)
        stb 24,9(23)
        srwi 24,29,16
        xor 24,24,18
        lbz 18,15(23)
        stb 24,10(23)
        srwi 24,29,24
        xor 15,24,15
        lbz 24,0(23)
        stb 15,11(23)
        srwi 15,27,8
        mtctr 18
        xor 14,15,14
        lbz 15,4(23)
        xor 24,31,24
        stb 14,13(23)
        xor 31,31,28
        srwi 14,27,16
        xor 31,31,19
        mfctr 18
        xor 14,14,12
        lbz 12,8(23)
        xor 31,31,29
        xor 31,31,27
        xor 28,28,15
        lbz 15,12(23)
        xor 31,31,4
        srwi 19,27,24
        stb 24,0(23)
        xor 29,29,12
        xor 31,31,5
        xor 19,19,18
        stb 29,8(23)
        srwi 29,8,16
        xor 31,31,3
        mtctr 29
        srwi 29,8,24
        xor 24,27,15
        stb 19,15(23)
        mtlr 29
        xor 19,31,8
        li 29,176
        li 31,192
        stb 14,14(23)
        stb 28,4(23)
        srwi 18,5,8
        srwi 12,8,8
        stb 24,12(23)
        srwi 15,3,8
        stvx 28,1,29
        li 29,208
        stvx 28,1,31
        srwi 31,5,16
        stw 31,304(1)
        stvx 28,1,29
        li 29,224
        stvx 28,1,29
        lwz 29,196(1)
        lwz 27,216(1)
        lbz 28,21(23)
        lwz 31,176(1)
        add 29,29,6
        add 9,27,9
        srwi 6,29,8
        lwz 27,236(1)
        xor 6,6,28
        lbz 28,22(23)
        add 7,31,7
        lbz 31,23(23)
        add 10,27,10
        stb 6,21(23)
        srwi 6,29,16
        lbz 27,25(23)
        xor 6,6,28
        srwi 28,29,24
        stb 6,22(23)
        xor 6,28,31
        srwi 31,9,8
        lbz 28,26(23)
        lbz 24,27(23)
        xor 31,31,27
        srwi 27,9,16
        stb 31,25(23)
        lbz 31,24(23)
        xor 27,27,28
        srwi 28,9,24
        xor 28,28,24
        stb 6,23(23)
        srwi 24,7,8
        stb 28,27(23)
        xor 31,9,31
        lbz 28,17(23)
        lbz 6,20(23)
        stb 31,24(23)
        lbz 31,18(23)
        xor 28,24,28
        stb 27,26(23)
        srwi 27,7,16
        xor 6,29,6
        lbz 24,19(23)
        xor 31,27,31
        stb 28,17(23)
        lbz 27,28(23)
        lbz 28,16(23)
        stb 6,20(23)
        srwi 6,7,24
        xor 6,6,24
        xor 27,10,27
        stb 31,18(23)
        xor 28,7,28
        stb 6,19(23)
        li 6,240
        stb 28,16(23)
        srwi 24,10,8
        stb 27,28(23)
        srwi 27,10,16
        stvx 29,1,6
        li 6,256
        stvx 29,1,6
        li 6,272
        stvx 29,1,6
        lwz 6,280(1)
        lwz 31,240(1)
        lwz 28,260(1)
        add 6,6,25
        lbz 25,29(23)
        add 31,31,0
        add 28,28,11
        xor 0,19,31
        srwi 11,10,24
        xor 25,24,25
        xor 0,0,28
        srwi 24,31,8
        stb 25,29(23)
        xor 14,0,6
        lbz 25,33(23)
        lbz 0,31(23)
        lbz 19,30(23)
        xor 25,24,25
        lbz 24,34(23)
        xor 0,11,0
        srwi 11,31,16
        stb 25,33(23)
        xor 27,27,19
        stb 0,31(23)
        srwi 0,28,8
        xor 11,11,24
        lbz 24,35(23)
        srwi 25,28,16
        stb 27,30(23)
        srwi 27,31,24
        stb 11,34(23)
        srwi 11,28,24
        xor 27,27,24
        lbz 24,32(23)
        stb 27,35(23)
        srwi 27,6,8
        xor 31,31,24
        lbz 24,37(23)
        stb 31,32(23)
        lbz 31,38(23)
        xor 0,0,24
        lbz 24,39(23)
        stb 0,37(23)
        xor 31,25,31
        lbz 0,36(23)
        lbz 25,41(23)
        xor 11,11,24
        srwi 24,5,24
        stb 31,38(23)
        lbz 31,40(23)
        xor 0,28,0
        xor 25,27,25
        stb 11,39(23)
        srwi 27,6,24
        stb 0,36(23)
        srwi 11,6,16
        li 0,288
        xor 6,6,31
        stb 25,41(23)
        stb 6,40(23)
        lbz 6,42(23)
        stvx 29,1,0
        xor 11,11,6
        lwz 6,300(1)
        lbz 31,45(23)
        lbz 25,50(23)
        add 6,6,26
        stb 11,42(23)
        srwi 28,6,8
        xor 14,14,6
        lbz 11,46(23)
        xor 28,28,31
        lbz 31,44(23)
        xor 7,14,7
        lbz 26,47(23)
        xor 7,7,29
        srwi 29,6,16
        xor 7,7,9
        srwi 9,6,24
        lbz 0,43(23)
        xor 31,6,31
        mfctr 6
        xor 29,29,11
        xor 9,9,26
        lbz 11,51(23)
        xor 25,6,25
        lbz 26,48(23)
        xor 19,7,10
        mflr 10
        lbz 6,52(23)
        xor 27,27,0
        lbz 7,53(23)
        xor 11,10,11
        lbz 0,49(23)
        xor 26,8,26
        lbz 10,54(23)
        xor 6,5,6
        lbz 8,55(23)
        xor 7,18,7
        lbz 5,56(23)
        xor 0,12,0
        lwz 18,304(1)
        xor 8,24,8
        stb 27,43(23)
        srwi 27,3,16
        xor 5,3,5
        stb 28,45(23)
        srwi 28,3,24
        xor 10,18,10
        stb 29,46(23)
        srwi 3,4,8
        stb 9,47(23)
        srwi 29,4,16
        srwi 9,4,24
        stb 11,51(23)
        stb 6,52(23)
        stb 7,53(23)
        stb 10,54(23)
        stb 8,55(23)
        stb 31,44(23)
        stb 0,49(23)
        stb 25,50(23)
        stb 26,48(23)
        stb 5,56(23)
        lbz 7,59(23)
        lbz 8,57(23)
        lbz 10,58(23)
        lbz 11,60(23)
        xor 28,28,7
        lbz 5,61(23)
        xor 8,15,8
        lbz 6,62(23)
        xor 10,27,10
        lbz 7,63(23)
        xor 4,4,11
        xor 3,3,5
        stb 8,57(23)
        xor 29,29,6
        stb 10,58(23)
        xor 9,9,7
        stb 28,59(23)
        stb 4,60(23)
        stb 3,61(23)
        stb 29,62(23)
        stb 9,63(23)
        b .L133
        .cfi_endproc
        .size   fb_chacha20, .-fb_chacha20
        .section        ".got2","aw"
.LC50:
        .long .LC49
.LC53:
        .long .LC52
        .set .LC54,.LC23
.LC57:
        .long .LC56
        .section        ".text"
        .align 2
        .globl fb_physics
.LCL6:
        .long .LCTOC1-.LCF6
        .type   fb_physics, @function
fb_physics:
        .cfi_startproc
        stwu 1,-128(1)
        .cfi_def_cfa_offset 128
        mflr 0
        .cfi_register 65, 0
        bcl 20,31,.LCF6
.LCF6:
        or. 9,5,6
        stw 24,48(1)
        .cfi_offset 24, -80
        mr 24,5
        stw 26,56(1)
        .cfi_offset 26, -72
        mr 26,6
        stw 30,72(1)
        .cfi_offset 30, -56
        mflr 30
        stw 0,132(1)
        .cfi_offset 65, 4
        lwz 0,.LCL6-.LCF6(30)
        add 30,0,30
        beq- 0,.L161
        or. 9,7,8
        stw 17,20(1)
        .cfi_offset 17, -108
        mr 17,8
        stw 18,24(1)
        .cfi_offset 18, -104
        mr 18,7
        beq- 0,.L162
        lwz 9,.LC50-.LCTOC1(30)
        stw 21,36(1)
        .cfi_offset 21, -92
        stw 23,44(1)
        .cfi_offset 23, -84
        lfs 0,0(9)
        stw 25,52(1)
        .cfi_offset 25, -76
        stw 27,60(1)
        .cfi_offset 27, -68
        stw 28,64(1)
        .cfi_offset 28, -64
        stw 29,68(1)
        .cfi_offset 29, -60
        stw 31,76(1)
        .cfi_offset 31, -52
        stfd 26,80(1)
        .cfi_offset 58, -48
        stfd 27,88(1)
        .cfi_offset 59, -40
        stfd 28,96(1)
        .cfi_offset 60, -32
        stfd 29,104(1)
        .cfi_offset 61, -24
        stfd 30,112(1)
        .cfi_offset 62, -16
        stfd 31,120(1)
        .cfi_offset 63, -8
        lwz 21,.LC57-.LCTOC1(30)
        stfs 0,8(1)
        stw 16,16(1)
        .cfi_offset 16, -112
        mr 16,9
        stw 19,28(1)
        .cfi_offset 19, -100
        li 19,0
        stw 20,32(1)
        .cfi_offset 20, -96
        li 20,0
        stw 22,40(1)
        .cfi_offset 22, -88
        mr 22,3
.L150:
        mr 27,22
        li 25,0
        li 23,0
.L159:
        lfs 26,8(1)
        mr 29,22
        mr 28,24
        mr 31,26
        fmr 27,26
        fmr 28,26
        b .L153
.L163:
        lfd 0,0(29)
        addi 29,29,64
        lfd 12,0(27)
        lwz 9,.LC53-.LCTOC1(30)
        fsub 29,0,12
        lfd 0,-56(29)
        lfd 12,8(27)
        lfs 1,0(9)
        fsub 30,0,12
        lfd 0,-48(29)
        lfd 12,16(27)
        fmul 11,30,30
        fsub 31,0,12
        fmul 0,29,29
        fmul 12,31,31
        fadd 0,0,11
        fadd 0,0,12
        fadd 1,0,1
        bl sqrt@plt
        lwz 9,.LC54-.LCTOC1(30)
        addic 31,31,-1
        addme 28,28
        lfs 0,0(9)
        or. 9,28,31
        fdiv 0,0,1
        fmul 1,0,0
        fmul 1,1,0
        lfd 0,-40(29)
        fmul 1,1,0
        fmul 29,29,1
        fmul 30,30,1
        fmul 31,31,1
        fadd 28,28,29
        fadd 27,27,30
        fadd 26,26,31
        beq- 0,.L179
.L153:
        subfc 10,31,26
        subfe 9,28,24
        cmplw 0,25,9
        bne+ 0,.L163
        cmplw 0,23,10
        bne+ 0,.L163
        addic 31,31,-1
        addi 29,29,64
        addme 28,28
        or. 9,28,31
        bne+ 0,.L153
.L179:
        lfs 0,0(21)
        addic 23,23,1
        addi 27,27,64
        addze 25,25
        cmplw 0,24,25
        fmr 12,0
        fmul 28,28,12
        fmul 27,27,12
        fmul 26,26,12
        lfd 12,-32(27)
        fadd 10,12,28
        lfd 12,-24(27)
        fadd 11,12,27
        lfd 12,-16(27)
        stfd 10,-32(27)
        fadd 12,12,26
        stfd 11,-24(27)
        stfd 12,-16(27)
        bne+ 0,.L159
        cmplw 0,26,23
        bne+ 0,.L159
        mr 9,22
        mtctr 26
.L156:
        lfd 12,32(9)
        addi 9,9,64
        lfd 9,-64(9)
        fmul 10,12,0
        lfd 12,-24(9)
        fmul 11,12,0
        lfd 12,-16(9)
        fadd 10,9,10
        lfd 9,-56(9)
        fmul 12,12,0
        fadd 11,9,11
        lfd 9,-48(9)
        stfd 10,-64(9)
        fadd 12,9,12
        stfd 11,-56(9)
        stfd 12,-48(9)
        bdnz .L156
        addic 20,20,1
        addze 19,19
        cmplw 0,18,19
        bne+ 0,.L150
        cmplw 0,17,20
        bne+ 0,.L150
        lfs 0,0(16)
        andi. 9,26,0x1
        addi 10,26,-1
        addi 9,22,32
        stfd 0,8(1)
        beq- 0,.L168
        cmpwi 0,10,0
        lfd 0,0(9)
        lfd 11,8(9)
        lfd 12,16(9)
        addi 9,22,96
        fadd 0,0,11
        fadd 0,0,12
        lfd 12,8(1)
        fadd 0,12,0
        stfd 0,8(1)
        beq- 0,.L174
.L168:
        srwi 10,26,1
        mtctr 10
.L160:
        lfd 11,8(9)
        mr 10,9
        addi 9,9,128
        lfd 0,-128(9)
        lfd 9,-56(9)
        lfd 12,-64(9)
        lfd 10,-112(9)
        fadd 0,0,11
        lfd 11,80(10)
        fadd 12,12,9
        fadd 0,0,10
        fadd 12,12,11
        lfd 11,8(1)
        fadd 0,11,0
        fadd 0,0,12
        stfd 0,8(1)
        bdnz .L160
.L174:
        lwz 0,132(1)
        lwz 3,8(1)
        lwz 4,12(1)
        lfd 26,80(1)
        .cfi_restore 58
        mtlr 0
        .cfi_restore 65
        lfd 27,88(1)
        .cfi_restore 59
        lfd 28,96(1)
        .cfi_restore 60
        lfd 29,104(1)
        .cfi_restore 61
        lfd 30,112(1)
        .cfi_restore 62
        lfd 31,120(1)
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
        lwz 23,44(1)
        .cfi_restore 23
        lwz 25,52(1)
        .cfi_restore 25
        lwz 27,60(1)
        .cfi_restore 27
        lwz 28,64(1)
        .cfi_restore 28
        lwz 29,68(1)
        .cfi_restore 29
        lwz 31,76(1)
        .cfi_restore 31
        lwz 24,48(1)
        lwz 26,56(1)
        lwz 30,72(1)
        addi 1,1,128
        .cfi_restore 30
        .cfi_restore 26
        .cfi_restore 24
        .cfi_def_cfa_offset 0
        blr
.L162:
        .cfi_def_cfa_offset 128
        .cfi_offset 17, -108
        .cfi_offset 18, -104
        .cfi_offset 24, -80
        .cfi_offset 26, -72
        .cfi_offset 30, -56
        .cfi_offset 65, 4
        lwz 0,132(1)
        mr 3,7
        mr 4,8
        lwz 17,20(1)
        .cfi_restore 17
        lwz 18,24(1)
        .cfi_restore 18
        lwz 24,48(1)
        mtlr 0
        .cfi_restore 65
        lwz 26,56(1)
        lwz 30,72(1)
        addi 1,1,128
        .cfi_restore 30
        .cfi_restore 26
        .cfi_restore 24
        .cfi_def_cfa_offset 0
        blr
.L161:
        .cfi_def_cfa_offset 128
        .cfi_offset 24, -80
        .cfi_offset 26, -72
        .cfi_offset 30, -56
        .cfi_offset 65, 4
        lwz 0,132(1)
        mr 3,5
        mr 4,6
        lwz 24,48(1)
        lwz 26,56(1)
        lwz 30,72(1)
        mtlr 0
        .cfi_restore 65
        addi 1,1,128
        .cfi_restore 30
        .cfi_restore 26
        .cfi_restore 24
        .cfi_def_cfa_offset 0
        blr
        .cfi_endproc
        .size   fb_physics, .-fb_physics
        .align 2
        .globl fb_sort
        .type   fb_sort, @function
fb_sort:
        .cfi_startproc
        mr. 11,5
        beq- 0,.L217
.L181:
        stwu 1,-48(1)
        .cfi_def_cfa_offset 48
        srwi 10,6,1
        slwi 9,11,31
        add 9,9,10
        stw 26,24(1)
        .cfi_offset 26, -24
        srwi 26,11,1
        slwi 10,26,1
        stw 25,20(1)
        .cfi_offset 25, -28
        srwi 25,9,31
        stw 27,28(1)
        .cfi_offset 27, -20
        addic 27,9,-1
        slwi 9,9,1
        stw 29,36(1)
        addme 26,26
        add 25,25,10
        stw 31,44(1)
        stw 28,32(1)
        .cfi_offset 29, -12
        .cfi_offset 31, -4
        .cfi_offset 28, -16
        addic 28,9,-1
        addme 25,25
.L212:
        cmplw 0,11,25
        ble- 0,.L218
.L208:
        slwi 9,27,2
        mr 8,25
        mr 10,28
        lwzx 29,3,9
        mr 5,27
        mr 9,26
.L191:
        addic 0,5,1
        slwi 7,10,2
        addze 9,9
        srwi 12,0,31
        add 31,3,7
        slwi 9,9,1
        lwzx 4,3,7
        slwi 0,0,1
        add 9,12,9
        mr 12,31
        cmplw 0,11,9
        bgt- 0,.L187
        bne- 0,.L190
        cmplw 0,6,0
        ble- 0,.L190
.L187:
        lwz 7,4(31)
        cmplw 0,7,4
        ble- 0,.L190
        slwi 12,0,2
        lwzx 4,3,12
        add 12,3,12
.L189:
        cmplw 0,29,4
        bge- 0,.L185
        slwi 10,0,1
        srwi 8,0,31
        slwi 7,9,1
        addic 10,10,1
        slwi 5,5,2
        adde 8,8,7
        stwx 4,3,5
        cmplw 0,11,8
        stw 29,0(12)
        ble- 0,.L219
.L206:
        mr 5,0
        b .L191
.L219:
        bne- 0,.L185
        cmplw 0,6,10
        bgt+ 0,.L206
.L185:
        addic 27,27,-1
        addme 26,26
        addic 28,28,-2
        cmpwi 0,26,-1
        addme 25,25
        bne+ 0,.L212
        cmpwi 0,27,-1
        bne+ 0,.L212
        addic 27,6,-1
        addi 9,3,4
        slwi 26,27,2
        addme 29,11
        add 26,26,9
        cmpwi 0,29,0
        lwz 9,0(3)
        lwzu 10,-4(26)
        stw 10,0(3)
        stw 9,0(26)
        beq- 0,.L220
.L209:
        lwz 28,0(3)
        li 7,0
        li 8,1
        li 9,0
        li 4,0
.L202:
        addic 10,4,1
        slwi 5,8,2
        addze 9,9
        srwi 12,10,31
        add 31,3,5
        slwi 9,9,1
        lwzx 0,3,5
        slwi 10,10,1
        add 9,12,9
        mr 12,31
        cmplw 0,29,9
        bgt- 0,.L196
        bne- 0,.L199
        cmplw 0,27,10
        ble- 0,.L199
.L196:
        lwz 5,4(31)
        cmplw 0,5,0
        ble- 0,.L199
        slwi 12,10,2
        lwzx 0,3,12
        add 12,3,12
.L198:
        cmplw 0,28,0
        bge- 0,.L200
        slwi 8,10,1
        srwi 7,10,31
        slwi 5,9,1
        addic 8,8,1
        slwi 4,4,2
        adde 7,7,5
        stwx 0,3,4
        cmplw 0,29,7
        stw 28,0(12)
        ble- 0,.L221
.L210:
        mr 4,10
        b .L202
.L221:
        bne- 0,.L200
        cmplw 0,27,8
        bgt+ 0,.L210
.L200:
        addic 27,27,-1
        lwz 9,0(3)
        addme 29,29
        lwzu 10,-4(26)
        cmpwi 0,29,0
        stw 10,0(3)
        stw 9,0(26)
        bne+ 0,.L209
.L220:
        cmplwi 0,27,1
        bne+ 0,.L209
        addi 9,3,-4
        li 4,0
        li 3,0
.L203:
        lwzu 8,4(9)
        srwi 7,4,7
        slwi 10,3,25
        add 10,10,7
        srwi 3,3,7
        slwi 7,4,25
        xor 10,8,10
        addc 4,8,10
        adde 3,7,3
        addic 6,6,-1
        addme 11,11
        or. 10,11,6
        bne+ 0,.L203
        lwz 25,20(1)
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
        .cfi_restore 25
        .cfi_def_cfa_offset 0
        blr
.L190:
        .cfi_restore_state
        mr 9,8
        mr 0,10
        b .L189
.L199:
        mr 9,7
        mr 10,8
        b .L198
.L218:
        bne- 0,.L185
        cmplw 0,6,28
        bgt+ 0,.L208
        b .L185
.L217:
        .cfi_def_cfa_offset 0
        .cfi_restore 25
        .cfi_restore 26
        .cfi_restore 27
        .cfi_restore 28
        .cfi_restore 29
        .cfi_restore 31
        cmplwi 0,6,1
        bgt+ 0,.L181
        cmpwi 0,6,0
        bne- 0,.L222
        li 3,0
        li 4,0
        blr
.L222:
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
        beq- 0,.L227
        mr 4,3
.L226:
        addic 6,6,-1
        lwz 4,0(4)
        addme 5,5
        or. 10,5,6
        bne+ 0,.L226
        subf 4,3,4
        li 3,0
        blr
.L227:
        mr 3,5
        mr 4,6
        blr
        .cfi_endproc
        .size   fb_chase, .-fb_chase
        .section        .rodata.cst4,"aM",@progbits,4
        .align 2
.LC1:
        .long   1056964608
        .align 2
.LC4:
        .long   1080033280
        .align 2
.LC7:
        .long   1075838976
        .align 2
.LC10:
        .long   1069547520
        .align 2
.LC13:
        .long   1065877504
        .align 2
.LC16:
        .long   981467136
        .align 2
.LC19:
        .long   1073741824
        .align 2
.LC22:
        .long   1065353216
        .section        .rodata.cst16,"aM",@progbits,16
        .align 4
.LC36:
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
.LC38:
        .long   1634760805
        .long   857760878
        .long   2036477234
        .long   1797285236
        .align 4
.LC40:
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
.LC42:
        .long   1634760805
        .long   1634760805
        .long   857760878
        .long   857760878
        .align 4
.LC44:
        .long   16
        .long   24
        .long   16
        .long   24
        .align 4
.LC46:
        .long   2036477234
        .long   2036477234
        .long   1797285236
        .long   1797285236
        .section        .rodata.cst4
        .align 2
.LC49:
        .long   0
        .align 2
.LC52:
        .long   1031798784
        .align 2
.LC56:
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
