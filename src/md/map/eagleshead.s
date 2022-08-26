/*
 * Eagles's head patches
 */

#include "goldenaxe.h"
#include "map.h"
#include "entity.h"
#include "md.h"
#include "patch.h"


    .section .rodata

    .balign 2


    /**********************************************************
     * Map definition
     */
    patch_start 0x0015bc
        .dc.l   eagles_head_map_definition  // Patch map table entry
    patch_end

    eagles_head_map_definition:
        // Palette list
        .dc.l   hud_player_palette
        .dc.l   eagles_head_map_palette_0
        .dc.l   eagles_head_map_palette_1
        .dc.l   0

        // Nemesis tile data list
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(1))
        .dc.l   nem_pat_dragon
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX))
        .dc.l   nem_pat_bitter
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(HOLE_TILE_ID))
        .dc.l   nem_pat_hole
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(EAGLE_EYE_TILE_ID))
        .dc.l   nem_pat_eagle_eye
        .dc.l   0

        // Tile map data
        .dc.l   map_eagles_head_foreground_blocks
        .dc.l   map_eagles_head_foreground_map

        // Map dimensions
        .dc.w   map_eagles_head_block_height
        .dc.w   map_eagles_head_block_width

        // Initial scroll positions in blocks
        .dc.w   4       // Vertical
        .dc.w   0       // Horizontal

        // Event list
        .dc.l   eagles_head_event_list
        .dc.l   eagles_head_extended_event_data_table

        // Height map data
        .dc.l   map_eagles_head_height_map
        .dc.l   map_eagles_head_height_blocks

        // Entity load list
        .dc.l   eagles_head_entity_load_list

        // Player starting positions
        .dc.w   0       // Player 1 Y (Baseline relative offset)
        .dc.w   256     // Player 1 X
        .dc.w   0       // Player 2 Y (Baseline relative offset)
        .dc.w   296     // Player 2 X

        // Music id
        .dc.w   SONG_EAGLES_HEAD

    eagles_head_map_palette_0:
        entity_palette PALETTE_OFFSET(2, 1), 4, hole_4
    eagles_head_map_palette_1:
        entity_palette PALETTE_OFFSET(3, 8), 7, eagle_eye_7


    /**********************************************************
     * Patch map background tile data graphics table entry
     * This is used to reload the relevant background tiles when magic attacks that use the background plane are finished.
     */
    patch_start 0x00914c
        .dc.l   eagles_head_tile_restore_list
    patch_end

    eagles_head_tile_restore_list:
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(1))
        .dc.l   nem_pat_dragon
        .dc.l   0


    /**********************************************************
     * Y base line list
     */
    patch_start 0x00878e
        .dc.l   eagles_head_y_baseline   // Patch y base line table entry
    patch_end

    eagles_head_y_baseline:
        .dc.w   2

        .dc.w   504
        .dc.w   208

        .dc.w   1184
        .dc.w   248

        .dc.w   map_eagles_head_pixel_width
        .dc.w   208


    /**********************************************************
     * Event list
     */
    eagles_head_event_list:
        .dc.w   0
        .dc.b   MAP_EVENT_VERTICAL_SCROLL_LIMITS
        .dc.b   eagles_head_scroll_limits_0 - eagles_head_extended_event_data_table

        .dc.w   253 // EAGLE_EYE_X(573) - 320
        .dc.b   MAP_EVENT_SPAWN_ENTITY
        .dc.b   ENTITY_TYPE_EYE_BALL

        .dc.w   304
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   320
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x01

        .dc.w   704
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   736
        .dc.b   MAP_EVENT_CAMERA_TRANSITION
        .dc.b   eagles_head_camera_transition_1 - eagles_head_extended_event_data_table

        .dc.w   804
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   952
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x02

        .dc.w   960
        .dc.b   MAP_EVENT_CHANGE_MUSIC
        .dc.b   SONG_DEATH_ADDER

        .dc.w   976
        .dc.b   MAP_EVENT_VERTICAL_SCROLL_LIMITS
        .dc.b   eagles_head_scroll_limits_2 - eagles_head_extended_event_data_table

        .dc.w   1104
        .dc.b   MAP_EVENT_CAMERA_TRANSITION
        .dc.b   eagles_head_camera_transition_3 - eagles_head_extended_event_data_table

        .dc.w   1216
        .dc.b   MAP_EVENT_NEXT_LEVEL_ON_ENEMY_DEFEAT
        .dc.b   0x00

        .dc.w   1280
        .dc.b   MAP_EVENT_NOTHING
        .dc.b   0x00

    eagles_head_extended_event_data_table:
        eagles_head_scroll_limits_0:        .dc.l   eagles_head_scroll_limits_0_param
        eagles_head_camera_transition_1:    .dc.l   eagles_head_camera_transition_1_param
        eagles_head_scroll_limits_2:        .dc.l   eagles_head_scroll_limits_2_param
        eagles_head_camera_transition_3:    .dc.l   eagles_head_camera_transition_3_param

    eagles_head_scroll_limits_0_param:
        .dc.w   40                  // Min y scroll
        .dc.w   424 - 224           // Max y scroll

    eagles_head_camera_transition_1_param:
        .dc.w   392 - 224           // Min y scroll
        .dc.w   392 - 224           // Max y scroll
        .dc.l   0x00010000          // Camera y decrement (16.16)
        .dc.l   0x00000000          // Camera x increment (16.16)

    eagles_head_scroll_limits_2_param:
        .dc.w   96                  // Min y scroll
        .dc.w   392 - 224           // Max y scroll

    eagles_head_camera_transition_3_param:
        .dc.w   96                  // Min y scroll
        .dc.w   392 - 224           // Max y scroll
        .dc.l   0x00000000          // Camera y decrement (16.16)
        .dc.l   0x00010000          // Camera x increment (16.16)


    /**********************************************************
     * Entity load list
     */
    eagles_head_entity_load_list:
        .dc.w   48
        .dc.l   eagles_head_map_entity_load_slot_descriptor_0

        .dc.w   200
        .dc.l   eagles_head_map_entity_load_slot_descriptor_1

        .dc.w   472
        .dc.l   eagles_head_map_entity_load_slot_descriptor_2

        .dc.w   704
        .dc.l   eagles_head_map_entity_load_slot_descriptor_3

        .dc.w   804
        .dc.l   eagles_head_map_entity_load_slot_descriptor_4

        .dc.w   976
        .dc.l   eagles_head_map_entity_load_slot_descriptor_5

        .dc.w   1104
        .dc.l   eagles_head_map_entity_load_slot_descriptor_6

        .dc.w   -1

    eagles_head_map_entity_load_slot_descriptor_0:
        .dc.w   0
        .dc.l   eagles_head_map_entity_load_group_descriptor_0_0

        eagles_head_map_entity_load_group_descriptor_0_0:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 0, ENTITY_TYPE_SKELETON_2_FROM_HOLE, 232, 184
                map_entity_definition 1, ENTITY_TYPE_SKELETON_2_FROM_HOLE, 176, 120

    eagles_head_map_entity_load_slot_descriptor_1:
        .dc.w   0
        .dc.l   eagles_head_map_entity_load_group_descriptor_1_0

        eagles_head_map_entity_load_group_descriptor_1_0:
            .dc.w   1   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 2, ENTITY_TYPE_SKELETON_2_FROM_HOLE, 192, 240

    eagles_head_map_entity_load_slot_descriptor_2:
        .dc.w   0
        .dc.l   eagles_head_map_entity_load_group_descriptor_2_0

        eagles_head_map_entity_load_group_descriptor_2_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   eagles_head_map_entity_load_group_descriptor_2_0_pal0
            .dc.l   eagles_head_map_entity_load_group_descriptor_2_0_pal1
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 0, ENTITY_TYPE_AMAZON_5, 248, 320
                map_entity_definition 6, ENTITY_TYPE_BLUE_DRAGON, 248, 320, 1

            eagles_head_map_entity_load_group_descriptor_2_0_pal0:
                entity_palette PALETTE_OFFSET(1, 1), 11, red1_4, yellow_3, skin_4
            eagles_head_map_entity_load_group_descriptor_2_0_pal1:
                entity_palette PALETTE_OFFSET(3, 1), 7, blue1_4, yellow_3

    eagles_head_map_entity_load_slot_descriptor_3:
        .dc.w   0
        .dc.l   eagles_head_map_entity_load_group_descriptor_3_0

        eagles_head_map_entity_load_group_descriptor_3_0:
            .dc.w   1   // load allowed when there are active enemies?

            .dc.l   eagles_head_map_entity_load_group_descriptor_3_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 1, ENTITY_TYPE_HENINGER_RED, 232, 320

            eagles_head_map_entity_load_group_descriptor_3_0_pal0:
                entity_palette PALETTE_OFFSET(1, 8), 8, skin_4, red2_4

    eagles_head_map_entity_load_slot_descriptor_4:
        .dc.w   1
        .dc.l   eagles_head_map_entity_load_group_descriptor_4_0
        .dc.l   eagles_head_map_entity_load_group_descriptor_4_1

        eagles_head_map_entity_load_group_descriptor_4_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   eagles_head_map_entity_load_group_descriptor_4_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   4  // number of entities
                map_entity_definition 0, ENTITY_TYPE_LONGMOAN_RED, 240, 308
                map_entity_definition 1, ENTITY_TYPE_LONGMOAN_RED, 216, 316
                map_entity_definition 2, ENTITY_TYPE_HENINGER_RED, 264, 308
                map_entity_definition 3, ENTITY_TYPE_HENINGER_RED, 200, 356

            eagles_head_map_entity_load_group_descriptor_4_0_pal0:
                    entity_palette PALETTE_OFFSET(1, 1), 15, black_4, yellow_3, skin_4, red2_4

        eagles_head_map_entity_load_group_descriptor_4_1:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   eagles_head_map_entity_load_group_descriptor_4_1_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 0, ENTITY_TYPE_BITTER_RED, 232, 332, GAME_PLAY_VRAM_RESERVED_TILE_MAX
                map_entity_definition 1, ENTITY_TYPE_BITTER_RED, 264, 340, GAME_PLAY_VRAM_RESERVED_TILE_MAX

            eagles_head_map_entity_load_group_descriptor_4_1_pal0:
                    entity_palette PALETTE_OFFSET(1, 12), 4, red3_4

    eagles_head_map_entity_load_slot_descriptor_5:
        .dc.w   0
        .dc.l   eagles_head_map_entity_load_group_descriptor_5_0

        eagles_head_map_entity_load_group_descriptor_5_0:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0

            .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX))
            .dc.l   nem_pat_bad_brother // Pre-load
            .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX + BAD_BROTHER_TILE_COUNT))
            .dc.l   nem_pat_thief
            .dc.l   0

            .dc.w   3  // number of entities
                map_entity_definition 3, ENTITY_TYPE_THIEF, 192, 360, GAME_PLAY_VRAM_RESERVED_TILE_MAX + BAD_BROTHER_TILE_COUNT, ENTITY_TYPE_THIEF_BLUE_PARAM(3)
                map_entity_definition 4, ENTITY_TYPE_THIEF, 224, 334, GAME_PLAY_VRAM_RESERVED_TILE_MAX + BAD_BROTHER_TILE_COUNT, ENTITY_TYPE_THIEF_BLUE_PARAM(3)
                map_entity_definition 5, ENTITY_TYPE_THIEF, 260, 320, GAME_PLAY_VRAM_RESERVED_TILE_MAX + BAD_BROTHER_TILE_COUNT, ENTITY_TYPE_THIEF_BLUE_PARAM(2)

    eagles_head_map_entity_load_slot_descriptor_6:
        .dc.w   1
        .dc.l   eagles_head_map_entity_load_group_descriptor_6_0
        .dc.l   eagles_head_map_entity_load_group_descriptor_6_1

        eagles_head_map_entity_load_group_descriptor_6_0:
            .dc.w   1   // load allowed when there are active enemies?

            .dc.l   eagles_head_map_entity_load_group_descriptor_6_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   3  // number of entities
                map_entity_definition 0, ENTITY_TYPE_BAD_BROTHER_RED, 216, 376, GAME_PLAY_VRAM_RESERVED_TILE_MAX
                map_entity_definition 1, ENTITY_TYPE_HENINGER_RED, 224, 376
                map_entity_definition 2, ENTITY_TYPE_LONGMOAN_RED, 248, 368

            eagles_head_map_entity_load_group_descriptor_6_0_pal0:
                    entity_palette PALETTE_OFFSET(1, 8), 8, skin_4, red2_4

        eagles_head_map_entity_load_group_descriptor_6_1:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0

            // Death adder special attacks graphics
            .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX + BAD_BROTHER_TILE_COUNT))
            .dc.l   nem_pat_death_adder
            .dc.l   VRAM_ADDR_SET(TILE_ADDR(DEATH_ADDER_SPECIAL_TILE_ID))
            .dc.l   nem_pat_death_adder_special
            .dc.l   VRAM_ADDR_SET(GAME_PLAY_VRAM_RESERVED_MIN)              // Fixed address
            .dc.l   nem_pat_death_adder_special_explosion
            .dc.l   0

            .dc.w   3  // number of entities
                map_entity_definition 0, ENTITY_TYPE_SKELETON_3,  168, -32
                map_entity_definition 1, ENTITY_TYPE_SKELETON_3,  246, -16
                map_entity_definition 2, ENTITY_TYPE_DEATH_BRINGER, 176, 320 / 2, GAME_PLAY_VRAM_RESERVED_TILE_MAX

