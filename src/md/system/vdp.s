|--------------------------------------------------------------------
| VDP routines
|--------------------------------------------------------------------

    .include "md.i"
    .include "ga.i"
    .include "marscomm.i"
    .include "patch.i"


    .global vdp_vsync_wait
    .global vdp_enable_display
    .global vdp_disable_display
    .global vdp_reset


    .equ vblank_int_handler,    0x000cf6
    .equ vdp_reset,             0x000df6


    |-------------------------------------------------------------------
    | Enable display
    |-------------------------------------------------------------------
    patch_start 0x002dca
        jmp     vdp_disable_display
    patch_end

    vdp_disable_display:
        bclr    #6, (vdp_reg_mode2 + 1).w
        bsr     vdp_update_mode_2_sync

        | Disable display on the 32X
        moveq   #MARSCOMM_DISABLE, %d0
        jmp     mars_comm


    |-------------------------------------------------------------------
    | Disable display
    |-------------------------------------------------------------------
    patch_start 0x002dca
        jmp     vdp_enable_display
    patch_end

    vdp_enable_display:
        bset    #6, (vdp_reg_mode2 + 1).w


    |-------------------------------------------------------------------
    | Sync mode 2 shadow register with the VDP
    |-------------------------------------------------------------------
    vdp_update_mode_2_sync:
        move.w  (vdp_reg_mode2).w, (VDP_CTRL)
        rts


    |--------------------------------------------------------------------
    | Remove the dependence on the vertical interrupt.
    |
    | This is done by:
    | - Disabling vertical interrupts on the VDP
    | - Changing the original vblank_int_handler into a subroutine
    | - Changing the original vint_wait subroutine into a vsync_wait subroutine that polls the VDP status register and
    |   when in the vertical blank period calls the original vblank_int_handler which is now a subroutine.
    |--------------------------------------------------------------------

    | Change vblank_int_handler into a subroutine
    patch_start 0x000d60
        rts                 | rte = rts
    patch_end

    | Reconfigure the VDP mode 2 register to disable vertical interrupts
    patch_start 0x000e50
        .dc.w   0x8114
    patch_end

    | Change the vint_wait subroutine into a vsync_wait subroutine
    patch_start 0x000da8
        jmp     vdp_vsync_wait
    patch_end


    |-------------------------------------------------------------------
    | Wait for vertical blank by polling the VDP status register
    |
    | Params:
    | - d0.b: vblank_update_flags
    |-------------------------------------------------------------------
    vdp_vsync_wait:
        move.b  %d0, (vblank_update_flags)

        btst    #6, (vdp_reg_mode2 + 1)     | Check if display is enabled
        beq     2f
        move.l  %a0, -(%sp)
        lea     (VDP_CTRL + 1), %a0
    1:  btst    #3, (%a0)                   | Wait until we are out of vblank (if in vblank at this point we have a frameskip)
        bne     1b
    1:  btst    #3, (%a0)                   | Wait until we are in vblank
        beq     1b
        move.l  (%sp)+, %a0

        jmp     vblank_int_handler
    2:  rts
