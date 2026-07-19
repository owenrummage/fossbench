        .file   "fossbench-ppc64be.S"
        .machine power4
        .machine altivec
        .section        ".text"
        .align 2
        .p2align 4,,15
        .globl fb_int_math
        .section        ".opd","aw"
        .align 3
fb_int_math:
        .quad   .L.fb_int_math,.TOC.@tocbase,0
        .previous
        .type   fb_int_math, @function
.L.fb_int_math:
        .cfi_startproc
        cmpdi 0,3,0
        beq 0,.L4
        lis 12,0x2545
        lis 11,0x94d0
        lis 7,0x4f6c
        lis 8,0x1331
        ori 12,12,0xf491
        lis 10,0x1ce4
        lis 4,0xbf58
        lis 9,0x7f4a
        mtctr 12
        ori 12,11,0x49bb
        lis 5,0x9e37
        lis 0,0xdfc9
        lis 6,0x9327
        ori 7,7,0xdd1d
        ori 8,8,0x11eb
        mfctr 11
        ori 10,10,0xe5b9
        ori 4,4,0x476d
        mtctr 3
        ori 9,9,0x7c15
        ori 5,5,0x79b9
        ori 0,0,0x94b
        ori 6,6,0x5ab2
        rldimi 7,11,32,0
        lis 11,0xdead
        rldimi 8,12,32,0
        rldimi 10,4,32,0
        ori 11,11,0xbeef
        rldimi 9,5,32,0
        rldimi 0,6,32,0
        rldicl 11,11,0,32
        .p2align 4,,15
.L3:
        mulld 9,9,11
        mulld 6,7,11
        mulld 4,8,11
        mulld 5,10,11
        add 9,9,10
        add 4,4,7
        add 8,5,8
        add 10,6,9
        srdi 5,4,29
        sldi 6,10,17
        xor 5,5,9
        xor 6,6,8
        rotldi 8,5,33
        srdi 7,6,7
        xor 8,8,4
        xor 7,7,10
        mulhdu 9,8,0
        mulhdu 10,7,0
        srdi 9,9,31
        srdi 10,10,31
        add 9,9,5
        add 10,10,6
        bdnz .L3
        xor 3,8,7
        xor 3,3,9
        xor 3,3,10
        blr
        .p2align 4,,15
.L4:
        li 3,0
        blr
        .long 0
        .byte 0,0,0,0,0,0,0,0
        .cfi_endproc
        .size   fb_int_math,.-.L.fb_int_math
        .align 2
        .p2align 4,,15
        .globl fb_fp_math
        .section        ".opd","aw"
        .align 3
fb_fp_math:
        .quad   .L.fb_fp_math,.TOC.@tocbase,0
        .previous
        .type   fb_fp_math, @function
.L.fb_fp_math:
        .cfi_startproc
        cmpdi 0,3,0
        beq 0,.L28
        addis 10,2,.LC20@toc@ha
        addis 9,2,.LC6@toc@ha
        stdu 1,-240(1)
        .cfi_def_cfa_offset 240
        addis 5,2,.LC18@toc@ha
        addi 10,10,.LC20@toc@l
        lfs 12,.LC6@toc@l(9)
        addis 9,2,.LC8@toc@ha
        lfs 6,.LC18@toc@l(5)
        addis 5,2,.LC22@toc@ha
        lfs 4,0(10)
        addis 6,2,.LC16@toc@ha
        addis 7,2,.LC18@toc@ha
        lfs 9,.LC8@toc@l(9)
        addis 9,2,.LC10@toc@ha
        lfs 2,.LC22@toc@l(5)
        addis 8,2,.LC22@toc@ha
        addi 6,6,.LC16@toc@l
        addi 7,7,.LC18@toc@l
        lfs 0,.LC10@toc@l(9)
        addis 9,2,.LC12@toc@ha
        addi 8,8,.LC22@toc@l
        lfs 11,.LC12@toc@l(9)
        addis 9,2,.LC16@toc@ha
        fmr 7,4
        fmr 3,4
        lfs 5,.LC16@toc@l(9)
        addis 9,2,.LC14@toc@ha
        addi 9,9,.LC14@toc@l
        .p2align 4,,15
.L27:
        fmul 10,11,5
        fmul 0,0,5
        fmul 11,9,5
        fmr 8,7
        fadd 10,10,6
        fadd 9,0,6
        fadd 11,11,6
        fcmpu 0,10,7
        bnl 0,.L11
        fmr 8,10
.L11:
        fcmpu 0,9,3
        fmr 0,7
        bnl 0,.L13
        fmr 0,9
.L13:
        fcmpu 0,11,4
        fmr 9,7
        bnl 0,.L15
        fmr 9,11
.L15:
        fcmpu 0,8,2
        blt 0,.L37
        fsqrt 11,8
.L18:
        lfs 10,0(8)
        fadd 9,9,11
        fcmpu 0,0,10
        blt 0,.L38
        lfs 10,0(6)
        lfs 1,0(7)
        lfs 11,0(10)
        fmul 12,12,10
        fmr 13,11
        fadd 12,12,1
        fcmpu 0,12,13
        bnl 0,.L22
        fmr 11,12
.L22:
        fsqrt 10,0
        lfs 12,0(9)
        fmr 13,12
        fadd 10,10,11
        fcmpu 0,10,13
        bng 0,.L24
        fmr 12,10
.L24:
        lfs 11,0(9)
        addic. 3,3,-1
        fadd 10,12,11
        fadd 13,9,11
        fdiv 10,11,10
        fdiv 11,11,13
        fadd 0,10,0
        fadd 11,11,8
        bne 0,.L27
.L26:
        fadd 0,0,11
        fadd 0,0,9
        fadd 0,0,12
        stfd 0,112(1)
        ld 3,112(1)
        addi 1,1,240
        .cfi_def_cfa_offset 0
        blr
        .p2align 4,,15
.L28:
        li 3,0
        blr
.L38:
        .cfi_def_cfa_offset 240
        mflr 0
        .cfi_register 65, 0
        fmr 1,0
        std 9,208(1)
        std 10,176(1)
        stfd 8,152(1)
        std 3,128(1)
        stfd 9,120(1)
        stfd 0,112(1)
        std 0,256(1)
        .cfi_offset 65, 16
        std 7,224(1)
        std 6,216(1)
        stfd 4,200(1)
        stfd 3,192(1)
        std 8,184(1)
        stfd 7,168(1)
        stfd 2,160(1)
        stfd 6,144(1)
        stfd 5,136(1)
        bl sqrt
        nop
        ld 9,208(1)
        addis 10,2,.LC6@toc@ha
        lfd 0,112(1)
        lfd 9,120(1)
        ld 3,128(1)
        lfs 10,.LC6@toc@l(10)
        lfd 8,152(1)
        lfs 12,0(9)
        addic. 3,3,-1
        fadd 0,0,10
        fmr 11,12
        fadd 10,9,11
        fdiv 11,11,10
        fadd 11,11,8
        beq 0,.L43
        ld 0,256(1)
        lfd 5,136(1)
        lfd 6,144(1)
        lfd 2,160(1)
        lfd 7,168(1)
        lfd 3,192(1)
        lfd 4,200(1)
        ld 10,176(1)
        mtlr 0
        .cfi_restore 65
        ld 8,184(1)
        ld 6,216(1)
        ld 7,224(1)
        b .L27
