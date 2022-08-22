/*
 * Cast patches
 */

#include "goldenaxe.h"
#include "patch.h"
#include "marscomm.h"


#define cast_screen_id      0xffffc320
#define cast_transition     0x000048b6


    /**********************************************************
     * Disable music
     */
    patch_start 0x00494c
        moveq   #SOUND_STOP, %d7
    patch_end


    /**********************************************************
     * Skip "cast" text screen
     */
    patch_start 0x004974
        nop
        nop
    patch_end

    patch_start 0x004988
        jmp     game_state_handler_cast_init.l
    patch_end

    game_state_handler_cast_init:
        move.w  #4, cast_screen_id
        jmp     cast_transition


    /**********************************************************
     * Make cast screen interactive
     */
    patch_start 0x0048cc                // Speed up tile loading slightly
        jsr     vdp_disable_display.l
        nop
        nop
    patch_end

    patch_start 0x004908
        jsr     vdp_enable_display.l
        rts                             // Create cast_transition subroutine
    patch_end

    patch_start 0x0048b6                // Transition palette to black instead of white
        moveq   #0, %d1
        nop
        nop
    patch_end

    patch_start 0x004920                // Speed up palette transition
        moveq   #1, %d2
    patch_end

    patch_start 0x0048b0
        jmp     game_state_handler_cast.l
    patch_end

    game_state_handler_cast:

        move.b  ctrl_player_1_changed, %d0
        or.b    ctrl_player_2_changed, %d0

        /* Player pressed left?
           TODO: Need to update data tables to support going back. Cast screen tileset collections are optimized for one direction only */
/*
        btst.b  #B_CTRL_LEFT, %d0
        beq     .check_right
        subq.w  #4, cast_screen_id
        bne     .right_ok
        move.w  #0x48, cast_screen_id
    .right_ok:
        jmp     cast_transition
*/

        /* Player pressed right?
           TODO: Implement when left is implemented. For now use a/b/c to go right as that does not imply left can be used also */
/*
    .check_right:
        //btst.b  #B_CTRL_RIGHT, %d0
*/
        move.b  %d0, %d1
        andi.b  #CTRL_ABC, %d1
        beq     .check_start
        addq.w  #4, cast_screen_id
        cmpi.w  #0x4c, cast_screen_id
        bne     .left_ok
        move.w  #4, cast_screen_id
    .left_ok:
        jmp     cast_transition

        // Player pressed start?
    .check_start:
        andi.b  #CTRL_START, %d0
        beq     .continue

        /* Exit to title */
        move.w  #GAME_STATE_TITLE, requested_game_state
        jmp     vdp_clear_palette

    .continue:
        move.w  #VBLANK_UPDATE_SPRITE_ATTR|VBLANK_UPDATE_CONTROLLER, %d0
        jmp     vdp_vsync_wait
