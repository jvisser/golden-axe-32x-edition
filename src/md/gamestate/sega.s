|--------------------------------------------------------------------
| Replace the sega logo game state subroutine.
|--------------------------------------------------------------------

    .include "goldenaxe.i"
    .include "mars.i"
    .include "marscomm.i"
    .include "patch.i"


    |-------------------------------------------------------------------
    | Run custom sega logo code
    |-------------------------------------------------------------------
    patch_start 0x000db8
        jsr     game_state_handler_sega.l
        nop
    patch_end

    game_state_handler_sega:
        jsr     vdp_disable_display
        jsr     vdp_reset
        jsr     audio_init.w

        lea     (img_sega_logo), %a0
        jsr     mars_comm_image_fade_in

        jsr     vdp_enable_display

        | Wait 2 seconds to show logo
        moveq   #120, %d1
    1:  move.w  #VBLANK_UPDATE_CONTROLLER, %d0
        jsr     vdp_vsync_wait

        move.b  (ctrl_player_1_changed), %d0
        or.b    (ctrl_player_2_changed), %d0
        andi.b  #0xf0, %d0                          | If any player pressed a/b/c/start exit immediately
        bne     3f
        dbf     %d1, 1b

        | Fade out and wait (takes 16 frames)
        jsr     mars_comm_palette_fade_out
        moveq   #16, %d1
    2:  jsr     vdp_vsync_wait
        dbf     %d1, 2b
    3:  rts