.L37:
        mflr 0
        .cfi_register 65, 0
        fmr 1,8
        std 7,232(1)
        std 6,224(1)
        std 9,216(1)
        stfd 4,208(1)
        stfd 3,200(1)
        std 8,192(1)
        std 0,256(1)
        .cfi_offset 65, 16
        std 10,184(1)
        stfd 7,176(1)
        stfd 2,168(1)
        stfd 9,160(1)
        stfd 0,152(1)
        stfd 6,144(1)
        stfd 5,136(1)
        std 3,128(1)
        stfd 12,120(1)
        stfd 8,112(1)
        bl sqrt
        nop
        ld 0,256(1)
        lfd 4,208(1)
        fmr 11,1
        lfd 3,200(1)
        lfd 7,176(1)
        lfd 2,168(1)
        lfd 9,160(1)
        lfd 0,152(1)
        lfd 6,144(1)
        mtlr 0
        .cfi_remember_state
        .cfi_restore 65
        lfd 5,136(1)
        lfd 12,120(1)
        lfd 8,112(1)
        ld 7,232(1)
        ld 6,224(1)
        ld 9,216(1)
        ld 8,192(1)
        ld 10,184(1)
        ld 3,128(1)
        b .L18
.L43:
        .cfi_restore_state
        ld 0,256(1)
        mtlr 0
        .cfi_restore 65
        b .L26
        .long 0
        .byte 0,0,0,1,128,0,0,0
        .cfi_endproc
        .size   fb_fp_math,.-.L.fb_fp_math
        .align 2
        .p2align 4,,15
        .globl fb_primes
        .section        ".opd","aw"
        .align 3
fb_primes:
        .quad   .L.fb_primes,.TOC.@tocbase,0
        .previous
        .type   fb_primes, @function
.L.fb_primes:
        .cfi_startproc
        cmpldi 0,3,1
        ble 0,.L64
        mflr 0
        mr 8,4
        mr 5,3
        li 4,0
        std 0,16(1)
        stdu 1,-112(1)
        .cfi_def_cfa_offset 112
        .cfi_offset 65, 16
        std 3,160(1)
        mr 3,8
        bl memset
        nop
        ld 5,160(1)
        li 9,257
        mr 8,3
        sth 9,0(3)
        addi 6,5,-1
        cmpldi 0,6,3
        ble 0,.L46
        li 10,2
        li 7,1
        b .L49
        .p2align 4,,15
.L47:
        addi 10,10,1
        divdu 9,6,10
        cmpld 0,9,10
        blt 0,.L50
.L49:
        lbzx 9,8,10
        cmpwi 0,9,0
        bne 0,.L47
        mulld 9,10,10
        cmpld 0,9,5
        bge 0,.L47
        .p2align 4,,15
.L48:
        stbx 7,8,9
        add 9,9,10
        cmpld 0,5,9
        bgt 0,.L48
        addi 10,10,1
        divdu 9,6,10
        cmpld 0,9,10
        bge 0,.L49
.L50:
        andi. 9,5,0x1
        addi 8,8,1
        li 3,0
        li 6,0
        addi 9,5,-2
        bne 0,.L67
.L57:
        srdi 9,9,1
        mtctr 9
.L52:
        lbz 10,1(8)
        lbz 9,2(8)
        addi 8,8,2
        cntlzw 10,10
        cntlzw 9,9
        srwi 10,10,5
        srwi 9,9,5
        add 3,3,10
        add 6,6,9
        bdnz .L52
.L61:
        addi 1,1,112
        .cfi_remember_state
        .cfi_def_cfa_offset 0
        add 3,3,6
        ld 0,16(1)
        mtlr 0
        .cfi_restore 65
        blr
        .p2align 4,,15
.L67:
        .cfi_restore_state
        lbzu 3,1(8)
        cmpdi 0,5,3
        cntlzw 3,3
        srwi 3,3,5
        bne 0,.L57
        b .L61
        .p2align 4,,15
.L64:
        .cfi_def_cfa_offset 0
        .cfi_restore 65
        li 3,0
        blr
.L46:
        .cfi_def_cfa_offset 112
        .cfi_offset 65, 16
        cmpldi 0,5,2
        bne 0,.L50
        addi 1,1,112
        .cfi_def_cfa_offset 0
        li 3,0
        ld 0,16(1)
        mtlr 0
        .cfi_restore 65
        blr
        .long 0
        .byte 0,0,0,1,128,0,0,0
        .cfi_endproc
        .size   fb_primes,.-.L.fb_primes
        .align 2
        .p2align 4,,15
        .globl fb_simd
        .section        ".opd","aw"
        .align 3
fb_simd:
        .quad   .L.fb_simd,.TOC.@tocbase,0
        .previous
        .type   fb_simd, @function
.L.fb_simd:
        .cfi_startproc
        cmpdi 0,3,0
        beqlr 0
        ld 11,0(4)
        ld 6,24(4)
        addi 10,1,-80
        andi. 8,3,0x1
        ld 0,16(4)
        ld 5,8(4)
        li 8,48
        li 7,64
        addi 9,4,16
        std 11,-80(1)
        std 6,-88(1)
        addi 6,1,-144
        addi 11,3,-1
        std 0,-96(1)
        std 5,8(10)
        lvx 1,6,8
        lvx 0,6,7
        beq 0,.L75
        vadduwm 0,0,1
        cmpdi 0,11,0
        vxor 1,0,1
        vadduwm 0,0,1
        vxor 1,1,0
        beq 0,.L80
.L75:
        srdi 8,3,1
        mtctr 8
.L70:
        vadduwm 0,0,1
        vxor 1,0,1
        vadduwm 0,0,1
        vxor 1,1,0
        vadduwm 0,0,1
        vxor 1,0,1
        vadduwm 0,0,1
        vxor 1,1,0
        bdnz .L70
