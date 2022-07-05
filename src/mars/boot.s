!--------------------------------------------------------------------
! 32X startup code and interrupt vectors
!
! Addresses that need to be known on the MD side (See 32X Header in MD boot.s):
! - 0x06000000: Master entry point
! - 0x06000004: Slave entry point
! - 0x05fffefc: Master VBR          (_master_int_vectors - irl_6_vector_offset)
! - 0x05ffff0c: Slave VBR           (_slave_int_vectors - irl_6_vector_offset)
!--------------------------------------------------------------------

    .section boot


    !-------------------------------------------------------------------
    ! Entry points
    !-------------------------------------------------------------------
    bra     __master
    nop
    bra     __slave
    nop


    !-------------------------------------------------------------------
    ! Master interrupt vector table.
    ! We only map the (usefull) interrupt vectors to preserve RAM
    !-------------------------------------------------------------------
    _master_int_vectors:
        .dc.l   _unhandled_exception    ! PWM           (IRL6)
        .dc.l   _unhandled_exception    ! Command       (IRL8)
        .dc.l   _unhandled_exception    ! H interrupt   (IRL10)
        .dc.l   _unhandled_exception    ! V interrupt   (IRL12)


    !-------------------------------------------------------------------
    ! Slave interrupt vector table.
    ! We only map the (usefull) interrupt vectors to preserve RAM
    !-------------------------------------------------------------------
    _slave_int_vectors:
        .dc.l   _unhandled_exception    ! PWM           (IRL6)
        .dc.l   _unhandled_exception    ! Command       (IRL8)
        .dc.l   _unhandled_exception    ! H interrupt   (IRL10)
        .dc.l   _unhandled_exception    ! V interrupt   (IRL12)


    !-------------------------------------------------------------------
    ! Unhandled exception handler
    !-------------------------------------------------------------------
    _unhandled_exception:
        rte
        nop


    !-------------------------------------------------------------------
    ! Master startup code
    !-------------------------------------------------------------------
    __master:
        mov.l   _master_main, r0
        jmp     @r0                     ! Start master program
        mov.l   _master_stack, sp

        .balign 4
        _master_stack:
            .dc.l   __mstack
        _master_main:
            .dc.l   _master


    !-------------------------------------------------------------------
    ! Slave startup code
    !-------------------------------------------------------------------
    __slave:
        mov.l   _slave_main, r0
        jmp     @r0                     ! Start slave program
        mov.l   _slave_stack, sp

        .balign 4
        _slave_stack:
            .dc.l   __sstack
        _slave_main:
            .dc.l   _slave
