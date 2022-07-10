|--------------------------------------------------------------------
| Replace the sega logo game state subroutine.
|--------------------------------------------------------------------

    .include "ga.i"
    .include "mars.i"
    .include "marscomm.i"
    .include "patch.i"


    patch_start 0x000db8
        jsr     game_state_handler_sega.l
        nop
    patch_end


    .equ audio_init,    0x0034bc


    |-------------------------------------------------------------------
    | Run custom sega logo code
    |-------------------------------------------------------------------
    game_state_handler_sega:
        jsr     audio_init.w

        jsr     vdp_disable_display
        jsr     vdp_reset
        jsr     img_load_sega_logo
        jsr     vdp_enable_display

        | Wait 2 seconds to show logo
        moveq   #120, %d0
    1:  jsr     vdp_vsync_wait
        dbf     %d0, 1b

        move.w  #GAME_STATE_TITLE, requested_game_state
        rts