.L80:
        addi 7,1,-144
        li 8,64
        addi 11,1,-144
        li 3,48
        stvx 0,7,8
        li 5,80
        li 6,96
        li 7,112
        li 8,128
        stvx 1,11,3
        stvx 0,11,5
        stvx 0,11,6
        stvx 0,11,7
        stvx 0,11,8
        ld 3,8(10)
        ld 5,-80(1)
        ld 6,-96(1)
        ld 10,-88(1)
        lwz 7,-64(1)
        lwz 8,-44(1)
        std 3,8(4)
        std 5,0(4)
        std 6,16(4)
        std 10,8(9)
        lwz 3,16(4)
        lwz 11,20(4)
        lwz 5,24(4)
        lwz 6,28(4)
        lwz 10,-24(1)
        lwz 9,-4(1)
        xor 3,3,11
        xor 3,3,5
        xor 3,3,6
        xor 3,3,7
        xor 3,3,8
        xor 3,3,10
        xor 3,3,9
        rldicl 3,3,0,32
        blr
        .long 0
        .byte 0,0,0,0,0,0,0,0
        .cfi_endproc
        .size   fb_simd,.-.L.fb_simd
        .align 2
        .p2align 4,,15
        .globl fb_compress
        .section        ".opd","aw"
        .align 3
fb_compress:
        .quad   .L.fb_compress,.TOC.@tocbase,0
        .previous
        .type   fb_compress, @function
.L.fb_compress:
        .cfi_startproc
        mflr 0
        std 30,-16(1)
        std 31,-8(1)
        mr 6,5
        .cfi_register 65, 0
        .cfi_offset 30, -16
        .cfi_offset 31, -8
        mr 30,4
        std 0,16(1)
        stdu 1,-144(1)
        .cfi_def_cfa_offset 144
        .cfi_offset 65, 16
        lis 5,0x4
        li 4,0
        mr 31,3
        mr 3,6
        bl memset
        nop
        cmpldi 0,30,15
        addi 9,30,1
        mtlr 9
        ble 0,.L82
        lis 4,0x9e37
        mr 6,3
        addi 0,30,-12
        li 11,0
        li 3,0
        ori 4,4,0x79b1
        li 9,0
        .p2align 4,,15
.L89:
        lwzx 7,31,9
        mullw 10,7,4
        rlwinm 10,10,18,14,29
        lwzx 8,6,10
        stwx 9,6,10
        cmpld 0,8,9
        bge 0,.L84
        subf 10,8,9
        cmpldi 0,10,65535
        bgt 0,.L84
        lwzx 10,31,8
        add 8,31,8
        cmpw 0,10,7
        beq 0,.L109
.L84:
        addi 9,9,1
.L87:
        cmpld 0,9,0
        blt 0,.L89
        mflr 9
        add 11,11,9
        subf 9,3,11
        mtlr 9
.L82:
        mflr 3
        addi 1,1,144
        .cfi_remember_state
        .cfi_def_cfa_offset 0
        ld 0,16(1)
        ld 30,-16(1)
        ld 31,-8(1)
        mtlr 0
        .cfi_restore 65
        .cfi_restore 31
        .cfi_restore 30
        blr
        .p2align 4,,15
.L109:
        .cfi_restore_state
        addi 10,9,4
        li 7,4
        cmpld 0,30,10
        ble 0,.L104
        std 29,120(1)
        .cfi_offset 29, -24
        lbzx 5,31,10
        lbz 12,4(8)
        mtctr 5
        not 5,10
        mfctr 29
        add 5,5,30
        cmpw 0,29,12
        rldicl 12,5,0,63
        bne 0,.L105
        addi 10,9,5
        li 7,5
        cmpld 0,10,30
        bge 0,.L105
        cmpdi 0,12,0
        bne 0,.L110
.L98:
        srdi 5,5,1
        mtctr 5
        b .L85
        .p2align 4,,15
.L88:
        addi 7,7,1
        addi 10,10,1
        lbzx 5,8,7
        lbzx 12,31,10
        cmpw 0,12,5
        bne 0,.L105
        addi 7,7,1
        addi 10,10,1
        bdz .L105
.L85:
        lbzx 12,31,10
        lbzx 5,8,7
        cmpw 0,12,5
        beq 0,.L88
.L105:
        subfic 7,7,18
        ld 29,120(1)
        .cfi_restore 29
        subfe 8,8,8
        neg 8,8
.L86:
        subf 9,3,9
        addi 11,11,3
        mr 3,10
        subfic 10,9,14
        add 11,11,9
        mr 9,3
        subfe 10,10,10
        subf 11,10,11
        add 11,11,8
        b .L87
        .p2align 4,,15
.L110:
        .cfi_offset 29, -24
        lbzx 29,31,10
        lbzx 12,8,7
        cmpw 0,29,12
        bne 0,.L105
        addi 10,9,6
        li 7,6
        cmpld 0,10,30
        blt 0,.L98
        b .L105
.L104:
        .cfi_restore 29
        li 8,0
        b .L86
        .long 0
        .byte 0,0,0,1,128,3,0,0
        .cfi_endproc
        .size   fb_compress,.-.L.fb_compress
        .align 2
        .p2align 4,,15
        .globl fb_chacha20
        .section        ".opd","aw"
        .align 3
fb_chacha20:
        .quad   .L.fb_chacha20,.TOC.@tocbase,0
        .previous
        .type   fb_chacha20, @function
