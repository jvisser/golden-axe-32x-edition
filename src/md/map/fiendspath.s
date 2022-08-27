/*
 * Fiend's path patches
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
    patch_start 0x0015b8
        .dc.l   fiends_path_map_definition  // Patch map table entry
    patch_end

    fiends_path_map_definition:
        // Palette list
        .dc.l   hud_player_palette
        .dc.l   fiends_path_map_palette_0
        .dc.l   0

        // Nemesis tile data list
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(HOLE_TILE_ID))
        .dc.l   nem_pat_hole
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(HOLE_TILE_ID + HOLE_TILE_COUNT))
        .dc.l   nem_pat_thief
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX))
        .dc.l   nem_pat_feather
        .dc.l   0

        // Tile map data
        .dc.l   map_fiends_path_foreground_blocks
        .dc.l   map_fiends_path_foreground_map

        // Map dimensions
        .dc.w   map_fiends_path_block_height
        .dc.w   map_fiends_path_block_width

        // Initial scroll positions in blocks
        .dc.w   13      // Vertical
        .dc.w   0       // Horizontal

        // Event list
        .dc.l   fiends_path_event_list
        .dc.l   fiends_path_extended_event_data_table

        // Height map data
        .dc.l   map_fiends_path_height_map
        .dc.l   map_fiends_path_height_blocks

        // Entity load list
        .dc.l   fiends_path_entity_load_list

        // Player starting positions
        .dc.w   0       // Player 1 Y (Baseline relative offset)
        .dc.w   248     // Player 1 X
        .dc.w   0       // Player 2 Y (Baseline relative offset)
        .dc.w   288     // Player 2 X

        // Music id
        .dc.w   SONG_FIENDS_PATH

    fiends_path_map_palette_0:
        entity_palette PALETTE_OFFSET(3, 11), 5, feather_5


    /**********************************************************
     * Patch map background tile data graphics table entry
     * This is used to reload the relevant background tiles when magic attacks that use the background plane are finished.
     */
    patch_start 0x009148
        .dc.l   fiends_path_tile_restore_list
    patch_end

    fiends_path_tile_restore_list:
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   0


    /**********************************************************
     * Y base line list
     */
    patch_start 0x00878a
        .dc.l   fiends_path_y_baseline   // Patch y base line table entry
    patch_end

    fiends_path_y_baseline:
        .dc.w   3

        .dc.w   320
        .dc.w   352

        .dc.w   352
        .dc.w   384

        .dc.w   896
        .dc.w   408

        .dc.w   map_fiends_path_pixel_width
        .dc.w   392


    /**********************************************************
     * Event list
     */
    fiends_path_event_list:
        .dc.w   0
        .dc.b   MAP_EVENT_VERTICAL_SCROLL_LIMITS
        .dc.b   fiends_path_village_scroll_limits_0 - fiends_path_extended_event_data_table

        .dc.w   256
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   384
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x01

        .dc.w   576
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   656
        .dc.b   MAP_EVENT_VERTICAL_SCROLL_LIMITS
        .dc.b   fiends_path_village_scroll_limits_1 - fiends_path_extended_event_data_table

        .dc.w   767
        .dc.b   MAP_EVENT_START_FEATHER_ANIMATION
        .dc.b   0

        .dc.w   768
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   944
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x02

        .dc.w   1008
        .dc.b   MAP_EVENT_CHANGE_MUSIC
        .dc.b   SONG_BOSS

        .dc.w   1104
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   1216
        .dc.b   MAP_EVENT_CAMPSITE_ON_ENEMY_DEFEAT
        .dc.b   0x00

        .dc.w   1280
        .dc.b   MAP_EVENT_NOTHING
        .dc.b   0x00

    fiends_path_extended_event_data_table:
        fiends_path_village_scroll_limits_0:    .dc.l   fiends_path_scroll_limits_0_param
        fiends_path_village_scroll_limits_1:    .dc.l   fiends_path_scroll_limits_1_param

    fiends_path_scroll_limits_0_param:
        .dc.w   176                 // Min y scroll
        .dc.w   432 - 224           // Max y scroll

    fiends_path_scroll_limits_1_param:
        .dc.w   0                   // Min y scroll
        .dc.w   512 - 224           // Max y scroll

    /**********************************************************
     * Entity load list
     */
    fiends_path_entity_load_list:
        .dc.w   0
        .dc.l   fiends_path_map_entity_load_slot_descriptor_0

        .dc.w   192
        .dc.l   fiends_path_map_entity_load_slot_descriptor_1

        .dc.w   576
        .dc.l   fiends_path_map_entity_load_slot_descriptor_2

        .dc.w   660
        .dc.l   fiends_path_map_entity_load_slot_descriptor_3

        .dc.w   768
        .dc.l   fiends_path_map_entity_load_slot_descriptor_4

        .dc.w   824
        .dc.l   fiends_path_map_entity_load_slot_descriptor_5

        .dc.w   996
        .dc.l   fiends_path_map_entity_load_slot_descriptor_6

        .dc.w   1104
        .dc.l   fiends_path_map_entity_load_slot_descriptor_7

        .dc.w   1216
        .dc.l   fiends_path_map_entity_load_slot_descriptor_8

        .dc.w   -1  // Terminate

    fiends_path_map_entity_load_slot_descriptor_0:
        .dc.w   0
        .dc.l   fiends_path_map_entity_load_group_descriptor_0_0

        fiends_path_map_entity_load_group_descriptor_0_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   fiends_path_map_entity_load_group_descriptor_0_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 0, ENTITY_TYPE_HENINGER_RED, 376, 330

            fiends_path_map_entity_load_group_descriptor_0_0_pal0:
                entity_palette PALETTE_OFFSET(1, 0), 16, black_8, skin_4, red2_4

    fiends_path_map_entity_load_slot_descriptor_1:
        .dc.w   0
        .dc.l   fiends_path_map_entity_load_group_descriptor_1_0

        fiends_path_map_entity_load_group_descriptor_1_0:
            .dc.w   1   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 1, ENTITY_TYPE_LONGMOAN_RED, 392, -30
                map_entity_definition 2, ENTITY_TYPE_HENINGER_RED, 416, -50

    fiends_path_map_entity_load_slot_descriptor_2:
        .dc.w   0
        .dc.l   fiends_path_map_entity_load_group_descriptor_2_0

        fiends_path_map_entity_load_group_descriptor_2_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   fiends_path_map_entity_load_group_descriptor_2_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 0, ENTITY_TYPE_SKELETON_2_FROM_HOLE, 424, 112

            fiends_path_map_entity_load_group_descriptor_2_0_pal0:
                entity_palette PALETTE_OFFSET(2, 1), 4, hole_4

    fiends_path_map_entity_load_slot_descriptor_3:
        .dc.w   0
        .dc.l   fiends_path_map_entity_load_group_descriptor_3_0

        fiends_path_map_entity_load_group_descriptor_3_0:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 0, ENTITY_TYPE_SKELETON_2_FROM_HOLE, 400, 132

    fiends_path_map_entity_load_slot_descriptor_4:
        .dc.w   0
        .dc.l   fiends_path_map_entity_load_group_descriptor_4_0

        fiends_path_map_entity_load_group_descriptor_4_0:
            .dc.w   1   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 1, ENTITY_TYPE_SKELETON_2_FROM_HOLE, 432, 200

    fiends_path_map_entity_load_slot_descriptor_5:
        .dc.w   0
        .dc.l   fiends_path_map_entity_load_group_descriptor_5_0

        fiends_path_map_entity_load_group_descriptor_5_0:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 5, ENTITY_TYPE_THIEF, 384, 330, HOLE_TILE_ID + HOLE_TILE_COUNT, ENTITY_TYPE_THIEF_BLUE_PARAM(2)

    fiends_path_map_entity_load_slot_descriptor_6:
        .dc.w   0
        .dc.l   fiends_path_map_entity_load_group_descriptor_6_0

        fiends_path_map_entity_load_group_descriptor_6_0:
            .dc.w   1   // load allowed when there are active enemies?

            .dc.l   fiends_path_map_entity_load_group_descriptor_6_0_pal0
            .dc.l   0
            .dc.l   0
            .dc.w   1  // number of entities
                map_entity_definition 0, ENTITY_TYPE_LONGMOAN_DARK, 400, 220

            fiends_path_map_entity_load_group_descriptor_6_0_pal0:
                entity_palette PALETTE_OFFSET(1, 8), 8, dark_4, dark_4

    fiends_path_map_entity_load_slot_descriptor_7:
        .dc.w   0
        .dc.l   fiends_path_map_entity_load_group_descriptor_7_0

        fiends_path_map_entity_load_group_descriptor_7_0:
            .dc.w   1   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 1, ENTITY_TYPE_HENINGER_DARK, 392, 244
                map_entity_definition 2, ENTITY_TYPE_HENINGER_DARK, 416, 228

    fiends_path_map_entity_load_slot_descriptor_8:
        .dc.w   1
        .dc.l   fiends_path_map_entity_load_group_descriptor_8_0
        .dc.l   fiends_path_map_entity_load_group_descriptor_8_1

        fiends_path_map_entity_load_group_descriptor_8_0:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   3  // number of entities
                map_entity_definition 0, ENTITY_TYPE_LONGMOAN_DARK, 392, 244
                map_entity_definition 1, ENTITY_TYPE_SKELETON_2_FROM_HOLE, 364, 182
                map_entity_definition 2, ENTITY_TYPE_SKELETON_2_FROM_HOLE, 424, 56

        fiends_path_map_entity_load_group_descriptor_8_1:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   3  // number of entities
                map_entity_definition 0, ENTITY_TYPE_LONGMOAN_DARK, 364, 86
                map_entity_definition 1, ENTITY_TYPE_HENINGER_DARK, 392, 176
                map_entity_definition 2, ENTITY_TYPE_SKELETON_2_FROM_HOLE, 432, 264


    /**********************************************************
     * Camp site
     */

    // Camp site vertical scroll
    patch_start 0x002a8c
        .dc.w   392 - (24 * 8) - 224/2
    patch_end

    // Camp site entity load group descriptor (thiefs)
    patch_start 0x002b28
        .dc.l   fiends_path_camp_map_entity_load_group_descriptor   // Patch table entry
    patch_end

    fiends_path_camp_map_entity_load_group_descriptor:
        .dc.w   0   // Load allowed when there are active enemies?

        .dc.l   fiends_path_map_camp_pal
        .dc.l   0   // Palette list
        .dc.l   0   // Nemesis tile data list
        .dc.w   2   // Number of entities
            map_entity_definition 0, ENTITY_TYPE_THIEF, 352, 32, 0x3A3, ENTITY_TYPE_THIEF_GREEN_PARAM(1)
            map_entity_definition 1, ENTITY_TYPE_THIEF, 352, 96, 0x3A3, ENTITY_TYPE_THIEF_BLUE_PARAM(3) | 0x8000

        fiends_path_map_camp_pal:
            entity_palette PALETTE_OFFSET(2, 1), 4, hole_4
