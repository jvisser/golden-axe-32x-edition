/*
 * Idle processing patches (ie when there are no active ememies)
 */

#include "goldenaxe.h"
#include "patch.h"


    /**********************************************************
     * Goto camp site patches (requested via MAP_EVENT_CAMPSITE_ON_ENEMY_DEFEAT)
     *
     * Goto beginner mode ending on level 2 when beginner mode is active
     */
    patch_start 0x001282
        jsr     goto_camp_site_check_beginner_mode.l
    patch_end

    goto_camp_site_check_beginner_mode:
        // Beginner mode?
        btst    #B_GAME_MODE_BEGINNER, (game_mode_flags)
        beq     .no_beginner_mode_end

        // Town map?
        cmp.w   #2, current_level
        bne     .no_beginner_mode_end

        // Initiale beginner mode ending
        move.l  #0x00271e, (%sp)
        rts

    .no_beginner_mode_end:

        moveq   #SOUND_FADE_OUT, %d7
        jmp     play_music