.L.fb_chacha20:
        .cfi_startproc
        mr 7,3
        rldicr 3,4,0,57
        rldicr. 4,4,0,57
        beqlr 0
        cmpdi 0,6,0
        beq 0,.L119
        mflr 0
        std 18,-112(1)
        std 20,-96(1)
        std 22,-80(1)
        std 23,-72(1)
        vxor 7,7,7
        std 28,-32(1)
        std 29,-24(1)
        std 0,16(1)
        std 31,-8(1)
        std 14,-144(1)
        std 15,-136(1)
        std 16,-128(1)
        std 17,-120(1)
        std 19,-104(1)
        std 21,-88(1)
        std 24,-64(1)
        std 25,-56(1)
        std 26,-48(1)
        std 27,-40(1)
        std 30,-16(1)
        stdu 1,-688(1)
        .cfi_def_cfa_offset 688
        .cfi_offset 65, 16
        .cfi_offset 18, -112
        .cfi_offset 20, -96
        .cfi_offset 22, -80
        .cfi_offset 23, -72
        .cfi_offset 28, -32
        .cfi_offset 29, -24
        .cfi_offset 31, -8
        .cfi_offset 14, -144
        .cfi_offset 15, -136
        .cfi_offset 16, -128
        .cfi_offset 17, -120
        .cfi_offset 19, -104
        .cfi_offset 21, -88
        .cfi_offset 24, -64
        .cfi_offset 25, -56
        .cfi_offset 26, -48
        .cfi_offset 27, -40
        .cfi_offset 30, -16
        li 0,400
        addis 9,2,.LANCHOR0@toc@ha
        addi 8,5,31
        addi 3,3,-1
        addi 10,5,15
        addi 9,9,.LANCHOR0@toc@l
        neg 31,5
        li 4,144
        li 11,0
        ld 28,0(9)
        ld 29,8(9)
        addis 9,2,.LC32@toc@ha
        li 18,0
        li 22,160
        li 23,48
        addi 9,9,.LC32@toc@l
        li 20,80
        vspltish 8,8
        stvx 23,1,0
        li 0,416
        stvx 24,1,0
        li 0,432
        stvx 25,1,0
        li 0,448
        stvx 26,1,0
        li 0,464
        stvx 27,1,0
        li 0,480
        stvx 28,1,0
        li 0,496
        stvx 29,1,0
        li 0,512
        stvx 30,1,0
        li 0,528
        stvx 31,1,0
        .cfi_offset 100, -288
        .cfi_offset 101, -272
        .cfi_offset 102, -256
        .cfi_offset 103, -240
        .cfi_offset 104, -224
        .cfi_offset 105, -208
        .cfi_offset 106, -192
        .cfi_offset 107, -176
        .cfi_offset 108, -160
        li 0,0
        lvx 5,0,5
        lvx 13,0,8
        addi 8,7,64
        lvx 0,0,9
        rldicr 9,3,0,57
        lvx 6,0,10
        rldicl 3,3,58,32
        std 29,120(1)
        std 28,112(1)
        li 10,128
        add 9,8,9
        addi 5,3,1
        li 3,96
        li 8,0
        std 9,320(1)
        li 9,0
        mtlr 3
        addis 3,2,.LC33@toc@ha
        addi 3,3,.LC33@toc@l
        lvsr 1,0,31
        std 3,328(1)
        addis 3,2,.LC34@toc@ha
        stw 0,164(1)
        std 11,168(1)
        std 7,736(1)
        std 6,760(1)
        stw 5,396(1)
        addi 3,3,.LC34@toc@l
        vperm 5,5,6,1
        vperm 6,6,13,1
        std 3,336(1)
        addis 3,2,.LC35@toc@ha
        vperm 5,5,5,0
        vperm 6,6,6,0
        addi 3,3,.LC35@toc@l
        vor 3,5,5
        std 3,344(1)
        addis 3,2,.LC36@toc@ha
        stvx 5,1,10
        vor 4,6,6
        stvx 6,1,4
        addi 3,3,.LC36@toc@l
        std 3,352(1)
        addis 3,2,.LC37@toc@ha
        addi 3,3,.LC37@toc@l
        std 3,360(1)
.L113:
        std 9,384(1)
        stw 8,392(1)
        mr 14,8
        ld 12,736(1)
        .p2align 4,,15
.L117:
        li 9,112
        mr 25,14
        addi 14,14,1
        lvx 13,1,9
        li 9,128
        mr 8,25
        lvx 1,1,9
        li 9,144
        lvx 0,1,9
        stw 25,160(1)
        li 9,10
        mtctr 9
        li 9,64
        stvx 13,1,23
        stvx 1,1,9
        mflr 9
        stvx 0,1,20
        lvx 0,1,22
        lwz 30,48(1)
        lwz 31,52(1)
        lwz 0,56(1)
        lwz 11,60(1)
        lwz 5,64(1)
        lwz 6,68(1)
        lwz 7,72(1)
        stvx 0,1,9
        lwz 29,80(1)
        lwz 9,76(1)
        lwz 26,84(1)
        lwz 27,88(1)
        lwz 28,92(1)
        lwz 10,100(1)
        lwz 3,104(1)
        lwz 4,108(1)
        .p2align 4,,15
