/*
 * Town patches
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
    patch_start 0x0015b4
        .dc.l   town_map_definition   // Patch map table entry
    patch_end

    town_map_definition:
        // Palette list
        .dc.l   hud_player_palette
        .dc.l   town_palette
        .dc.l   0

        // Nemesis tile data list
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(TOWNDOOR_TILE_ID))
        .dc.l   nem_pat_towndoor_1
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT))
        .dc.l   nem_pat_towndoor_2
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT))
        .dc.l   nem_pat_thief
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT + THIEF_TILE_COUNT))
        .dc.l   nem_pat_villager
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX))
        .dc.l   nem_pat_bad_brother
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX + BAD_BROTHER_TILE_COUNT))
        .dc.l   nem_pat_dragon
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(TURTLE_EYE_TILE_ID))
        .dc.l   nem_pat_turtle_eye
        .dc.l   0

        // Tile map data
        .dc.l   map_town_foreground_blocks
        .dc.l   map_town_foreground_map

        // Map dimensions
        .dc.w   map_town_block_height
        .dc.w   map_town_block_width

        // Initial scroll positions in blocks
        .dc.w   6       // Vertical
        .dc.w   0       // Horizontal

        // Event list
        .dc.l   town_event_list
        .dc.l   town_extended_event_data_table

        // Height map data
        .dc.l   map_town_height_map
        .dc.l   map_town_height_blocks

        // Entity load list
        .dc.l   town_entity_load_list

        // Player starting positions
        .dc.w   0       // Player 1 Y (Baseline relative offset)
        .dc.w   256     // Player 1 X
        .dc.w   0       // Player 2 Y (Baseline relative offset)
        .dc.w   296     // Player 2 X

        // Music id
        .dc.w   SONG_TOWN

    town_palette:
        entity_palette PALETTE_OFFSET(3, 1), 13, blue1_4, yellow_3, turtle_eye_6


    /**********************************************************
     * Patch map background tile data graphics table entry
     * This is used to reload the relevant background tiles when magic attacks that use the background plane are finished.
     */
    patch_start 0x009144
        .dc.l   town_tile_restore_list
    patch_end

    town_tile_restore_list:
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   0


    /**********************************************************
     * Y base line list
     */
    patch_start 0x008786
        .dc.l   town_y_baseline   // Patch y base line table entry
    patch_end

    town_y_baseline:
        .dc.w   3

        .dc.w   408
        .dc.w   240

        .dc.w   576
        .dc.w   216

        .dc.w   1248
        .dc.w   232

        .dc.w   map_town_pixel_width
        .dc.w   176


    /**********************************************************
     * Event list
     */
    town_event_list:
        .dc.w   0
        .dc.b   MAP_EVENT_VERTICAL_SCROLL_LIMITS
        .dc.b   town_scroll_limits_0 - town_extended_event_data_table

        .dc.w   8
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   48
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   88
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   320
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x01

        .dc.w   354 // TURTLE_EYE_X(674) - 320
        .dc.b   MAP_EVENT_SPAWN_ENTITY
        .dc.b   ENTITY_TYPE_EYE_BALL

        .dc.w   384
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   600
        .dc.b   MAP_EVENT_CAMERA_TRANSITION
        .dc.b   town_camera_transition_1 - town_extended_event_data_table

        .dc.w   814
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   820
        .dc.b   MAP_EVENT_VERTICAL_SCROLL_LIMITS
        .dc.b   town_scroll_limits_2 - town_extended_event_data_table

        .dc.w   848
        .dc.b   MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT
        .dc.b   0

        .dc.w   1040
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x02

        .dc.w   1048
        .dc.b   MAP_EVENT_CHANGE_MUSIC
        .dc.b   SONG_BOSS

        .dc.w   1104
        .dc.b   MAP_EVENT_CAMERA_TRANSITION
        .dc.b   town_camera_transition_3 - town_extended_event_data_table

        .dc.w   1216
        .dc.b   MAP_EVENT_CAMPSITE_ON_ENEMY_DEFEAT
        .dc.b   0x00

        .dc.w   1280
        .dc.b   MAP_EVENT_NOTHING
        .dc.b   0x00

    town_extended_event_data_table:
        town_scroll_limits_0:       .dc.l   town_scroll_limits_0_param
        town_camera_transition_1:   .dc.l   town_camera_transition_1_param
        town_scroll_limits_2:       .dc.l   town_scroll_limits_2_param
        town_camera_transition_3:   .dc.l   town_camera_transition_3_param

    town_scroll_limits_0_param:
        .dc.w   104                 // Min y scroll
        .dc.w   512 - 224           // Max y scroll

    town_camera_transition_1_param:
        .dc.w   256 - 224           // Min y scroll
        .dc.w   256 - 224           // Max y scroll
        .dc.l   0x00007fff          // Camera y decrement (16.16)
        .dc.l   0x00000000          // Camera x increment (16.16)

    town_scroll_limits_2_param:
        .dc.w   0                   // Min y scroll
        .dc.w   256 - 224           // Max y scroll

    town_camera_transition_3_param:
        .dc.w   0                   // Min y scroll
        .dc.w   256 - 224           // Max y scroll
        .dc.l   0x00000000          // Camera y decrement (16.16)
        .dc.l   0x00010000          // Camera x increment (16.16)

    /**********************************************************
     * Entity load list (Arcade mode)
     */
    town_entity_load_list:
        .dc.w   8
        .dc.l   town_map_entity_load_slot_descriptor_0

        .dc.w   48
        .dc.l   town_map_entity_load_slot_descriptor_1

        .dc.w   56
        .dc.l   town_map_entity_load_slot_descriptor_2

        .dc.w   272
        .dc.l   town_map_entity_load_slot_descriptor_3

        .dc.w   800
        .dc.l   town_map_entity_load_slot_descriptor_4

        .dc.w   848
        .dc.l   town_map_entity_load_slot_descriptor_5

        .dc.w   896
        .dc.l   town_map_entity_load_slot_descriptor_6

        .dc.w   1104
        .dc.l   town_map_entity_load_slot_descriptor_7

        .dc.w   1216
        .dc.l   town_map_entity_load_slot_descriptor_8

        .dc.w   -1

    town_map_entity_load_slot_descriptor_0:
        .dc.w   0
        .dc.l   town_map_entity_load_group_descriptor_0_0

        town_map_entity_load_group_descriptor_0_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   town_map_entity_load_group_descriptor_0_0_pal0
            .dc.l   town_map_entity_load_group_descriptor_0_0_pal1
            .dc.l   0
            .dc.l   0

            .dc.w   3  // number of entities
                map_entity_definition 0, ENTITY_TYPE_LONGMOAN_SILVER, 296, 330
                map_entity_definition 1, ENTITY_TYPE_LONGMOAN_SILVER, 240, 350
                map_entity_definition 6, ENTITY_TYPE_RED_DRAGON, 240, 350, GAME_PLAY_VRAM_RESERVED_TILE_MAX + BAD_BROTHER_TILE_COUNT

        town_map_entity_load_group_descriptor_0_0_pal0:
            entity_palette PALETTE_OFFSET(1, 1), 15, red1_4, yellow_3, skin_4, silver_4
        town_map_entity_load_group_descriptor_0_0_pal1:
            entity_palette PALETTE_OFFSET(2, 11), 5, flame_5

    town_map_entity_load_slot_descriptor_1:
        .dc.w   0
        .dc.l   town_map_entity_load_group_descriptor_1_0

        town_map_entity_load_group_descriptor_1_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   town_map_entity_load_group_descriptor_1_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   3  // number of entities
                map_entity_definition 0, ENTITY_TYPE_HENINGER_RED, 192, 350
                map_entity_definition 1, ENTITY_TYPE_LONGMOAN_SILVER, 256, -30
                map_entity_definition 7, ENTITY_TYPE_BLUE_DRAGON, 192, 350, GAME_PLAY_VRAM_RESERVED_TILE_MAX + BAD_BROTHER_TILE_COUNT

        town_map_entity_load_group_descriptor_1_0_pal0:
            entity_palette PALETTE_OFFSET(1, 8), 8, skin_4, silver_4

    town_map_entity_load_slot_descriptor_2:
        .dc.w   0
        .dc.l   town_map_entity_load_group_descriptor_2_0

        town_map_entity_load_group_descriptor_2_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   town_map_entity_load_group_descriptor_2_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   3  // number of entities
                map_entity_definition 0, ENTITY_TYPE_HENINGER_GOLD, 192, 350
                map_entity_definition 1, ENTITY_TYPE_LONGMOAN_PURPLE, 208, 330
                map_entity_definition 2, ENTITY_TYPE_AMAZON_4, 240, -30

        town_map_entity_load_group_descriptor_2_0_pal0:
            entity_palette PALETTE_OFFSET(1, 8), 8, skin_4, green_4

    town_map_entity_load_slot_descriptor_3:
        .dc.w   0
        .dc.l   town_map_entity_load_group_descriptor_3_0

        town_map_entity_load_group_descriptor_3_0:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   3  // number of entities
                map_entity_definition 0, ENTITY_TYPE_AMAZON_2, 216, 332,, 300
                map_entity_definition 1, ENTITY_TYPE_AMAZON_2, 240, 348,, 240
                map_entity_definition 2, ENTITY_TYPE_THIEF, 228, 308, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT, ENTITY_TYPE_THIEF_BLUE_PARAM(3)

    town_map_entity_load_slot_descriptor_4:
        .dc.w   0
        .dc.l   town_map_entity_load_group_descriptor_4_0

        town_map_entity_load_group_descriptor_4_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   town_map_entity_load_group_descriptor_4_0_pal0
            .dc.l   town_map_entity_load_group_descriptor_4_0_pal1
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 0, ENTITY_TYPE_BAD_BROTHER_BLUE, 208, 240, GAME_PLAY_VRAM_RESERVED_TILE_MAX
                map_entity_definition 1, ENTITY_TYPE_BAD_BROTHER_BLUE, 208, 240, GAME_PLAY_VRAM_RESERVED_TILE_MAX, 300

            town_map_entity_load_group_descriptor_4_0_pal0:
                entity_palette PALETTE_OFFSET(1, 8), 8, skin_4, blue2_4
            town_map_entity_load_group_descriptor_4_0_pal1:
                entity_palette PALETTE_OFFSET(3, 8), 8, towndoor_8

    town_map_entity_load_slot_descriptor_5:
        .dc.w   0
        .dc.l   town_map_entity_load_group_descriptor_5_0

        town_map_entity_load_group_descriptor_5_0:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX))
            .dc.l   nem_pat_bitter  // Pre-load
            .dc.l   0

            .dc.w   6  // number of entities
                map_entity_definition 0, ENTITY_TYPE_VILLAGER_1, 212, 350, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT + THIEF_TILE_COUNT, 0xd3ff
                map_entity_definition 1, ENTITY_TYPE_VILLAGER_2, 220, 334, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT + THIEF_TILE_COUNT, 0xda00
                map_entity_definition 2, ENTITY_TYPE_VILLAGER_1, 228, 348, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT + THIEF_TILE_COUNT, 0xdb00
                map_entity_definition 3, ENTITY_TYPE_VILLAGER_2, 236, 330, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT + THIEF_TILE_COUNT, 0xd900
                map_entity_definition 4, ENTITY_TYPE_VILLAGER_1, 244, 324, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT + THIEF_TILE_COUNT, 0xd6f0
                map_entity_definition 5, ENTITY_TYPE_VILLAGER_2, 252, 330, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT + THIEF_TILE_COUNT, 0xdd00

    town_map_entity_load_slot_descriptor_6:
        .dc.w   0
        .dc.l   town_map_entity_load_group_descriptor_6_0

        town_map_entity_load_group_descriptor_6_0:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 3, ENTITY_TYPE_THIEF, 228, 330, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT, ENTITY_TYPE_THIEF_BLUE_PARAM(2)
                map_entity_definition 4, ENTITY_TYPE_THIEF, 180, 320, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT, ENTITY_TYPE_THIEF_BLUE_PARAM(3)

    town_map_entity_load_slot_descriptor_7:
        .dc.w   0
        .dc.l   town_map_entity_load_group_descriptor_7_0

        town_map_entity_load_group_descriptor_7_0:
            .dc.w   1   // load allowed when there are active enemies?

            .dc.l   town_map_entity_load_group_descriptor_7_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   3  // number of entities
                map_entity_definition 0, ENTITY_TYPE_HENINGER_GOLD, 160, 350
                map_entity_definition 1, ENTITY_TYPE_HENINGER_GOLD, 188, 360
                map_entity_definition 2, ENTITY_TYPE_HENINGER_GOLD, 240, 330

            town_map_entity_load_group_descriptor_7_0_pal0:
                entity_palette PALETTE_OFFSET(1, 8), 8, skin_4, silver2_4

    town_map_entity_load_slot_descriptor_8:
        .dc.w   0
        .dc.l   town_map_entity_load_group_descriptor_8_0

        town_map_entity_load_group_descriptor_8_0:
            .dc.w   1   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 5, ENTITY_TYPE_BITTER_SILVER, 112, 160, GAME_PLAY_VRAM_RESERVED_TILE_MAX  // Only silver opens the door


    /**********************************************************
     * Entity load list (Beginner mode)
     */
    patch_start 0x0012fe
        .dc.l   town_beginner_entity_load_list
    patch_end

    town_beginner_entity_load_list:
        .dc.w   8
        .dc.l   town_map_beginner_entity_load_slot_descriptor_0

        .dc.w   48
        .dc.l   town_map_beginner_entity_load_slot_descriptor_1

        .dc.w   56
        .dc.l   town_map_beginner_entity_load_slot_descriptor_2

        .dc.w   272
        .dc.l   town_map_beginner_entity_load_slot_descriptor_3

        .dc.w   800
        .dc.l   town_map_beginner_entity_load_slot_descriptor_4

        .dc.w   848
        .dc.l   town_map_beginner_entity_load_slot_descriptor_5

        .dc.w   896
        .dc.l   town_map_beginner_entity_load_slot_descriptor_6

        .dc.w   1104
        .dc.l   town_map_beginner_entity_load_slot_descriptor_7

        .dc.w   1216
        .dc.l   town_map_beginner_entity_load_slot_descriptor_8

        .dc.w   -1


    town_map_beginner_entity_load_slot_descriptor_0:
        .dc.w   0
        .dc.l   town_map_beginner_entity_load_group_descriptor_0_0

        town_map_beginner_entity_load_group_descriptor_0_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   town_map_beginner_entity_load_group_descriptor_0_0_pal0
            .dc.l   town_map_beginner_entity_load_group_descriptor_0_0_pal1
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 0, ENTITY_TYPE_LONGMOAN_SILVER, 296, 330
                map_entity_definition 1, ENTITY_TYPE_LONGMOAN_SILVER, 240, 350

        town_map_beginner_entity_load_group_descriptor_0_0_pal0:
            entity_palette PALETTE_OFFSET(1, 1), 15, red1_4, yellow_3, skin_4, silver_4
        town_map_beginner_entity_load_group_descriptor_0_0_pal1:
            entity_palette PALETTE_OFFSET(2, 11), 5, flame_5

    town_map_beginner_entity_load_slot_descriptor_1:
        .dc.w   0
        .dc.l   town_map_beginner_entity_load_group_descriptor_1_0

        town_map_beginner_entity_load_group_descriptor_1_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   town_map_beginner_entity_load_group_descriptor_1_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 0, ENTITY_TYPE_HENINGER_RED, 192, 350
                map_entity_definition 1, ENTITY_TYPE_LONGMOAN_SILVER, 256, -30

        town_map_beginner_entity_load_group_descriptor_1_0_pal0:
            entity_palette PALETTE_OFFSET(1, 8), 8, skin_4, silver_4

    town_map_beginner_entity_load_slot_descriptor_2:
        .dc.w   0
        .dc.l   town_map_beginner_entity_load_group_descriptor_2_0

        town_map_beginner_entity_load_group_descriptor_2_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   town_map_beginner_entity_load_group_descriptor_2_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   3  // number of entities
                map_entity_definition 0, ENTITY_TYPE_HENINGER_GOLD, 192, 350
                map_entity_definition 1, ENTITY_TYPE_LONGMOAN_PURPLE, 208, 330
                map_entity_definition 2, ENTITY_TYPE_AMAZON_4, 240, -30

        town_map_beginner_entity_load_group_descriptor_2_0_pal0:
            entity_palette PALETTE_OFFSET(1, 8), 8, skin_4, green_4

    town_map_beginner_entity_load_slot_descriptor_3:
        .dc.w   0
        .dc.l   town_map_beginner_entity_load_group_descriptor_3_0

        town_map_beginner_entity_load_group_descriptor_3_0:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   3  // number of entities
                map_entity_definition 0, ENTITY_TYPE_AMAZON_2, 216, 332,, 300
                map_entity_definition 1, ENTITY_TYPE_AMAZON_2, 240, 348,, 240
                map_entity_definition 2, ENTITY_TYPE_THIEF, 228, 308, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT, ENTITY_TYPE_THIEF_BLUE_PARAM(3)

    town_map_beginner_entity_load_slot_descriptor_4:
        .dc.w   0
        .dc.l   town_map_beginner_entity_load_group_descriptor_4_0

        town_map_beginner_entity_load_group_descriptor_4_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   town_map_beginner_entity_load_group_descriptor_4_0_pal0
            .dc.l   town_map_beginner_entity_load_group_descriptor_4_0_pal1
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 0, ENTITY_TYPE_BAD_BROTHER_BLUE, 208, 240, GAME_PLAY_VRAM_RESERVED_TILE_MAX
                map_entity_definition 1, ENTITY_TYPE_BAD_BROTHER_BLUE, 208, 240, GAME_PLAY_VRAM_RESERVED_TILE_MAX, 300

            town_map_beginner_entity_load_group_descriptor_4_0_pal0:
                entity_palette PALETTE_OFFSET(1, 8), 8, skin_4, blue2_4
            town_map_beginner_entity_load_group_descriptor_4_0_pal1:
                entity_palette PALETTE_OFFSET(3, 8), 8, towndoor_8

    town_map_beginner_entity_load_slot_descriptor_5:
        .dc.w   0
        .dc.l   town_map_beginner_entity_load_group_descriptor_5_0

        town_map_beginner_entity_load_group_descriptor_5_0:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   6  // number of entities
                map_entity_definition 0, ENTITY_TYPE_VILLAGER_1, 212, 350, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT + THIEF_TILE_COUNT, 0xd3ff
                map_entity_definition 1, ENTITY_TYPE_VILLAGER_2, 220, 334, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT + THIEF_TILE_COUNT, 0xda00
                map_entity_definition 2, ENTITY_TYPE_VILLAGER_1, 228, 348, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT + THIEF_TILE_COUNT, 0xdb00
                map_entity_definition 3, ENTITY_TYPE_VILLAGER_2, 236, 330, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT + THIEF_TILE_COUNT, 0xd900
                map_entity_definition 4, ENTITY_TYPE_VILLAGER_1, 244, 324, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT + THIEF_TILE_COUNT, 0xd6f0
                map_entity_definition 5, ENTITY_TYPE_VILLAGER_2, 252, 330, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT + THIEF_TILE_COUNT, 0xdd00

    town_map_beginner_entity_load_slot_descriptor_6:
        .dc.w   0
        .dc.l   town_map_beginner_entity_load_group_descriptor_6_0

        town_map_beginner_entity_load_group_descriptor_6_0:
            .dc.w   0   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 3, ENTITY_TYPE_THIEF, 228, 330, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT, ENTITY_TYPE_THIEF_BLUE_PARAM(2)
                map_entity_definition 4, ENTITY_TYPE_THIEF, 180, 320, TOWNDOOR_TILE_ID + TOWNDOOR1_TILE_COUNT + TOWNDOOR2_TILE_COUNT, ENTITY_TYPE_THIEF_BLUE_PARAM(3)

    town_map_beginner_entity_load_slot_descriptor_7:
        .dc.w   0
        .dc.l   town_map_beginner_entity_load_group_descriptor_7_0

        town_map_beginner_entity_load_group_descriptor_7_0:
            .dc.w   1   // load allowed when there are active enemies?

            .dc.l   town_map_beginner_entity_load_group_descriptor_7_0_pal0
            .dc.l   0
            .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX + BAD_BROTHER_TILE_COUNT))
            .dc.l   nem_pat_death_adder
            .dc.l   VRAM_ADDR_SET(TILE_ADDR(DEATH_ADDER_SPECIAL_TILE_ID))
            .dc.l   nem_pat_death_adder_special
            .dc.l   VRAM_ADDR_SET(GAME_PLAY_VRAM_RESERVED_MIN)
            .dc.l   nem_pat_death_adder_special_explosion
            .dc.l   0

            .dc.w   3  // number of entities
                map_entity_definition 0, ENTITY_TYPE_HENINGER_SILVER, 160, 350
                map_entity_definition 1, ENTITY_TYPE_HENINGER_SILVER, 188, 360
                map_entity_definition 2, ENTITY_TYPE_HENINGER_SILVER, 240, 330

            town_map_beginner_entity_load_group_descriptor_7_0_pal0:
                entity_palette PALETTE_OFFSET(1, 8), 8, skin_4, silver_4

    town_map_beginner_entity_load_slot_descriptor_8:
        .dc.w   0
        .dc.l   town_map_beginner_entity_load_group_descriptor_8_0

        town_map_beginner_entity_load_group_descriptor_8_0:
            .dc.w   1   // load allowed when there are active enemies?
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 5, ENTITY_TYPE_DEATH_ADDER_JR, 112, 160, GAME_PLAY_VRAM_RESERVED_TILE_MAX


    /**********************************************************
     * Camp site
     */

    // Camp site vertical scroll
    patch_start 0x002a8a
        .dc.w   32
    patch_end

    // Camp site entity load group descriptor (thiefs)
    patch_start 0x002b24
        .dc.l   town_camp_map_entity_load_group_descriptor   // Patch table entry
    patch_end

    town_camp_map_entity_load_group_descriptor:
        .dc.w   0   // Load allowed when there are active enemies?
        .dc.l   0   // Palette list
        .dc.l   0   // Nemesis tile data list
        .dc.w   4   // Number of entities
            map_entity_definition 0, ENTITY_TYPE_THIEF, 176, 96, 0x3A3, ENTITY_TYPE_THIEF_BLUE_PARAM(1) | 0x8000
            map_entity_definition 1, ENTITY_TYPE_THIEF, 184, 96, 0x3A3, ENTITY_TYPE_THIEF_GREEN_PARAM(1)
            map_entity_definition 2, ENTITY_TYPE_THIEF, 192, 32, 0x3A3, ENTITY_TYPE_THIEF_BLUE_PARAM(1)
            map_entity_definition 3, ENTITY_TYPE_THIEF, 176, 32, 0x3A3, ENTITY_TYPE_THIEF_GREEN_PARAM(1)
