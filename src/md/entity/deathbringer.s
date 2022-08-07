/*
 * Death Bringer specific entity patches
 */

#include "goldenaxe.h"
#include "md.h"
#include "entity.h"
#include "patch.h"


    /**********************************************************
     * Remap axe tile id so it doesnt clash with the dragon and king/queen
     */
    patch_start 0x013818    // VRAM address
        move.l  #VRAM_ADDR_SET(GAME_PLAY_VRAM_RESERVED_MIN), (VDP_CTRL)
    patch_end

    patch_start 0x0137e2    // Remap tile id
        move.w  #GAME_PLAY_VRAM_RESERVED_TILE_MIN, ENTITY_TILE_ID(%a0)
    patch_end


    /**********************************************************
     * Remove chair sitting sequence
     */
    patch_start 0x0119c8
        move.b  #4, 0x4c(%a0)       // Set attack mode
        .rept 7
            nop
        .endr
    patch_end
