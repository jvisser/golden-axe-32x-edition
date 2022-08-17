/*
 * Background eyeballs
 */

#include "goldenaxe.h"
#include "entity.h"
#include "patch.h"


    /**********************************************************
     * Replace Level 6 door entity with eye ball entity.
     * Assumes the tiles are loaded at the top of the tile VRAM area.
     */
    patch_start 0x00b00a
        jmp     entity_logic_eye_ball
    patch_end

    entity_logic_eye_ball:
        bset    #7, entity_id(%a0)
        bne     .run_logic

        move.l  #eye_animation_table, entity_animation_table(%a0)

        move.w  (current_level), %d0
        cmp.w   #2, %d0
        beq     .turtle
        cmp.w   #4, %d0
        beq.    .eagle
        jmp     remove_entity

    .turtle:
        move.w  #0, entity_animation_offset(%a0)
        move.w  #GAME_PLAY_VRAM_DYNAMIC_TOP_TILE - TURTLE_EYE_TILE_COUNT, entity_tile_id(%a0)
        move.w  #TURTLE_EYE_X + TURTLE_EYE_WIDTH, entity_map_init_data(%a0)
        move.w  #128 + TURTLE_EYE_X, %d0
        move.w  #128 + TURTLE_EYE_Y, %d1
        bra     .init
    .eagle:
        move.w  #4, entity_animation_offset(%a0)
        move.w  #GAME_PLAY_VRAM_DYNAMIC_TOP_TILE - EAGLE_EYE_TILE_COUNT, entity_tile_id(%a0)
        move.w  #EAGLE_EYE_X + EAGLE_EYE_WIDTH, entity_map_init_data(%a0)
        move.w  #128 + EAGLE_EYE_X, %d0
        move.w  #128 + EAGLE_EYE_Y, %d1
    .init:
        sub.w   (horizontal_scroll), %d0
        sub.w   (vertical_scroll), %d1
        move.w  %d0, entity_x(%a0)
        move.w  %d1, entity_y(%a0)
        move.b  #HIGH_BYTE(VDP_ATTR_PAL3), entity_sprite_attr(%a0)
        move.b  #40,entity_animation_frame_time(%a0)
        move.b  #40,entity_animation_frame_time_left(%a0)
        jmp     load_pre_load_animation_frame

    .run_logic:
        move.w  (horizontal_scroll), %d0
        cmp.w   entity_map_init_data(%a0), %d0
        bcc     .remove
        jmp     update_pre_load_animation
    .remove:
        jmp     remove_entity


    .section .rodata

    .balign 2

    eye_animation_table:
        .dc.l   turtle_eye_animation
        .dc.l   eagle_eye_animation

    turtle_eye_animation:
        .dc.b   4                       // frameCount
        .dc.b   0
        .dc.l   turtle_eye_0
        .dc.l   turtle_eye_1
        .dc.l   turtle_eye_2
        .dc.l   turtle_eye_1

    eagle_eye_animation:
        .dc.b   4
        .dc.b   0
        .dc.l   eagle_eye_0
        .dc.l   eagle_eye_1
        .dc.l   eagle_eye_2
        .dc.l   eagle_eye_1

    // Animation frame meta sprites
    turtle_eye_0:
        .dc.b   0                       // Sprite count - 1
        .dc.b   0                       // Hurt bounds index
        .dc.b   0                       // Damage bounds index
        // Sprite
        .dc.b   0                       // Y offset
        .dc.b   VDP_SPRITE_SIZE_H2_V2   // Size
        .dc.w   0                       // Relative pattern id
        .dc.b   0                       // X offset
    turtle_eye_1:
        .dc.b   0
        .dc.b   0
        .dc.b   0
        // Sprite
        .dc.b   0
        .dc.b   VDP_SPRITE_SIZE_H2_V2
        .dc.w   4
        .dc.b   0
    turtle_eye_2:
        .dc.b   0
        .dc.b   0
        .dc.b   0
        // Sprite
        .dc.b   0
        .dc.b   VDP_SPRITE_SIZE_H2_V2
        .dc.w   8
        .dc.b   0


    eagle_eye_0:
        .dc.b   0
        .dc.b   0
        .dc.b   0
        // Sprite
        .dc.b   0
        .dc.b   VDP_SPRITE_SIZE_H4_V4
        .dc.w   0
        .dc.b   0
    eagle_eye_1:
        .dc.b   0
        .dc.b   0
        .dc.b   0
        // Sprite
        .dc.b   0
        .dc.b   VDP_SPRITE_SIZE_H4_V4
        .dc.w   16
        .dc.b   0
    eagle_eye_2:
        .dc.b   0
        .dc.b   0
        .dc.b   0
        // Sprite
        .dc.b   0
        .dc.b   VDP_SPRITE_SIZE_H4_V4
        .dc.w   32
        .dc.b   0
