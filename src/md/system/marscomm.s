/*
 * 32X sub program communication
 */

#include "md.h"
#include "mars.h"
#include "marscomm.h"


    .equ    __Z80_SAFE, 1           // Set to 1 to halt the Z80 while RV=1


    .global __mars_comm_init
    .global __mars_comm

    .global mars_comm_display_disable
    .global mars_comm_display_enable
    .global mars_comm_palette_fade_in
    .global mars_comm_palette_fade_out
    .global mars_comm_image
    .global mars_comm_image_fade_in
    .global mars_comm_vertical_scroll
    .global mars_comm_palette_subtract


    /**********************************************************
     * Disable 32X display
     */
    mars_comm_display_disable:
        mars_comm_call_start
        mars_comm   MARS_COMM_SLAVE, MARS_COMM_CMD_DISPLAY_DISABLE
        mars_comm_call_end
        rts


    /**********************************************************
     * Enable 32X display
     */
    mars_comm_display_enable:
        mars_comm_call_start
        mars_comm   MARS_COMM_SLAVE, MARS_COMM_CMD_DISPLAY_ENABLE
        mars_comm_call_end
        rts


    /**********************************************************
     * Palette fade in
     */
    mars_comm_palette_fade_in:
        mars_comm_call_start
        mars_comm_lp MARS_COMM_SLAVE, MARS_COMM_CMD_PALETTE_FILL_PAL0,  #0x00ff0000
        mars_comm_lp MARS_COMM_SLAVE, MARS_COMM_CMD_PALETTE_TRANSITION, #0x00ff0842
        mars_comm_call_end
        rts


    /**********************************************************
     * Palette fade out
     */
    mars_comm_palette_fade_out:
        mars_comm_call_start
        mars_comm_lp MARS_COMM_SLAVE, MARS_COMM_CMD_PALETTE_FILL_PAL1,  #0x00ff0000
        mars_comm_lp MARS_COMM_SLAVE, MARS_COMM_CMD_PALETTE_TRANSITION, #0x00ff0842
        mars_comm_call_end
        rts


    /**********************************************************
     * Subtract the specified color value from the current palette
     *
     * Parameters:
     * - d0.w: color value
     */
    mars_comm_palette_subtract:
        mars_comm_call_start
        move.w  %d0, -(%sp)

        swap    %d0
        move.w  #0x00ff, %d0
        swap    %d0
        mars_comm_lp MARS_COMM_SLAVE, MARS_COMM_CMD_PALETTE_SUBTRACT, %d0

        move.w  (%sp)+, %d0
        mars_comm_call_end
        rts


    /**********************************************************
     * Load and show an image on the 32X
     *
     * Parameters:
     * - a0: image address
     */
    mars_comm_image:
        mars_comm_call_start
        mars_comm    MARS_COMM_MASTER, MARS_COMM_CMD_DISPLAY_DISABLE
        mars_comm_lp MARS_COMM_MASTER, MARS_COMM_CMD_IMAGE_PAL0, %a0
        mars_comm    MARS_COMM_MASTER, MARS_COMM_CMD_PALETTE_COMMIT
        mars_comm    MARS_COMM_MASTER, MARS_COMM_CMD_DISPLAY_SWAP
        mars_comm    MARS_COMM_MASTER, MARS_COMM_CMD_DISPLAY_ENABLE
        mars_comm_call_end
        rts


    /**********************************************************
     * Load an image on the 32X and fade in
     *
     * Parameters:
     * - a0: image address
     */
    mars_comm_image_fade_in:
        mars_comm_call_start
        mars_comm    MARS_COMM_MASTER, MARS_COMM_CMD_DISPLAY_DISABLE
        mars_comm_lp MARS_COMM_MASTER, MARS_COMM_CMD_PALETTE_FILL_PAL0, #0x00ff0000
        mars_comm    MARS_COMM_MASTER, MARS_COMM_CMD_PALETTE_COMMIT
        mars_comm_lp MARS_COMM_MASTER, MARS_COMM_CMD_IMAGE_PAL1, %a0
        mars_comm    MARS_COMM_MASTER, MARS_COMM_CMD_DISPLAY_SWAP
        mars_comm    MARS_COMM_MASTER, MARS_COMM_CMD_DISPLAY_ENABLE
        mars_comm_lp MARS_COMM_SLAVE,  MARS_COMM_CMD_PALETTE_TRANSITION, #0x00ff0842
        mars_comm_call_end
        rts


    /**********************************************************
     * Update 32X linetable for vertical scrolling 256 line image
     *
     * Parameters:
     * - d0.w: vertical scroll value
     */
    mars_comm_vertical_scroll:
        mars_comm_call_start
        move.w  %d0, -(%sp)
        andi.w  #0xff, %d0
        ori.w   #MARS_COMM_CMD_VERTICAL_SCROLL, %d0

        mars_comm_dyn_cmd MARS_COMM_MASTER, %d0

        move.w  (%sp)+, %d0
        mars_comm_call_end
        rts


    /**********************************************************
     * Sub program initial handshake.
     * Should be called directly after ok signals from the 32X boot ROM's
     */
    __mars_comm_init:
        lea     (MARS_REG_BASE), %a6

        // Set HW/VDP access to the 32X side
        bset    #7, MARS_ADP_CTL(%a6)

        // Wait for the 32X to accept HW control
    1:  tst.l   MARS_COMM0(%a6)
        bne     1b
    1:  tst.l   MARS_COMM2(%a6)
        bne     1b
        rts


    .data       // Use the .data section to store this routine in RAM allowing RV switching
    .balign 2

    /**********************************************************
     * Send command to the 32X sub program.
     * Command specific parameters must be set in the communication registers before calling.
     *
     * Params:
     * - d5.w: non zero command id
     * - d6.w: comm port base offset relative to MARS_REG_BASE
     */
    __mars_comm:
        tst.w   %d5
        beq     .exit

        lea     (MARS_REG_BASE), %a6

        // Wait for 32X ready
    1:  tst.w   2(%a6, %d6.w)
        bne     1b

        // Give the 32X access to ROM?
        bclr    #15, %d5
        beq     .no_rom_access_requested

    .ifne __Z80_SAFE
        // Halt Z80 if not halted already
        btst    #0, (Z80_BUS_REQUEST)
        beq     .z80_halted
        move.w  #0x0100, (Z80_BUS_REQUEST)
    1:  btst    #0, (Z80_BUS_REQUEST)
        bne     1b
        pea     .z80_resume
    .z80_halted:
    .endif

        // RV = 0
        bclr    #0, MARS_DMAC + 1(%a6)
    .no_rom_access_requested:

        // Clear response register
        clr.w   2(%a6, %d6.w)

        // Send command
        move.w  %d5, (%a6, %d6.w)

        // Wait for command ready
    1:  cmp.w   2(%a6, %d6.w), %d5
        bne     1b

        // Send ACK
        clr.w   (%a6, %d6.w)

        // Give MD access to ROM (RV = 1)
        bset    #0, MARS_DMAC + 1(%a6)
    .exit:
        rts
    .z80_resume:
        move.w  #0, (Z80_BUS_REQUEST)
        rts
