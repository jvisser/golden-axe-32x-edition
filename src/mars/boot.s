!--------------------------------------------------------------------
! 32X startup code and interrupt vectors
!
! Addresses that need to be known on the MD side (See 32X Header in MD boot.s):
! - 0x06000000: Master entry point
! - 0x06000004: Slave entry point
! - 0x05ffff00: Master VBR          (_master_int_vectors - irl_6_vector_offset)
! - 0x05ffff14: Slave VBR           (_slave_int_vectors - irl_6_vector_offset)
!
! General HW notes:
!
! The following registers implicitly have CPU local values
! - Interrupt clear registers for all sources
! - Interrupt mask register bits 0-3
!
!   See the 32X Hardware Manual:
!   - Page 28: Interrupt Control for SH2
!   - Page 62: Master and Slave
!
! For specifics/quirks on handling interrupts
!   See the 32X Hardware Manual:
!   - Page 71: Interrupt
!   - Page 87: Concerning SH2 Interrupt
!--------------------------------------------------------------------

    .section boot


    !-------------------------------------------------------------------
    ! Entry points
    !-------------------------------------------------------------------
    bra     __master
    nop
    bra     __slave
    nop
    bra     __default_interrupt_handler
    nop


    !-------------------------------------------------------------------
    ! Master interrupt vector table.
    ! We only map the (usefull) interrupt vectors to preserve RAM
    !-------------------------------------------------------------------
    _master_int_vectors:
        .dc.l   __dispatch_master_interrupt     ! PWM               (IRL6)
        .dc.l   __dispatch_master_interrupt     ! Command           (IRL8)
        .dc.l   __dispatch_master_interrupt     ! H interrupt       (IRL10)
        .dc.l   __dispatch_master_interrupt     ! V interrupt       (IRL12)
        .dc.l   __dispatch_master_interrupt     ! VRES interrupt    (IRL14)


    !-------------------------------------------------------------------
    ! Slave interrupt vector table.
    ! We only map the (usefull) interrupt vectors to preserve RAM
    !-------------------------------------------------------------------
    _slave_int_vectors:
        .dc.l   __dispatch_slave_interrupt      ! PWM               (IRL6)
        .dc.l   __dispatch_slave_interrupt      ! Command           (IRL8)
        .dc.l   __dispatch_slave_interrupt      ! H interrupt       (IRL10)
        .dc.l   __dispatch_slave_interrupt      ! V interrupt       (IRL12)
        .dc.l   __dispatch_slave_interrupt      ! VRES interrupt    (IRL14)


    !-------------------------------------------------------------------
    ! Master startup code
    ! NB: Kega fusion has issues with a delay slot instruction here other than nop for some reason
    !-------------------------------------------------------------------
    __master:
        bsr     __setup_interrupts
        nop
        mov.l   __master_main, r14
        mov.l   __master_stack, sp
        jmp     @r14                    ! Start master program
        nop


    !-------------------------------------------------------------------
    ! Slave startup code
    ! NB: Kega fusion has issues with a delay slot instruction here other than nop for some reason
    !-------------------------------------------------------------------
    __slave:
        bsr     __setup_interrupts
        nop
        mov.l   __slave_main, r14
        mov.l   __slave_stack, sp
        jmp     @r14                    ! Start slave program
        nop


    !-------------------------------------------------------------------
    ! Setup interrupt masks
    !-------------------------------------------------------------------
    __setup_interrupts:
        ! Interrupt clear registers
        mov.l   __mars_reg_base, r0
        mov.w   r0, @(0x14, r0)
        mov.w   r0, @(0x16, r0)
        mov.w   r0, @(0x18, r0)
        mov.w   r0, @(0x1a, r0)
        mov.w   r0, @(0x1c, r0)

        ! Set interrupt mask to accept level 6 interrupts
        mov.l   __initial_sr_int6, r1
        rts
        ldc     r1, sr


    !-------------------------------------------------------------------
    ! Interrupt handler routine for undefined interrupt handlers
    ! See mars.ld
    !-------------------------------------------------------------------
    __default_interrupt_handler:
        rts
        nop


    !-------------------------------------------------------------------
    ! Slave interrupt handler routine
    !-------------------------------------------------------------------
    __dispatch_slave_interrupt:
        mov.l   r0, @-sp
        mov.l   r1, @-sp
        mova    __slave_interrupt_handlers, r0
        bra     __dispatch_interrupt
        mov     r0, r1


    !-------------------------------------------------------------------
    ! Master interrupt handler routine
    !-------------------------------------------------------------------
    __dispatch_master_interrupt:
        mov.l   r0, @-sp
        mov.l   r1, @-sp
        mova    __master_interrupt_handlers, r0
        mov     r0, r1


    !-------------------------------------------------------------------
    ! Generic interrupt handler routine
    !-------------------------------------------------------------------
    __dispatch_interrupt:

        ! Dispatch to the interrupt handling routine based on interrupt level
        stc     sr, r0
        shlr2   r0
        shlr2   r0
        shlr    r0
        bt      1f                      ! Odd level, bail

        and     #0x07, r0
        add     #-3, r0                 ! r0 = IRL6 relative interrupt level
        ! Save registers, gcc calling convention dictates r8-r14 are preserved between calls
        mov.l   r0, @-sp
        mov.l   r2, @-sp
        mov.l   r3, @-sp
        mov.l   r4, @-sp
        mov.l   r5, @-sp
        mov.l   r6, @-sp
        mov.l   r7, @-sp
        sts.l   macl, @-sp
        sts.l   mach, @-sp
        sts.l   pr, @-sp
        shll2   r0
        mov.l   @(r0, r1), r1
        jsr     @r1                     ! call handler routine
        nop
        lds.l   @sp+, pr
        lds.l   @sp+, mach
        lds.l   @sp+, macl
        mov.l   @sp+, r7
        mov.l   @sp+, r6
        mov.l   @sp+, r5
        mov.l   @sp+, r4
        mov.l   @sp+, r3
        mov.l   @sp+, r2
        mov.l   @sp+, r1

        ! Set interrupt clear register
        shll    r1
        neg     r1, r0
        add     #0x1c, r0
        mov.l   __mars_reg_base, r1
        mov.w   r0, @(r0, r1)

    1:  mov.l   @sp+, r1            ! Need at least 2 cycles/ops after int clear before RTE
        mov.l   @sp+, r0
        rte
        nop

    __vres:
        mov     #0, r0

        mov.l   __mars_reg_base, r1
        ldc     r1, gbr             ! Set GBR
        mov.w   r0, @(0x000, gbr)   ! Disable interrupts and give VDP access to the MD
        mov.w   r0, @(0x100, gbr)   ! Disable 32X display

        ! Jump to the reset vector in the boot ROM of the executing SH2 (hopefully this is good enough)
        mov.l   __initial_sr, r1
        ldc     r1, sr
        mov.l   @r0+, r1
        mov.l   @r0+, sp
        jmp     @r1
        nop

    .balign 4

    __master_stack: .dc.l   __mstack
    __master_main:  .dc.l   _master

    __master_interrupt_handlers:
        .dc.l   _master_int_pwm
        .dc.l   _master_int_command
        .dc.l   _master_int_hblank
        .dc.l   _master_int_vblank
        .dc.l   __vres

    __slave_stack:  .dc.l   __sstack
    __slave_main:   .dc.l   _slave

    __slave_interrupt_handlers:
        .dc.l   _slave_int_pwm
        .dc.l   _slave_int_command
        .dc.l   _slave_int_hblank
        .dc.l   _slave_int_vblank
        .dc.l   __vres

    __mars_reg_base:    .dc.l 0x20004000
    __initial_sr:       .dc.l 0x000000f0
    __initial_sr_int6:  .dc.l 0x00000050