.L114:
        add 30,30,5
        add 31,31,6
        add 0,7,0
        add 11,9,11
        xor 8,30,8
        xor 10,31,10
        xor 3,0,3
        xor 4,11,4
        rotlwi 8,8,16
        rotlwi 10,10,16
        rotlwi 3,3,16
        rotlwi 4,4,16
        add 29,8,29
        add 26,10,26
        add 27,27,3
        add 28,28,4
        xor 5,29,5
        xor 6,26,6
        xor 7,27,7
        xor 9,28,9
        rotlwi 5,5,12
        rotlwi 6,6,12
        rotlwi 7,7,12
        rotlwi 9,9,12
        add 30,30,5
        add 31,31,6
        add 0,0,7
        add 11,11,9
        xor 8,30,8
        xor 10,31,10
        xor 3,0,3
        xor 4,11,4
        rotlwi 8,8,8
        rotlwi 10,10,8
        rotlwi 3,3,8
        rotlwi 4,4,8
        add 29,29,8
        add 26,26,10
        add 27,27,3
        add 28,28,4
        xor 5,29,5
        xor 6,26,6
        xor 7,27,7
        xor 9,28,9
        rotlwi 5,5,7
        rotlwi 6,6,7
        rotlwi 7,7,7
        rotlwi 9,9,7
        add 30,30,6
        add 11,11,5
        add 31,31,7
        add 0,0,9
        xor 3,11,3
        xor 4,30,4
        xor 8,31,8
        xor 10,0,10
        rotlwi 3,3,16
        rotlwi 4,4,16
        rotlwi 8,8,16
        rotlwi 10,10,16
        add 26,26,3
        add 27,27,4
        add 28,28,8
        add 29,29,10
        xor 5,26,5
        xor 6,27,6
        xor 7,28,7
        xor 9,29,9
        rotlwi 5,5,12
        rotlwi 6,6,12
        rotlwi 7,7,12
        rotlwi 9,9,12
        add 11,11,5
        add 30,30,6
        add 31,31,7
        add 0,0,9
        xor 3,11,3
        xor 4,30,4
        xor 8,31,8
        xor 10,0,10
        rotlwi 3,3,8
        rotlwi 4,4,8
        rotlwi 8,8,8
        rotlwi 10,10,8
        add 26,26,3
        add 27,27,4
        add 28,28,8
        add 29,29,10
        xor 5,26,5
        xor 6,27,6
        xor 7,28,7
        xor 9,29,9
        rotlwi 5,5,7
        rotlwi 6,6,7
        rotlwi 7,7,7
        rotlwi 9,9,7
        bdnz .L114
        andi. 24,12,0xf
        stw 30,48(1)
        stw 4,108(1)
        stw 27,88(1)
        stw 6,68(1)
        stw 31,52(1)
        stw 8,96(1)
        stw 28,92(1)
        stw 7,72(1)
        stw 0,56(1)
        stw 10,100(1)
        stw 29,80(1)
        stw 9,76(1)
        stw 11,60(1)
        stw 3,104(1)
        stw 26,84(1)
        stw 5,64(1)
        bne 0,.L115
        ld 9,328(1)
        lvx 1,1,23
        li 8,64
        lvx 12,1,22
        lvx 11,1,20
        neg 10,12
        lvx 15,0,12
        lvx 0,1,8
        ld 8,344(1)
        lvx 2,0,9
        vmrghw 13,1,1
        lvsr 29,0,10
        addi 10,12,31
        mflr 9
        vmrglw 25,1,1
        lvx 18,0,10
        ld 10,336(1)
        lvx 19,0,8
        ld 8,360(1)
        vadduwm 11,4,11
        lvx 9,1,9
        addi 9,12,15
        vadduwm 0,3,0
        vadduwm 1,1,2
        lvx 28,0,9
        addi 9,12,47
        lvx 30,0,10
        lvx 10,0,8
        ld 8,352(1)
        lvx 2,0,9
        vmrghw 31,0,0
        addi 9,12,63
        vadduwm 13,13,19
        vadduwm 12,12,9
        vpkuwum 9,1,0
        lvx 24,0,9
        li 9,176
        lvx 16,0,8
        vperm 15,15,28,29
        vxor 17,12,1
        vmrghw 1,11,11
        vadduwm 25,25,10
        vpkuwum 27,11,12
        vxor 17,17,0
        vmrglw 0,0,0
        vmrghw 14,12,12
        vsrh 19,9,8
        vxor 17,17,11
        vmrglw 12,12,12
        vsrw 10,0,16
        vmrglw 11,11,11
        vsrh 26,27,8
        vpkuhum 27,9,27
        vsldoi 23,17,7,8
        vsrw 31,31,16
        vsrw 13,13,16
        vsrw 25,25,16
        vpkuhum 9,19,26
        vxor 0,23,17
        vperm 17,2,24,29
        vperm 2,18,2,29
        vsrw 11,11,16
        vperm 18,28,18,29
        vsrw 12,12,16
        vsldoi 28,0,7,4
        vsrw 1,1,16
        vpkuhum 29,15,18
        vsrw 14,14,16
        vpkuhum 24,2,17
        vxor 28,28,0
        vperm 16,2,17,30
        vperm 0,15,18,30
        vpkuwum 31,31,10
        vperm 19,29,24,30
        stvx 28,1,9
        vperm 0,0,16,30
        vpkuwum 13,13,25
        vpkuwum 1,1,11
        vxor 10,9,19
        vpkuwum 14,14,12
        vxor 0,0,27
        vpkuwum 15,15,18
        vpkuhum 13,13,31
        vpkuwum 2,2,17
        vpkuhum 1,1,14
        vxor 13,13,15
        vmrghb 12,0,10
        vmrglb 0,0,10
        vxor 1,1,2
        vmrghh 11,12,13
        lwz 9,176(1)
        vmrglh 12,12,13
        vmrghh 13,0,1
        vmrglh 0,0,1
        stvx 11,0,12
        xor 18,18,9
        li 9,16
        stvx 12,12,9
        li 9,32
        stvx 13,12,9
        stvx 0,12,23
.L116:
        ld 9,320(1)
        addi 12,12,64
        cmpld 0,9,12
        bne 0,.L117
        lwz 10,396(1)
        lwz 8,392(1)
        ld 9,384(1)
        add 8,8,10
        ld 10,760(1)
        addi 9,9,1
        cmpld 0,10,9
        bne 0,.L113
        li 0,-288
        addi 1,1,688
        .cfi_def_cfa_offset 0
        rldicl 3,18,0,32
        lvx 23,1,0
        li 0,-272
        ld 14,-144(1)
        ld 15,-136(1)
        ld 16,-128(1)
        lvx 24,1,0
        li 0,-256
        ld 17,-120(1)
        ld 18,-112(1)
        ld 19,-104(1)
        lvx 25,1,0
        li 0,-240
        ld 20,-96(1)
        ld 21,-88(1)
        ld 22,-80(1)
        lvx 26,1,0
        li 0,-224
        ld 23,-72(1)
        ld 24,-64(1)
        ld 25,-56(1)
        lvx 27,1,0
        li 0,-208
        ld 26,-48(1)
        ld 27,-40(1)
        ld 28,-32(1)
        lvx 28,1,0
        li 0,-192
        ld 29,-24(1)
        ld 30,-16(1)
        ld 31,-8(1)
        lvx 29,1,0
        li 0,-176
        lvx 30,1,0
        li 0,-160
        lvx 31,1,0
        ld 0,16(1)
        mtlr 0
        .cfi_restore 65
        .cfi_restore 31
        .cfi_restore 30
        .cfi_restore 29
        .cfi_restore 28
        .cfi_restore 27
        .cfi_restore 26
        .cfi_restore 25
        .cfi_restore 24
        .cfi_restore 23
        .cfi_restore 22
        .cfi_restore 21
        .cfi_restore 20
        .cfi_restore 19
        .cfi_restore 18
        .cfi_restore 17
        .cfi_restore 16
        .cfi_restore 15
        .cfi_restore 14
        .cfi_restore 108
        .cfi_restore 107
        .cfi_restore 106
        .cfi_restore 105
        .cfi_restore 104
        .cfi_restore 103
        .cfi_restore 102
        .cfi_restore 101
        .cfi_restore 100
        blr
.L119:
        li 3,0
        blr
        .p2align 4,,15
