!--------------------------------------------------------------------
! 32X Startup code and exception vectors
!--------------------------------------------------------------------

    !-------------------------------------------------------------------
    ! Entry points
    bra     _master_start
    bra     _slave_start


    !-------------------------------------------------------------------
    ! Master vector table
    .dc.l   _master_start
    .dc.l   0x0603ff00
    .dc.l   _master_start
    .dc.l   0x0603ff00
    .rept   60
    .dc.l   _unhandled_exception
    .endr


    !-------------------------------------------------------------------
    ! Slave vector table
    .dc.l   _slave_start
    .dc.l   0x06040000
    .dc.l   _slave_start
    .dc.l   0x06040000
    .rept   60
    .dc.l   _unhandled_exception
    .endr


    !-------------------------------------------------------------------
    ! Unhandled exception
    _unhandled_exception:
        rte
        nop


    !-------------------------------------------------------------------
    ! Master startup code
    _master_start:
        bra     master
        nop


    !-------------------------------------------------------------------
    ! Slave startup code
    _slave_start:
        bra     slave
        nop