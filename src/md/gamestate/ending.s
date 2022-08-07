/*
 * Game ending sequence patches
 */

#include "goldenaxe.h"
#include "entity.h"
#include "patch.h"


    /**********************************************************
     * Death bringer ending after map 5 (instead of 8)
     * Triggered by map event: MAP_EVENT_END_GAME_ON_ENEMY_DEFEAT
     */
    patch_start 0x0026d8
        .dc.w   0x0004
    patch_end


    /**********************************************************
     * Normal ending after map 5 (instead of 8)
     *
     * Triggered by map event: MAP_EVENT_NEXT_LEVEL_ON_ENEMY_DEFEAT
     */
    patch_start 0x002570
        .dc.w   0x0004
    patch_end


    /**********************************************************
     * Remove ending text boxes and go straight to the ending intermission
     */
    patch_start 0x00b3c8
        move.w  #5*60, %d1
        jsr     wait_n_frames
        bcs     .exit

        jsr     screen_transition_to_dark

    .exit:
        clr.w   current_level   // Signifies end
        move.w  #GAME_STATE_INTERMISSION, requested_game_state
        rts
    patch_end