.L115:
        .cfi_def_cfa_offset 688
        .cfi_offset 14, -144
        .cfi_offset 15, -136
        .cfi_offset 16, -128
        .cfi_offset 17, -120
        .cfi_offset 18, -112
        .cfi_offset 19, -104
        .cfi_offset 20, -96
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
        .cfi_offset 100, -288
        .cfi_offset 101, -272
        .cfi_offset 102, -256
        .cfi_offset 103, -240
        .cfi_offset 104, -224
        .cfi_offset 105, -208
        .cfi_offset 106, -192
        .cfi_offset 107, -176
        .cfi_offset 108, -160
        .cfi_offset 65, 16
        mr 24,0
        lbz 0,3(12)
        addis 30,30,0x6170
        lbz 15,1(12)
        lbz 16,2(12)
        add 8,8,25
        addis 31,31,0x3320
        addis 24,24,0x7962
        addi 30,30,30821
        lbz 17,6(12)
        lbz 19,7(12)
        mtctr 8
        addi 31,31,25710
        lbz 25,11(12)
        stb 0,371(1)
        addi 0,24,11570
        lbz 24,5(12)
        srwi 8,30,16
        addis 11,11,0x6b20
        xor 8,8,16
        lbz 16,13(12)
        addi 11,11,25972
        mr 21,24
        lbz 24,9(12)
        stb 8,2(12)
        stb 16,379(1)
        lbz 16,15(12)
        stb 24,375(1)
        srwi 24,30,8
        xor 24,24,15
        lbz 15,10(12)
        stb 24,1(12)
        lbz 24,14(12)
        lwz 8,368(1)
        stb 24,383(1)
        srwi 24,30,24
        xor 24,24,8
        lbz 8,0(12)
        stb 24,3(12)
        srwi 24,31,8
        xor 8,30,8
        xor 24,24,21
        xor 30,30,31
        stb 24,5(12)
        stb 8,0(12)
        srwi 24,31,16
        lbz 8,4(12)
        xor 24,24,17
        xor 30,30,18
        lbz 18,8(12)
        stb 24,6(12)
        srwi 24,31,24
        xor 30,30,0
        xor 8,31,8
        lbz 31,12(12)
        xor 24,24,19
        xor 18,0,18
        stb 8,4(12)
        lwz 8,372(1)
        xor 30,30,11
        stb 24,7(12)
        srwi 24,0,8
        stb 18,8(12)
        xor 31,11,31
        xor 30,30,4
        xor 24,24,8
        srwi 8,0,16
        srwi 0,0,24
        xor 30,30,10
        xor 8,8,15
        stb 24,9(12)
        stb 31,12(12)
        stb 8,10(12)
        lwz 8,376(1)
        xor 0,0,25
        srwi 25,11,8
        srwi 31,11,16
        srwi 11,11,24
        stb 0,11(12)
        li 0,224
        xor 30,30,3
        xor 25,25,8
        lwz 8,380(1)
        xor 11,11,16
        stb 25,13(12)
        stb 11,15(12)
        xor 31,31,8
        mfctr 8
        srwi 16,8,8
        srwi 15,8,16
        stb 31,14(12)
        li 8,192
        stvx 5,1,8
        li 8,208
        lwz 11,192(1)
        stvx 5,1,8
        mfctr 8
        srwi 8,8,24
        stw 8,368(1)
        add 11,11,5
        srwi 8,11,8
        lbz 21,21(12)
        stvx 5,1,0
        li 0,240
        lbz 24,22(12)
        stvx 5,1,0
        mfctr 0
        xor 17,30,0
        lbz 5,17(12)
        lbz 18,20(12)
        lbz 0,24(12)
        lbz 25,23(12)
        lbz 19,25(12)
        lbz 30,26(12)
        lbz 31,27(12)
        xor 8,8,5
        stb 8,17(12)
        lwz 5,212(1)
        lwz 8,232(1)
        add 5,5,6
        add 7,8,7
        lwz 8,252(1)
        srwi 6,5,8
        xor 18,5,18
        xor 0,7,0
        xor 6,6,21
        add 8,8,9
        lbz 21,18(12)
        stb 18,20(12)
        srwi 9,5,16
        stb 0,24(12)
        lbz 0,19(12)
        stb 6,21(12)
        lbz 6,16(12)
        srwi 18,10,8
        xor 24,9,24
        lbz 9,28(12)
        stb 24,22(12)
        srwi 24,5,24
        xor 6,11,6
        xor 24,24,25
        srwi 25,7,16
        stb 6,16(12)
        srwi 6,7,8
        xor 9,8,9
        xor 25,25,30
        stb 24,23(12)
        xor 6,6,19
        stb 9,28(12)
        srwi 30,7,24
        stb 25,26(12)
        stb 6,25(12)
        srwi 6,11,16
        xor 30,30,31
        srwi 31,11,24
        xor 6,6,21
        stb 30,27(12)
        li 30,256
        srwi 9,8,24
        xor 31,31,0
        stb 6,18(12)
        srwi 0,8,8
        stb 31,19(12)
        stvx 6,1,30
        li 30,272
        srwi 6,8,16
        stvx 6,1,30
        li 30,288
        stvx 6,1,30
        lbz 21,29(12)
        lbz 25,30(12)
        lbz 30,31(12)
        lbz 31,33(12)
        lbz 24,34(12)
        lbz 19,39(12)
        xor 0,0,21
        xor 6,6,25
        lbz 21,37(12)
        lbz 25,35(12)
        xor 9,9,30
        lbz 30,32(12)
        stb 0,29(12)
        stb 6,30(12)
        stb 9,31(12)
        lwz 0,256(1)
        lwz 6,276(1)
        lwz 9,296(1)
        add 0,0,29
        add 6,6,26
        lbz 26,38(12)
        add 9,9,27
        srwi 29,0,8
        xor 27,0,30
        xor 30,17,0
        xor 29,29,31
        lbz 31,36(12)
        stb 27,32(12)
        lbz 27,41(12)
        xor 30,30,6
        stb 29,33(12)
        srwi 29,0,16
        srwi 0,0,24
        xor 17,30,9
        xor 31,6,31
        xor 0,0,25
        lbz 25,40(12)
        xor 29,29,24
        li 30,304
        stb 31,36(12)
        srwi 31,6,8
        stb 0,35(12)
        srwi 0,6,16
        stb 29,34(12)
        xor 31,31,21
        srwi 6,6,24
        xor 25,9,25
        stb 31,37(12)
        srwi 31,9,8
        xor 0,0,26
        xor 6,6,19
        stb 25,40(12)
        xor 27,31,27
        stb 0,38(12)
        lbz 0,42(12)
        stb 6,39(12)
        srwi 31,9,16
        stb 27,41(12)
        stvx 6,1,30
        srwi 9,9,24
        srwi 30,10,24
        xor 31,31,0
        srwi 6,10,16
        mfctr 19
        stb 31,42(12)
        lbz 25,43(12)
        lbz 31,50(12)
        lbz 21,51(12)
        lbz 24,52(12)
        lbz 0,44(12)
        lbz 26,45(12)
        lbz 27,46(12)
        lbz 29,47(12)
        xor 9,9,25
        lbz 25,49(12)
        xor 31,15,31
        xor 10,10,24
        lbz 24,56(12)
        stb 9,43(12)
        xor 16,16,25
        lbz 25,48(12)
        xor 24,3,24
        stb 16,49(12)
        xor 25,19,25
        lbz 19,55(12)
        xor 19,30,19
        srwi 30,3,8
        lwz 9,316(1)
        stb 31,50(12)
        lwz 31,368(1)
        add 9,9,28
        lbz 28,54(12)
        xor 21,31,21
        lbz 31,53(12)
        xor 0,9,0
        stb 21,51(12)
        stb 25,48(12)
        stb 10,52(12)
        stb 0,44(12)
        lbz 25,58(12)
        lbz 21,63(12)
        xor 31,18,31
        srwi 10,9,8
        stb 24,56(12)
        lbz 24,57(12)
        srwi 0,9,16
        stb 19,55(12)
        stb 31,53(12)
        srwi 31,9,24
        xor 9,17,9
        xor 10,10,26
        xor 0,0,27
        lbz 26,59(12)
        lbz 27,60(12)
        xor 31,31,29
        xor 6,6,28
        lbz 29,62(12)
        lbz 28,61(12)
        xor 9,9,11
        stb 10,45(12)
        stb 0,46(12)
        stb 31,47(12)
        stb 6,54(12)
        srwi 31,3,16
        srwi 0,4,8
        srwi 6,4,16
        srwi 10,4,24
        srwi 3,3,24
        xor 9,9,5
        xor 30,30,24
        xor 31,31,25
        xor 3,3,26
        xor 4,4,27
        xor 0,0,28
        xor 6,6,29
        stb 30,57(12)
        stb 31,58(12)
        stb 3,59(12)
        stb 4,60(12)
        stb 0,61(12)
        stb 6,62(12)
        xor 10,10,21
        xor 9,9,7
        stb 10,63(12)
        xor 18,9,8
        b .L116
        .long 0
        .byte 0,0,0,1,128,18,0,0
        .cfi_endproc
        .size   fb_chacha20,.-.L.fb_chacha20
        .align 2
        .p2align 4,,15
        .globl fb_physics
        .section        ".opd","aw"
        .align 3
