|--------------------------------------------------------------------
| Replace the sega logo game state subroutine.
|--------------------------------------------------------------------

    .include "ga.i"
    .include "patch.i"


    patch_start 0x000db8
        jmp     game_state_handler_sega
    patch_end


    .text

    |-------------------------------------------------------------------
    | Run custom sega logo code
    |-------------------------------------------------------------------
    game_state_handler_sega:
        move.w  #GAME_STATE_TITLE, requested_game_state
        rts
