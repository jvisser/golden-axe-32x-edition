/*
 * Player character patches
 */

#include "goldenaxe.h"
#include "entity.h"
#include "patch.h"


    /**********************************************************
     * Patch initial auto walk animation to only occur if the current/starting player position is offscreen to the left
     */
    patch_start 0x0014bc
        jsr     players_init
    patch_end

    players_init:
        lea     (entity_player_1), %a0
        bsr     init_player_auto_walk
        lea     (entity_player_2), %a0
        jmp     init_player_auto_walk

    init_player_auto_walk:
        /* Check if the current player state is auto walk */
        cmp.b   #0x68, ENTITY_STATE(%a0)
        bne     .exit

        /* Auto walk if outside of the left horizontal screen boundary */
        cmp.w   #0x80, ENTITY_X(%a0)
        bcs     .exit

        /* Skip auto walk */
        clr.b   ENTITY_STATE(%a0)

    .exit:
        rts


    /**********************************************************
     * Walk to top of level before cutscene after final boss defeat
     */
    #define target_base_y   152

    patch_start 0x0082fa
        move.w  #target_base_y, %d2
    patch_end

    patch_start 0x00833c
        move.w  #target_base_y, %d3
    patch_end


    /**********************************************************
     * Select the proper walk animation between mounted and unmounted for the ending walk sequence
     */
    patch_start 0x00836a
        jmp     player_select_ending_walk_animation.l
    patch_end

    patch_start 0x00838c
        jmp     player_select_ending_walk_animation.l
    patch_end

    patch_start 0x0083d8
        jmp     player_select_ending_stand_still_animation.l
    patch_end

    player_select_ending_walk_animation:
        moveq   #4, %d0
        bsr     select_mounted_animation
        jmp     update_animation

    player_select_ending_stand_still_animation:
        moveq   #0, %d0
        bsr     select_mounted_animation
        jmp     setup_animation

    select_mounted_animation:
        btst    #B_ENTITY_FLAGS3_MOUNTED, ENTITY_FLAGS3(%a0)
        beq.s   1f
        move.w  #23*4, %d0      // Select animation offset 23
    1:  rts


    /**********************************************************
     * Fix: Cause unmount on knockdown request without damage received flag set.
     * This caused issues with death adders attacks which didn't properly unmount causing issues such as the dragon being stuk in attack state.
     */
    patch_start 0x006ede
        jsr     player_unmount_on_knowdown.l
    patch_end

    player_unmount_on_knowdown:
        btst    #B_ENTITY_FLAGS3_MOUNTED, ENTITY_FLAGS3(%a0)        // Mounted check
        beq.s   1f

        movea.l ENTITY_MOUNT(%a0), %a3                              // Load mount address
        bclr    #B_ENTITY_FLAGS3_MOUNTED, ENTITY_FLAGS3(%a0)        // Flag as unmounted
        bset    #7, 0x49(%a3)                                       // Flag mount as unmounted

    1:  bset    #2, ENTITY_FLAGS1(%a0)
        rts