fb_physics:
        .quad   .L.fb_physics,.TOC.@tocbase,0
        .previous
        .type   fb_physics, @function
.L.fb_physics:
        .cfi_startproc
        cmpdi 0,4,0
        beq 0,.L140
        cmpdi 0,5,0
        std 31,-8(1)
        .cfi_offset 31, -8
        mr 0,3
        mr 31,5
        li 3,0
        beq 0,.L131
        addis 9,2,.LC22@toc@ha
        addis 3,2,.LC48@toc@ha
        addis 12,2,.LC46@toc@ha
        addis 11,2,.LC14@toc@ha
        lfs 0,.LC22@toc@l(9)
        li 5,0
        addi 3,3,.LC48@toc@l
        addi 12,12,.LC46@toc@l
        addi 11,11,.LC14@toc@l
        stfs 0,-32(1)
        .p2align 4,,15
.L133:
        mr 7,0
        li 6,0
        .p2align 4,,15
.L138:
        mtctr 4
        lfs 6,-32(1)
        mr 9,0
        mr 8,4
        fmr 7,6
        fmr 8,6
        .p2align 4,,15
.L135:
        subf 10,8,4
        addi 8,8,-1
        cmpld 0,6,10
        beq 0,.L134
        lfd 2,0(7)
        lfd 3,8(7)
        lfd 10,0(9)
        lfd 11,8(9)
        lfd 0,16(7)
        lfd 12,16(9)
        lfs 4,0(12)
        lfs 9,0(11)
        lfd 5,24(9)
        fsub 10,10,2
        fsub 11,11,3
        fsub 12,12,0
        fmul 2,11,11
        fmul 0,10,10
        fmul 3,12,12
        fadd 0,0,2
        fadd 0,0,3
        fadd 0,0,4
        fsqrt 0,0
        fdiv 9,9,0
        fmul 0,9,9
        fmul 0,0,9
        fmul 0,0,5
        fmul 10,10,0
        fmul 11,11,0
        fmul 12,12,0
        fadd 8,8,10
        fadd 7,7,11
        fadd 6,6,12
.L134:
        addi 9,9,64
        bdnz .L135
        lfs 12,0(3)
        lfd 9,32(7)
        addi 6,6,1
        addi 7,7,64
        lfd 10,-24(7)
        lfd 11,-16(7)
        cmpld 0,4,6
        fmr 0,12
        fmul 8,8,0
        fmul 7,7,0
        fmul 0,6,0
        fadd 9,9,8
        fadd 10,10,7
        fadd 0,11,0
        stfd 9,-32(7)
        stfd 10,-24(7)
        stfd 0,-16(7)
        bne 0,.L138
        mtctr 4
        fmr 0,12
        mr 9,0
        .p2align 4,,15
.L136:
        lfd 7,32(9)
        lfd 8,40(9)
        addi 9,9,64
        lfd 9,-16(9)
        lfd 10,-64(9)
        lfd 11,-56(9)
        lfd 12,-48(9)
        fmul 7,7,0
        fmul 8,8,0
        fmul 9,9,0
        fadd 10,10,7
        fadd 11,11,8
        fadd 12,12,9
        stfd 10,-64(9)
        stfd 11,-56(9)
        stfd 12,-48(9)
        bdnz .L136
        addi 5,5,1
        cmpld 0,31,5
        bne 0,.L133
        andi. 9,6,0x1
        addis 10,2,.LC22@toc@ha
        mr 9,0
        lfs 11,.LC22@toc@l(10)
        addi 10,6,-1
        addi 9,9,32
        beq 0,.L147
        lfd 0,0(9)
        lfd 10,8(9)
        cmpdi 0,10,0
        lfd 12,16(9)
        mr 9,0
        addi 9,9,96
        fadd 0,0,10
        fadd 0,0,12
        fadd 11,11,0
        beq 0,.L152
.L147:
        srdi 10,6,1
        mtctr 10
.L139:
        lfd 12,0(9)
        lfd 7,8(9)
        addi 9,9,128
        lfd 9,-112(9)
        lfd 0,-64(9)
        lfd 8,-56(9)
        lfd 10,-48(9)
        fadd 12,12,7
        fadd 0,0,8
        fadd 12,12,9
        fadd 0,0,10
        fadd 11,11,12
        fadd 11,11,0
        bdnz .L139
.L152:
        stfd 11,-32(1)
        nop
        nop
        nop
        ld 3,-32(1)
.L131:
        ld 31,-8(1)
        .cfi_restore 31
        blr
.L140:
        li 3,0
        blr
        .long 0
        .byte 0,0,0,0,0,1,0,0
        .cfi_endproc
        .size   fb_physics,.-.L.fb_physics
        .align 2
        .p2align 4,,15
        .globl fb_sort
        .section        ".opd","aw"
        .align 3
fb_sort:
        .quad   .L.fb_sort,.TOC.@tocbase,0
        .previous
        .type   fb_sort, @function
.L.fb_sort:
        .cfi_startproc
        cmpldi 0,4,1
        mr 10,3
        ble 0,.L191
        std 31,-8(1)
        .cfi_offset 31, -8
        rldicr 31,4,0,62
        srdi 12,4,1
        addi 31,31,-1
        .p2align 4,,15
