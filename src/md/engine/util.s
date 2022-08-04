/*
 * Collection of utility functions
 */

#include "goldenaxe.h"
#include "md.h"


    .global wait_n_frames
    .global show_image_with_sound


    /**********************************************************
     * Wait n frames or until the player presses an action button
     *
     * Parameters:
     * - d1.w: frametime - 1 (0 = 1)
     *
     * Return
     * - ccr.c: if player exited
     */
    wait_n_frames:
    1:  move.w  #VBLANK_UPDATE_CONTROLLER, %d0
        jsr     vdp_vsync_wait

        move.b  (ctrl_player_1_changed), %d0
        or.b    (ctrl_player_2_changed), %d0
        andi.b  #CTRL_ABCS, %d0
        bne     .player_exit
        dbf     %d1, 1b
        and     #~1, %ccr
        rts
    .player_exit:
        or      #1, %ccr
        rts


    /**********************************************************
     * Show the specified image with fade in and play the specified sound.
     * Useful for cutscenes etc...
     *
     * Parameters:
     * - a0: image address
     * - d7.b: song id
     *
     * Return
     * - ccr.c: if player exited
     */
    show_image_with_sound:
        jsr     mars_comm_image_fade_in

        move.w  %d7, -(%sp)
        jsr     palette_interpolate_full
        move.w  (%sp)+, %d7

        /* Start sound after fade in */
        jmp     sound_command
