|--------------------------------------------------------------------
| Called whenever the game state/mode changes
|--------------------------------------------------------------------

    .include "goldenaxe.i"
    .include "marscomm.i"
    .include "patch.i"


    |-------------------------------------------------------------------
    | Disable the 32X on game state changes
    |-------------------------------------------------------------------
    patch_start 0x000c84
        jsr     state_change_handler.l
        nop
        nop
    patch_end

    state_change_handler:
        move.w  #0xffff, (requested_game_state).w
        move.w  %d0, (current_game_state).w

        jmp     mars_comm_display_disable
