/*
 * King and queen patches (ending sequence)
 */

#include "goldenaxe.h"
#include "entity.h"
#include "patch.h"


    /**********************************************************
     * Don't use death adder's entity slot so he can be kept on screen in the final cutscene
     */
    patch_start 0x0026be
        move.b  #ENTITY_TYPE_KING, ENTITY_SLOT_ADDR(4)
    patch_end


    /**********************************************************
     * Load the king and queen graphics at safe tile address so we can keep death adder's corpse on screen.
     * Basically after death adder's tile data as defined in eagles head map def
     * Also change to use palette 2 which is free at this point
     */
    #define KING_QUEEN_TILE_ID (GAME_PLAY_VRAM_RESERVED_TILE_MAX + BAD_BROTHER_TILE_COUNT + NEM_DEATH_ADDER_TILE_COUNT)

    patch_start 0x0025fa
        move.l  #VRAM_ADDR_SET(TILE_ADDR(KING_QUEEN_TILE_ID)), (VDP_CTRL).l
    patch_end

    // Use palette 2
    patch_start 0x038584
        .dc.b   0x40
    patch_end

    // Chain sprite
    patch_start 0x00b1fe
        move.b  #0x40, ENTITY_SPRITE_ATTR(%a0)
        move.w  #KING_QUEEN_TILE_ID, ENTITY_TILE_ID(%a0)
    patch_end

    // King sprite
    patch_start 0x00b244
        move.b  #0x40, ENTITY_SPRITE_ATTR(%a0)
        move.w  #KING_QUEEN_TILE_ID, ENTITY_TILE_ID(%a0)
    patch_end

    // Queen sprite
    patch_start 0x00b2f0
        move.b  #0x40, ENTITY_SPRITE_ATTR(%a0)
        move.w  #KING_QUEEN_TILE_ID, ENTITY_TILE_ID(%a0)
    patch_end
