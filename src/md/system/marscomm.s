|--------------------------------------------------------------------
| 32X sub program communication
|--------------------------------------------------------------------

    .include "mars.i"


    .global mars_comm_init
    .global mars_comm


    |-------------------------------------------------------------------
    | Sub program initial handshake.
    | Should be called directly after ok signals from the 32X boot ROM's
    |-------------------------------------------------------------------
    mars_comm_init:
        lea     (MARS_REG_BASE), %a6

        | Set HW/VDP access to the 32X side
        bset    #7, MARS_ADP_CTL(%a6)

        | Wait for the 32X to accept HW control
    1:  tst.l   MARS_COMM0(%a6)
        bne     1b
    1:  tst.l   MARS_COMM2(%a6)
        bne     1b
        rts


    .data       | Use the .data section to store this routine in RAM allowing RV switching
    .align  2

    |-------------------------------------------------------------------
    | Send command to the 32X sub program
    |
    | Params:
    | - d0.w: command
    |-------------------------------------------------------------------
    mars_comm:
        | RV = 0

        | Send command
        | Wait for command ready response

        | RV = 1
        rts
