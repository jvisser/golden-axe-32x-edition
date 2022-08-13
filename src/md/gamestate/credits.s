/*
 * Credits patches
 */

#include "goldenaxe.h"
#include "patch.h"
#include "marscomm.h"


    /**********************************************************
     * Set 320 pixel wide display mode
     */
    patch_start 0x006616
        jsr     game_state_handler_credits_init.l
        nop
    patch_end

    game_state_handler_credits_init:
        ori     #0x0700, %sr
        jsr     vdp_disable_display
        jsr     vdp_set_mode_h40    // Game relied in display mode set by previous mode (cast in original game code)

        moveq   #SONG_CREDITS, %d7  // Sound from cast would be reused before, now we need to explicitly start it
        jmp     sound_command


    /**********************************************************
     * Allow skipping to the results by pressing an action button
     */
    #define credits_cycle 0xffffc334    // Seems to be shared by screen transition code...

    patch_start 0x0065f2
        jsr     game_state_handler_credits.l
    patch_end

    game_state_handler_credits:
        move.b  ctrl_player_1_changed, %d0
        or.b    ctrl_player_2_changed, %d0
        andi.b  #CTRL_ABCS, %d0
        beq     .exit

        move.w  #1, (credits_cycle) // Skip to the next mode (results)
    .exit:
        rts
