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
