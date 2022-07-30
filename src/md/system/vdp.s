/*
 * VDP patches
 */

#include "md.h"
#include "goldenaxe.h"
#include "marscomm.h"
#include "patch.h"


    .global vdp_vsync_wait
    .global vdp_clear_name_tables


    /**********************************************************
     * Disable display
     */
    patch_start 0x002dca
        jmp     _vdp_disable_display
    patch_end

    _vdp_disable_display:
        bclr    #6, (vdp_reg_mode2 + 1)
        move.w  (vdp_reg_mode2), (VDP_CTRL)
        jmp     mars_comm_display_disable


    /**********************************************************
     * Remove the dependence on the vertical interrupt.
     *
     * This is done by:
     * - Disabling vertical interrupts on the VDP
     * - Changing the original vblank_int_handler into a subroutine
     * - Changing the original vint_wait subroutine into a vsync_wait subroutine that polls the VDP status register and
     *   when in the vertical blank period calls the original vblank_int_handler which is now a subroutine.
     */

    /* Change vblank_int_handler into a subroutine */
    patch_start 0x000d60
        rts                 | rte = rts
    patch_end

    /* Reconfigure the VDP mode 2 register to disable vertical interrupts */
    patch_start 0x000e50
        .dc.w   0x8114
    patch_end

    /* Change the vint_wait subroutine into a vsync_wait subroutine */
    patch_start 0x000da8
        jmp     vdp_vsync_wait
    patch_end


    /**********************************************************
     * Wait for vertical blank by polling the VDP status register
     *
     * Params:
     * - d0.b: vblank_update_flags
     */
    vdp_vsync_wait:
        move.b  %d0, (vblank_update_flags)

        btst    #6, (vdp_reg_mode2 + 1)     /* Check if display is enabled */
        beq     .display_disabled

        move.l  %a0, -(%sp)
        lea     (VDP_CTRL + 1), %a0
    1:  btst    #3, (%a0)                   /* Wait until we are out of vblank (if in vblank at this point we have a frameskip) */
        bne     1b
    1:  btst    #3, (%a0)                   /* Wait until we are in vblank */
        beq     1b
        move.l  (%sp)+, %a0

        jmp     vblank_int_handler

    .display_disabled:
        rts


    /**********************************************************
     * Clear the plane A/B nametable
     */
    vdp_clear_name_tables:
        move.l  #VDP_ADDR_SET_NAME_TBL_A, (VDP_CTRL)
        lea     (VDP_DATA), %a0
        move.w  #0x1fff, %d0
        moveq   #0, %d1
    1:  move.w  %d1, (%a0)
        dbf     %d0, 1b
        rts
