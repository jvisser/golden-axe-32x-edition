|--------------------------------------------------------------------
| Called whenever the game state/mode changes
|--------------------------------------------------------------------

    .include "ga.i"
    .include "marscomm.i"
    .include "patch.i"


    patch_start 0x000c84
        jsr     state_change_handler.l
        nop
        nop
    patch_end


    |-------------------------------------------------------------------
    | Disable the 32X on game state changes
    |-------------------------------------------------------------------
    state_change_handler:
        move.w  #0xffff, (requested_game_state).w
        move.w  %d0, (current_game_state).w

        mars_comm_safe MARSCOMM_DISABLE
        rts
