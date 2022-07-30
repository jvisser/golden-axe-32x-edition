/*
 * Sega logo screen patches
 */

#include "goldenaxe.h"
#include "md.h"
#include "mars.h"
#include "marscomm.h"
#include "patch.h"


    /**********************************************************
     * Run custom sega logo code
     */
    patch_start 0x000db8
        jsr     game_state_handler_sega.l
        nop
    patch_end

    game_state_handler_sega:
        jsr     vdp_disable_display
        jsr     vdp_reset
        jsr     audio_init.w

        lea     (img_sega_logo), %a0
        jsr     mars_comm_image_fade_in

        jsr     vdp_enable_display

        /* Show the Sega logo for 2 seconds or until the player presses an action button */
        moveq   #60*2, %d1
        jsr     wait_n_frames
        bcs     .exit               /* skip fade out if player requested starting the game */

        /* Fade out and wait (takes 16 frames) */
        jsr     mars_comm_palette_fade_out
        moveq   #16, %d1
    1:  jsr     vdp_vsync_wait
        dbf     %d1, 1b

    .exit:
        rts
