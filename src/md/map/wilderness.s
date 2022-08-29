/*
 * Wilderness patches
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
    patch_start 0x0015ac
        .dc.l   wilderness_map_definition   // Patch map table entry
    patch_end

    #define CHICKEN_LEG_TILE_ID     1
    #define BAD_BROTHER_TILE_ID     0x0200      // After intro text
    #define THIEF_TILE_ID           BAD_BROTHER_TILE_ID + BAD_BROTHER_TILE_COUNT
    #define VILLAGER_TILE_ID        THIEF_TILE_ID + THIEF_TILE_COUNT

    wilderness_map_definition:
        // Palette list
        .dc.l   hud_player_palette
        .dc.l   0

        // Nemesis tile data list
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(CHICKEN_LEG_TILE_ID))
        .dc.l   nem_pat_chicken_leg
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(BAD_BROTHER_TILE_ID))
        .dc.l   nem_pat_bad_brother
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(THIEF_TILE_ID))
        .dc.l   nem_pat_thief
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(VILLAGER_TILE_ID))
        .dc.l   nem_pat_villager
        .dc.l   0

        // Tile map data
        .dc.l   map_wilderness_foreground_blocks
        .dc.l   map_wilderness_foreground_map

        // Map dimensions
        .dc.w   map_wilderness_block_height
        .dc.w   map_wilderness_block_width

        // Initial scroll positions in blocks
        .dc.w   0       // Vertical
        .dc.w   4       // Horizontal

        // Event list
        .dc.l   wilderness_event_list
        .dc.l   wilderness_extended_event_data_table

        // Height map data
        .dc.l   map_wilderness_height_map
        .dc.l   map_wilderness_height_blocks

        // Entity load list
        .dc.l   wilderness_entity_load_list

        // Player starting positions
        .dc.w   0       // Player 1 Y (Baseline relative offset)
        .dc.w   112     // Player 1 X
        .dc.w   16      // Player 2 Y (Baseline relative offset)
        .dc.w   80      // Player 2 X

        // Music id
        .dc.w   SONG_WILDERNESS


    /**********************************************************
     * Patch map background tile data graphics table entry
     * This is used to reload the relevant background tiles when magic attacks that use the background plane are finished.
     */
    patch_start 0x00913c
        .dc.l   wilderness_tile_restore_list
    patch_end

    wilderness_tile_restore_list:
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   0


    /**********************************************************
     * Y base line list
     */
    patch_start 0x00877e
        .dc.l   wilderness_y_baseline   // Patch y base line table entry
    patch_end

    wilderness_y_baseline:
        .dc.w   0x0000

        .dc.w   map_wilderness_pixel_width
        .dc.w   188


    /**********************************************************
     * Event list
     */
    wilderness_event_list:
        .dc.w   224
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   320
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x01

        .dc.w   356
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   536
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   768
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   888
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   952
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x02

        .dc.w   960
        .dc.b   MAP_EVENT_CHANGE_MUSIC
        .dc.b   SONG_BOSS

        .dc.w   1104
        .dc.b   MAP_EVENT_CAMERA_TRANSITION
        .dc.b   wilderness_camera_transition_0 - wilderness_extended_event_data_table

        .dc.w   1216
        .dc.b   MAP_EVENT_CAMPSITE_ON_ENEMY_DEFEAT
        .dc.b   0x00

        .dc.w   1280
        .dc.b   MAP_EVENT_NOTHING
        .dc.b   0x00

    wilderness_extended_event_data_table:
        wilderness_camera_transition_0:   .dc.l   wilderness_camera_transition_0_param

    wilderness_camera_transition_0_param:
        .dc.w   0                   // Min y scroll
        .dc.w   0                   // Max y scroll
        .dc.l   0x00000000          // Camera y decrement (16.16)
        .dc.l   0x00010000          // Camera x increment (16.16)

    /**********************************************************
     * Entity load list
     */
    wilderness_entity_load_list:
        .dc.w   80
        .dc.l   wilderness_map_entity_load_slot_descriptor_0

        .dc.w   168
        .dc.l   wilderness_map_entity_load_slot_descriptor_1

        .dc.w   224
        .dc.l   wilderness_map_entity_load_slot_descriptor_2

        .dc.w   296
        .dc.l   wilderness_map_entity_load_slot_descriptor_3

        .dc.w   464
        .dc.l   wilderness_map_entity_load_slot_descriptor_4

        .dc.w   704
        .dc.l   wilderness_map_entity_load_slot_descriptor_5

        .dc.w   816
        .dc.l   wilderness_map_entity_load_slot_descriptor_6

        .dc.w   976
        .dc.l   wilderness_map_entity_load_slot_descriptor_7

        .dc.w   1104
        .dc.l   wilderness_map_entity_load_slot_descriptor_8

        .dc.w   -1  // Terminate

    wilderness_map_entity_load_slot_descriptor_0:
        .dc.w   0
        .dc.l   wilderness_map_entity_load_group_descriptor_0_0

        wilderness_map_entity_load_group_descriptor_0_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   wilderness_map_entity_load_group_descriptor_0_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 0, ENTITY_TYPE_LONGMOAN_SILVER, 152, 330

            wilderness_map_entity_load_group_descriptor_0_0_pal0:
                entity_palette PALETTE_OFFSET(1, 0), 16, black_8, skin_4, silver_4

    wilderness_map_entity_load_slot_descriptor_1:
        .dc.w   0
        .dc.l   wilderness_map_entity_load_group_descriptor_1_0

        wilderness_map_entity_load_group_descriptor_1_0:
            .dc.w   1   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 1, ENTITY_TYPE_HENINGER_SILVER, 160, 330

    wilderness_map_entity_load_slot_descriptor_2:
        .dc.w   0
        .dc.l   wilderness_map_entity_load_group_descriptor_2_0

        wilderness_map_entity_load_group_descriptor_2_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   wilderness_map_entity_load_group_descriptor_2_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 0, ENTITY_TYPE_LONGMOAN_SILVER, 152, 330
                map_entity_definition 1, ENTITY_TYPE_HENINGER_PURPLE, 200, 330

            wilderness_map_entity_load_group_descriptor_2_0_pal0:
                entity_palette PALETTE_OFFSET(1, 12), 4, purple2_4

    wilderness_map_entity_load_slot_descriptor_3:
        .dc.w   0
        .dc.l   wilderness_map_entity_load_group_descriptor_3_0

        wilderness_map_entity_load_group_descriptor_3_0:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 0, ENTITY_TYPE_THIEF, 148, 330, THIEF_TILE_ID, ENTITY_TYPE_THIEF_BLUE_PARAM(2)

    wilderness_map_entity_load_slot_descriptor_4:
        .dc.w   0
        .dc.l   wilderness_map_entity_load_group_descriptor_4_0

        wilderness_map_entity_load_group_descriptor_4_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   wilderness_map_entity_load_group_descriptor_4_0_pal0
            .dc.l   wilderness_map_entity_load_group_descriptor_4_0_pal1
            .dc.l   0
            .dc.l   0

            .dc.w   4  // number of entities
                map_entity_definition 0, ENTITY_TYPE_LONGMOAN_SILVER, 184, 330
                map_entity_definition 1, ENTITY_TYPE_AMAZON_5, 136, 372
                map_entity_definition 5, ENTITY_TYPE_VILLAGER_2, 184, 330, VILLAGER_TILE_ID, 0xd000
                map_entity_definition 6, ENTITY_TYPE_CHICKEN_LEG, 136, 372, CHICKEN_LEG_TILE_ID

            wilderness_map_entity_load_group_descriptor_4_0_pal0:
                entity_palette PALETTE_OFFSET(1, 1), 15, green2_4, yellow_3, skin_4, silver_4

            wilderness_map_entity_load_group_descriptor_4_0_pal1:
                entity_palette PALETTE_OFFSET(2, 5), 6, yellow_3, purple_3

    wilderness_map_entity_load_slot_descriptor_5:
        .dc.w   0
        .dc.l   wilderness_map_entity_load_group_descriptor_5_0

        wilderness_map_entity_load_group_descriptor_5_0:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 0, ENTITY_TYPE_THIEF, 128, 340, THIEF_TILE_ID, ENTITY_TYPE_THIEF_BLUE_PARAM(1)
                map_entity_definition 1, ENTITY_TYPE_THIEF, 168, 330, THIEF_TILE_ID, ENTITY_TYPE_THIEF_BLUE_PARAM(2)

    wilderness_map_entity_load_slot_descriptor_6:
        .dc.w   0
        .dc.l   wilderness_map_entity_load_group_descriptor_6_0

        wilderness_map_entity_load_group_descriptor_6_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   wilderness_map_entity_load_group_descriptor_6_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 1, ENTITY_TYPE_LONGMOAN_SILVER, 152, 330

            wilderness_map_entity_load_group_descriptor_6_0_pal0:
                entity_palette PALETTE_OFFSET(1, 1), 15, black_4, yellow_3, skin_4, silver_4

    wilderness_map_entity_load_slot_descriptor_7:
        .dc.w   0
        .dc.l   wilderness_map_entity_load_group_descriptor_7_0

        wilderness_map_entity_load_group_descriptor_7_0:
            .dc.w   1   // load allowed when there are active enemies?

            .dc.l   wilderness_map_entity_load_group_descriptor_7_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 0, ENTITY_TYPE_VILLAGER_1, 184, 330, VILLAGER_TILE_ID, 0xd000
                map_entity_definition 1, ENTITY_TYPE_VILLAGER_2, 208, 330, VILLAGER_TILE_ID, 0xc300

            wilderness_map_entity_load_group_descriptor_7_0_pal0:
                entity_palette PALETTE_OFFSET(1, 8), 8, skin_4, green_4

    wilderness_map_entity_load_slot_descriptor_8:
        .dc.w   0
        .dc.l   wilderness_map_entity_load_group_descriptor_8_0

        wilderness_map_entity_load_group_descriptor_8_0:
            .dc.w   1   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   5  // number of entities
                map_entity_definition 2, ENTITY_TYPE_HENINGER_RED, 140, 330
                map_entity_definition 3, ENTITY_TYPE_LONGMOAN_GREEN, 208, 330
                map_entity_definition 4, ENTITY_TYPE_BAD_BROTHER_GREEN, 136, 350, BAD_BROTHER_TILE_ID
                map_entity_definition 5, ENTITY_TYPE_BAD_BROTHER_GREEN, 168, 370, BAD_BROTHER_TILE_ID
                map_entity_definition 7, ENTITY_TYPE_CHICKEN_LEG, 208, 372, CHICKEN_LEG_TILE_ID


    /**********************************************************
     * Camp site
     */

    // Camp site vertical scroll
    patch_start 0x002a86
        .dc.w   0
    patch_end

    // Camp site entity load group descriptor (thiefs)
    patch_start 0x002b1c
        .dc.l   wilderness_camp_map_entity_load_group_descriptor   // Patch table entry
    patch_end

    wilderness_camp_map_entity_load_group_descriptor:
        .dc.w   0   // Load allowed when there are active enemies?
        .dc.l   0   // Palette list
        .dc.l   0   // Nemesis tile data list
        .dc.w   1   // Number of entities
            map_entity_definition 0, ENTITY_TYPE_THIEF, 176, 96, 0x3A3, ENTITY_TYPE_THIEF_BLUE_PARAM(2) | 0x8000
