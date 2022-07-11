|--------------------------------------------------------------------
| Replace the sega logo game state subroutine.
|--------------------------------------------------------------------

    .include "goldenaxe.i"
    .include "mars.i"
    .include "marscomm.i"
    .include "patch.i"


    patch_start 0x000db8
        jsr     game_state_handler_sega.l
        nop
    patch_end


    |-------------------------------------------------------------------
    | Run custom sega logo code
    |-------------------------------------------------------------------
    game_state_handler_sega:
        jsr     audio_init.w

        jsr     vdp_disable_display
        jsr     vdp_reset

        mars_comm_image img_sega_logo

        jsr     vdp_enable_display

        | Wait 2 seconds to show logo
        moveq   #120, %d1
    1:  move.w  #VBLANK_UPDATE_CONTROLLER, %d0
        jsr     vdp_vsync_wait

        move.b  (ctrl_player_1_changed).w, %d0
        or.b    (ctrl_player_2_changed).w, %d0
        andi.b  #0xf0, %d0                          | If any player pressed a/b/c/start exit
        bne     1f
        dbf     %d1, 1b
    1:  rts
