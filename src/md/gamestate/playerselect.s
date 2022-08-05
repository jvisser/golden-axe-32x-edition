/*
 * Player select screen patches
 */

#include "goldenaxe.h"
#include "patch.h"
#include "marscomm.h"


    /**********************************************************
     * Load arcade background and initiate fade in
     */
    patch_start 0x004436
        jmp     game_state_handler_player_select_init.l
    patch_end

    game_state_handler_player_select_init:
        lea     (img_dungeon_background), %a0
        move.w  #SONG_TITLE, %d7
        jmp     show_image_with_sound


    /**********************************************************
     * Disable palette change when cycling characters
     */
    patch_start 0x004682
        nop
        nop
    patch_end


    /**********************************************************
     * Limit level select to the arcade levels only
     */
    patch_start 0x004466
        jsr     limit_level_select.l
        nop
    patch_end

    limit_level_select:
        cmp.w   #5, (%a0)
        bne     .high_ok
        subq.w  #5, (%a0)
    .high_ok:
        cmp.w   #7, (%a0)
        bne     .low_ok
        subq.w  #3, (%a0)
    .low_ok:
        move.w  (%a0), %d0
        addq.w  #2, %d0
        add.w   (font_tile_offset), %d0
        rts
