/*
 * Character profile patches
 */

#include "goldenaxe.h"
#include "md.h"
#include "patch.h"
#include "marscomm.h"


    /**********************************************************
     * Change end screen transition from palette fade out to the arcade transition
     */
    patch_start 0x005494
        bsr     screen_transition_to_dark.w
    patch_end


    /**********************************************************
     * Disable fade in like the arcade version
     */
/*
    patch_start 0x005552
        bsr     palette_update_dynamic.w
        nop
        nop
        nop
    patch_end
*/


    /**********************************************************
    * Show death adder profile
    */
    patch_start 0x0054a8
        jsr     game_state_handler_profile_end.l
        nop
    patch_end

    game_state_handler_profile_end:
        lea     (img_death_adder), %a0
        jsr     mars_comm_image
        jsr     screen_transition_from_dark

        /* Show death adder profile for 5 seconds or until the player presses an action button */
        move.w  #5*60, %d1
        jsr     wait_n_frames
        bcs     .player_exit        // skip transition if player requested a return to the title screen

        jsr     screen_transition_to_dark

    .player_exit:
        jsr     vdp_clear_palette

        clr.b   (demo_index)
        move.w  #GAME_STATE_TITLE, %d0
        rts
