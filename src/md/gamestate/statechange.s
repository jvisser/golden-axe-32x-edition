/*
 * Called whenever the game state/mode changes
 */

#include "goldenaxe.h"
#include "marscomm.h"
#include "patch.h"


    /**********************************************************
     * Disable the 32X on game state changes (except for game over)
     */
    patch_start 0x000c84
        jsr     state_change_handler.l
        nop
        nop
    patch_end

    state_change_handler:
        move.w  #0xffff, (requested_game_state)
        move.w  %d0, (current_game_state)

        cmpi.w  #GAME_STATE_GAME_OVER, %d0
        beq     .keep_display_on
        jmp     mars_comm_display_disable
    .keep_display_on:
        rts
