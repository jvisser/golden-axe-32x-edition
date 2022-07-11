|--------------------------------------------------------------------
| 32X sub program communication
|--------------------------------------------------------------------

    .include "md.i"
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
    | Send command to the 32X sub program.
    | Command specific parameters must be set in the communication registers before calling.
    |
    | Params:
    | - d0.w: non zero command id
    | - d1.w: comm port base offset relative to MARS_REG_BASE
    |-------------------------------------------------------------------
    mars_comm:
        tst.w   %d0
        beq     .exit

        | Halt Z80 if not halted already
        btst    #0, (Z80_BUS_REQUEST)
        beq     2f
        move.w  #0x0100, (Z80_BUS_REQUEST)
    1:  btst    #0, (Z80_BUS_REQUEST)
        bne     1b
        pea     .z80_resume

    2:  move.l  %a6, -(%sp)
        lea     (MARS_REG_BASE), %a6

        | Give the 32X access to ROM (RV = 0)
        bclr    #0, MARS_DMAC + 1(%a6)

        | Clear response register
        clr.w   2(%a6, %d1.w)

        | Send command
        move.w  %d0, (%a6, %d1.w)

        | Wait for command ready
    1:  cmp.w   2(%a6, %d1.w), %d0
        bne     1b

        | Send ACK
        clr.w   (%a6, %d1.w)

        | Give MD access to ROM (RV = 1)
        bset    #0, MARS_DMAC + 1(%a6)

        move.l  (%sp)+, %a6
    .exit:
        rts
    .z80_resume:
        move.w  #0, (Z80_BUS_REQUEST)
        rts