.L166:
        cmpld 0,4,31
        addi 12,12,-1
        ble 0,.L163
        sldi 9,12,2
        mr 7,31
        mr 5,12
        lwzx 11,10,9
        b .L165
        .p2align 4,,15
.L192:
        lwzx 3,10,3
        cmplw 0,3,6
        ble 0,.L174
        mr 6,3
        sldi 7,9,1
        sldi 3,5,2
        mr 8,0
        cmplw 0,11,6
        addi 7,7,1
        mr 5,9
        cmpld 7,4,7
        bge 0,.L163
.L193:
        stwx 6,10,3
        stw 11,0(8)
        ble 7,.L163
.L165:
        addi 9,5,1
        sldi 8,7,2
        sldi 3,9,3
        sldi 9,9,1
        lwzx 6,10,8
        add 8,10,8
        cmpld 0,4,9
        add 0,10,3
        bgt 0,.L192
.L174:
        mr 9,7
        cmplw 0,11,6
        sldi 3,5,2
        sldi 7,9,1
        mr 5,9
        addi 7,7,1
        cmpld 7,4,7
        blt 0,.L193
.L163:
        cmpdi 0,12,0
        addi 31,31,-2
        bne 0,.L166
        addi 9,4,-1
        sldi 4,4,2
        mtctr 9
        mr 11,9
        add 4,4,10
        lwz 9,0(10)
        cmpldi 0,11,1
        lwzu 8,-4(4)
        stw 8,0(10)
        stw 9,0(4)
        beq 0,.L167
        .p2align 4,,15
.L196:
        lwz 0,0(10)
        li 5,0
        li 7,1
        b .L170
        .p2align 4,,15
.L194:
        lwzx 3,10,3
        cmplw 0,3,6
        ble 0,.L177
        mr 6,3
        sldi 7,9,1
        sldi 3,5,2
        mr 8,31
        cmplw 0,0,6
        addi 7,7,1
        mr 5,9
        cmpld 7,7,11
        bge 0,.L169
.L195:
        stwx 6,10,3
        stw 0,0(8)
        bge 7,.L169
.L170:
        addi 9,5,1
        sldi 8,7,2
        sldi 3,9,3
        sldi 9,9,1
        lwzx 6,10,8
        add 8,10,8
        cmpld 0,9,11
        add 31,10,3
        blt 0,.L194
.L177:
        mr 9,7
        cmplw 0,0,6
        sldi 3,5,2
        sldi 7,9,1
        mr 5,9
        addi 7,7,1
        cmpld 7,7,11
        blt 0,.L195
.L169:
        addi 11,11,-1
        lwz 9,0(10)
        lwzu 8,-4(4)
        cmpldi 0,11,1
        stw 8,0(10)
        stw 9,0(4)
        bne 0,.L196
.L167:
        mfctr 9
        addi 8,10,-4
        andi. 9,9,0x1
        mfctr 9
        bne 0,.L197
.L182:
        srdi 9,9,1
        addi 9,9,1
        mtctr 9
        b .L171
        .p2align 4,,15
.L198:
        lwz 12,4(9)
        rotldi 3,3,57
        xor 3,12,3
        add 12,12,3
.L171:
        lwz 3,4(8)
        rotldi 12,12,57
        addi 9,8,4
        addi 8,8,8
        xor 12,3,12
        add 3,3,12
        bdnz .L198
        ld 31,-8(1)
        .cfi_remember_state
        .cfi_restore 31
        blr
.L197:
        .cfi_restore_state
        lwz 12,0(10)
        mr 8,10
        sldi 12,12,1
        b .L182
.L191:
        .cfi_restore 31
        cmpdi 0,4,0
        li 3,0
        beqlr 0
        lwz 3,0(10)
        blr
        .long 0
        .byte 0,0,0,0,0,1,0,0
        .cfi_endproc
        .size   fb_sort,.-.L.fb_sort
        .align 2
        .p2align 4,,15
        .globl fb_chase
        .section        ".opd","aw"
        .align 3
fb_chase:
        .quad   .L.fb_chase,.TOC.@tocbase,0
        .previous
        .type   fb_chase, @function
.L.fb_chase:
        .cfi_startproc
        cmpdi 0,4,0
        beq 0,.L202
        andi. 8,4,0x3
        mr 9,3
        addi 7,4,-1
        mr 10,4
        beq 0,.L209
        cmpdi 0,8,1
        beq 0,.L213
        cmpdi 0,8,2
        bne 0,.L221
.L214:
        ld 9,0(9)
        addi 4,4,-1
.L213:
        cmpdi 0,4,1
        ld 9,0(9)
        beq 0,.L219
.L209:
        srdi 10,10,2
        mtctr 10
.L201:
        ld 9,0(9)
        ld 9,0(9)
        ld 9,0(9)
        ld 9,0(9)
        bdnz .L201
.L219:
        subf 3,3,9
        blr
        .p2align 4,,15
.L202:
        li 3,0
        blr
        .p2align 4,,15
.L221:
        ld 9,0(3)
        mr 4,7
        b .L214
        .long 0
        .byte 0,0,0,0,0,0,0,0
        .cfi_endproc
        .size   fb_chase,.-.L.fb_chase
        .section        .rodata.cst4,"aM",@progbits,4
        .align 2
.LC6:
        .long   1056964608
        .align 2
.LC8:
        .long   1080033280
        .align 2
.LC10:
        .long   1075838976
        .align 2
.LC12:
        .long   1069547520
        .align 2
.LC14:
        .long   1065353216
        .align 2
.LC16:
        .long   1065877504
        .align 2
.LC18:
        .long   981467136
        .align 2
.LC20:
        .long   1073741824
        .align 2
.LC22:
        .long   0
        .section        .rodata.cst16,"aM",@progbits,16
        .align 4
.LC32:
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
.LC33:
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
.LC35:
        .long   1634760805
        .long   1634760805
        .long   857760878
        .long   857760878
        .align 4
.LC36:
        .long   16
        .long   24
        .long   16
        .long   24
        .align 4
.LC37:
        .long   2036477234
        .long   2036477234
        .long   1797285236
        .long   1797285236
        .section        .rodata.cst4
        .align 2
.LC46:
        .long   1031798784
        .align 2
.LC48:
        .long   1006632960
        .section        .rodata
        .align 4
        .set    .LANCHOR0,. + 0
        .type   sigma.0, @object
        .size   sigma.0, 16
sigma.0:
        .long   1634760805
        .long   857760878
        .long   2036477234
        .long   1797285236
        .ident  "GCC: (crosstool-NG UNKNOWN) 16.1.0"
        .gnu_attribute 4, 1
