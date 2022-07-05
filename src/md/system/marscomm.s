|--------------------------------------------------------------------
| 32X sub program communication
|--------------------------------------------------------------------

    .include "mars.i"


    .global mars_comm_init
    .global mars_comm


    |-------------------------------------------------------------------
    | Sub program initial handshake
    |-------------------------------------------------------------------
    mars_comm_init:
        lea     (MARS_REG_BASE), %a6

        | Set HW access to the 32X side
        bset    #7, MARS_ADP_CTL(%a6)       | VDP

        | Start handshake
        | TODO...

        rts


    .data       | Use the .data section to store this routine in RAM allowing RV switching
    .align  2

    |-------------------------------------------------------------------
    | Send command to the 32X sub program
    |
    | Params:
    | - d0.w: command (high bit indicated blocking call)
    |-------------------------------------------------------------------
    mars_comm:
        rts
