|--------------------------------------------------------------------
| 32X sub program communication
|--------------------------------------------------------------------

    .include "md.i"
    .include "mars.i"
    .include "marscomm.i"


    .global __mars_comm_init
    .global __mars_comm

    .global mars_comm_display_disable
    .global mars_comm_display_enable
    .global mars_comm_palette_fade_in
    .global mars_comm_palette_fade_out
    .global mars_comm_image
    .global mars_comm_image_fade_in


    |--------------------------------------------------------------------
    | Disable 32X display
    |--------------------------------------------------------------------
    mars_comm_display_disable:
        mars_comm_call_start
        mars_comm_p1 MARSCOMM_SLAVE, MARSCOMM_CMD_DISPLAY, #MARSCOMM_CMD_DISPLAY_DISABLE
        mars_comm_call_end
        rts


    |--------------------------------------------------------------------
    | Enable 32X display
    |--------------------------------------------------------------------
    mars_comm_display_enable:
        mars_comm_call_start
        mars_comm_p1 MARSCOMM_SLAVE, MARSCOMM_CMD_DISPLAY, #MARSCOMM_CMD_DISPLAY_ENABLE
        mars_comm_call_end
        rts


    |--------------------------------------------------------------------
    | Palette fade in
    |--------------------------------------------------------------------
    mars_comm_palette_fade_in:
        mars_comm_call_start
        mars_comm_lp MARSCOMM_MASTER, MARSCOMM_CMD_PALETTE, #MARSCOMM_CMD_PALETTE_FILL
        mars_comm_lp MARSCOMM_MASTER, MARSCOMM_CMD_PALETTE, #MARSCOMM_CMD_PALETTE_TRANSITION
        mars_comm_call_end
        rts


    |--------------------------------------------------------------------
    | Palette fade out
    |--------------------------------------------------------------------
    mars_comm_palette_fade_out:
        mars_comm_call_start
        mars_comm_lp MARSCOMM_MASTER, MARSCOMM_CMD_PALETTE, #0x01000000  | How the hell do you pass #MARSCOMM_CMD_PALETTE_FILL|MARSCOMM_PALETTE_1 as an argument?
        mars_comm_lp MARSCOMM_MASTER, MARSCOMM_CMD_PALETTE, #MARSCOMM_CMD_PALETTE_TRANSITION
        mars_comm_call_end
        rts


    |--------------------------------------------------------------------
    | Load and show an image on the 32X
    |
    | Parameters:
    |- a0: image address
    |--------------------------------------------------------------------
    mars_comm_image:
        mars_comm_call_start

        mars_comm_p1 MARSCOMM_MASTER, MARSCOMM_CMD_DISPLAY, #MARSCOMM_CMD_DISPLAY_DISABLE
        mars_comm_lp MARSCOMM_MASTER, MARSCOMM_CMD_IMAGE, %a0
        mars_comm_lp MARSCOMM_MASTER, MARSCOMM_CMD_PALETTE, #MARSCOMM_CMD_PALETTE_COMMIT
        mars_comm_p1 MARSCOMM_MASTER, MARSCOMM_CMD_DISPLAY, #MARSCOMM_CMD_DISPLAY_SWAP
        mars_comm_p1 MARSCOMM_MASTER, MARSCOMM_CMD_DISPLAY, #MARSCOMM_CMD_DISPLAY_ENABLE

        mars_comm_call_end
        rts


    |--------------------------------------------------------------------
    | Load an image on the 32X and fade in
    |
    | Parameters:
    |- a0: image address
    |--------------------------------------------------------------------
    mars_comm_image_fade_in:
        mars_comm_call_start

        move.l  %d0, -(%sp)

        | Store image palette in the target palette on the 32X
        move.l  %a0, %d0
        ori.l   #MARSCOMM_PALETTE_1, %d0

        mars_comm_p1 MARSCOMM_MASTER, MARSCOMM_CMD_DISPLAY, #MARSCOMM_CMD_DISPLAY_DISABLE
        mars_comm_lp MARSCOMM_MASTER, MARSCOMM_CMD_PALETTE, #MARSCOMM_CMD_PALETTE_FILL
        mars_comm_lp MARSCOMM_MASTER, MARSCOMM_CMD_PALETTE, #MARSCOMM_CMD_PALETTE_COMMIT
        mars_comm_lp MARSCOMM_MASTER, MARSCOMM_CMD_IMAGE, %d0
        mars_comm_p1 MARSCOMM_MASTER, MARSCOMM_CMD_DISPLAY, #MARSCOMM_CMD_DISPLAY_SWAP
        mars_comm_p1 MARSCOMM_MASTER, MARSCOMM_CMD_DISPLAY, #MARSCOMM_CMD_DISPLAY_ENABLE
        mars_comm_lp MARSCOMM_SLAVE, MARSCOMM_CMD_PALETTE, #MARSCOMM_CMD_PALETTE_TRANSITION

        move.l  (%sp)+, %d0

        mars_comm_call_end
        rts


    |-------------------------------------------------------------------
    | Sub program initial handshake.
    | Should be called directly after ok signals from the 32X boot ROM's
    |-------------------------------------------------------------------
    __mars_comm_init:
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
    | - d5.w: non zero command id
    | - d6.w: comm port base offset relative to MARS_REG_BASE
    |-------------------------------------------------------------------
    __mars_comm:
        tst.w   %d5
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
        clr.w   2(%a6, %d6.w)

        | Send command
        move.w  %d5, (%a6, %d6.w)

        | Wait for command ready
    1:  cmp.w   2(%a6, %d6.w), %d5
        bne     1b

        | Send ACK
        clr.w   (%a6, %d6.w)

        | Give MD access to ROM (RV = 1)
        bset    #0, MARS_DMAC + 1(%a6)

        move.l  (%sp)+, %a6
    .exit:
        rts
    .z80_resume:
        move.w  #0, (Z80_BUS_REQUEST)
        rts
