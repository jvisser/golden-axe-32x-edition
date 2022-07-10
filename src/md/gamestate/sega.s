|--------------------------------------------------------------------
| Replace the sega logo game state subroutine.
|--------------------------------------------------------------------

    .include "ga.i"
    .include "mars.i"
    .include "marscomm.i"
    .include "patch.i"


    patch_start 0x000db8
        jmp     game_state_handler_sega
    patch_end


    |-------------------------------------------------------------------
    | Run custom sega logo code
    |-------------------------------------------------------------------
    game_state_handler_sega:

        move.l  #sega_logo_image, (MARS_REG_BASE + MARS_COMM4)
        moveq   #MARSCOMM_IMAGE, %d0
        jsr     mars_comm

        jsr     vdp_enable_display

        | Wait 2 seconds to show logo
        moveq   #120, %d0
    1:  jsr     vdp_vsync_wait
        dbf     %d0, 1b

        move.w  #GAME_STATE_TITLE, requested_game_state
        rts
