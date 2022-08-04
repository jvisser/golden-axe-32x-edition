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
     * Don't use death adder's entity slot so he can be kept on screen in the final cutscene
     * Also change to use palette 3 which was used for the background in the original game.
     * basically after death adder as defined in eagles head map def
     */
    patch_start 0x0026be
        move.b  #ENTITY_TYPE_KING, ENTITY_SLOT_ADDR(4)
    patch_end


    /**********************************************************
     * Load the king and queen graphics at safe tile address so we can keep death adder's corpse on screen.
     * Also change to use palette 3 which was used for the background in the original game.
     * basically after death adder as defined in eagles head map def
     */
    #define KING_QUEEN_TILE_ID (GAME_PLAY_VRAM_RESERVED_TILE_MAX + BAD_BROTHER_TILE_COUNT + NEM_DEATH_ADDER_TILE_COUNT)

    patch_start 0x0025fa
        move.l  #VRAM_ADDR_SET(TILE_ADDR(KING_QUEEN_TILE_ID)), (VDP_CTRL).l
    patch_end

    // Use palette 3
    patch_start 0x038584
        .dc.b   0x60
    patch_end

    // Chain sprite
    patch_start 0x00b1fe
        move.b  #0x60, ENTITY_SPRITE_ATTR(%a0)
        move.w  #KING_QUEEN_TILE_ID, ENTITY_TILE_ID(%a0)
    patch_end

    // King sprite
    patch_start 0x00b244
        move.b  #0x60, ENTITY_SPRITE_ATTR(%a0)
        move.w  #KING_QUEEN_TILE_ID, ENTITY_TILE_ID(%a0)
    patch_end

    // Queen sprite
    patch_start 0x00b2f0
        move.b  #0x60, ENTITY_SPRITE_ATTR(%a0)
        move.w  #KING_QUEEN_TILE_ID, ENTITY_TILE_ID(%a0)
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
