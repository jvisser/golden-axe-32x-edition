/*
 * Death Adder entity patches to make him a reusable entity
 */

#include "goldenaxe.h"
#include "md.h"
#include "entity.h"
#include "patch.h"


    /**********************************************************
     * Remap tile id of death adder projectile so it doesn't clash with the dragon loaded at tile number 1 in the eagles head map
     */

    // Special attack
    patch_start 0x008de4    // VRAM address
        move.l  #VRAM_ADDR_SET(TILE_ADDR(DEATH_ADDER_SPECIAL_TILE_ID)), (VDP_CTRL)
    patch_end

    patch_start 0x012024    // VRAM address
        move.l  #VRAM_ADDR_SET(TILE_ADDR(DEATH_ADDER_SPECIAL_TILE_ID)), (VDP_CTRL)
    patch_end

    patch_start 0x0131e8    // Remap tile id
        move.w  #DEATH_ADDER_SPECIAL_TILE_ID, ENTITY_TILE_ID(%a0)
    patch_end

    patch_start 0x01378C    // Remap tile id
        move.w  #DEATH_ADDER_SPECIAL_TILE_ID, ENTITY_TILE_ID(%a0)
    patch_end

    patch_start 0x01230e    // Remap tile id
        move.w  #DEATH_ADDER_SPECIAL_TILE_ID, ENTITY_TILE_ID(%a5)
        nop
    patch_end


    /**********************************************************
     * Remove open door animation sequence
     */
    patch_start 0x01198c
        jmp     0x0119a8
    patch_end


    /**********************************************************
     * Remove close door animation sequence
     */
    patch_start 0x011fc2
        .rept 5
            nop
        .endr
    patch_end


    /**********************************************************
     * Update death adder palette immediately
     */
    patch_start 0x011fb6
        nop
        nop
        nop
    patch_end


    /**********************************************************
     * Remove palette transition including its 8 frame hang time
     */
    patch_start 0x0119ae
        jsr     palette_update_dynamic_commit.l
    patch_end


    /**********************************************************
     * Skip wait time for door open
     */
    patch_start 0x011f82
        jmp     0x011faa
    patch_end
