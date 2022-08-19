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
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(1))
        .dc.l   nem_pat_towndoor_1
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(1 + TOWNDOOR1_TILE_COUNT))
        .dc.l   nem_pat_towndoor_2
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX))
        .dc.l   nem_pat_dragon
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX + DRAGON_TILE_COUNT))
        .dc.l   nem_pat_bad_brother
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_DYNAMIC_TOP_TILE - TURTLE_EYE_TILE_COUNT))
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
        .dc.w   320
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x01

        .dc.w   354 // TURTLE_EYE_X(674) - 320
        .dc.b   MAP_EVENT_SPAWN_ENTITY
        .dc.b   ENTITY_TYPE_EYE_BALL

        .dc.w   672
        .dc.b   MAP_EVENT_SCROLL_LOCK
        .dc.b   town_scroll_lock_0 - town_extended_event_data_table

        .dc.w   1040
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x02

        .dc.w   1048
        .dc.b   MAP_EVENT_CHANGE_MUSIC
        .dc.b   SONG_BOSS

        .dc.w   1216
        .dc.b   MAP_EVENT_CAMPSITE_ON_ENEMY_DEFEAT
        .dc.b   0x00

        .dc.w   1280
        .dc.b   MAP_EVENT_NOTHING
        .dc.b   0x00

    town_extended_event_data_table:
        town_scroll_lock_0:     .dc.l   town_scroll_lock_0_param

    town_scroll_lock_0_param:
        .dc.w   0                   // Min y scroll
        .dc.w   256 - 224           // Max y scroll
        .dc.l   0x0000b333          // Camera y decrement on h scroll (16.16)


    /**********************************************************
     * Entity load list
     */
    town_entity_load_list:
        .dc.w   0
        .dc.l   town_map_entity_load_slot_descriptor_0

        .dc.w   800
        .dc.l   town_map_entity_load_slot_descriptor_1

        .dc.w   1216
        .dc.l   town_map_entity_load_slot_descriptor_2

        .dc.w   -1

    town_map_entity_load_slot_descriptor_0:
        .dc.w   0
        .dc.l   town_map_entity_load_group_descriptor_0_0

        town_map_entity_load_group_descriptor_0_0:
            .dc.w   1   // load allowed when there are active enemies?

            .dc.l   town_map_entity_load_group_descriptor_0_0_pal0
            .dc.l   town_map_entity_load_group_descriptor_0_0_pal1
            .dc.l   0
            .dc.l   0

            .dc.w   2  // number of entities
                map_entity_definition 6, ENTITY_TYPE_BLUE_DRAGON, 216, 190, GAME_PLAY_VRAM_RESERVED_TILE_MAX
                map_entity_definition 7, ENTITY_TYPE_RED_DRAGON, 216, 90, GAME_PLAY_VRAM_RESERVED_TILE_MAX

        town_map_entity_load_group_descriptor_0_0_pal0:
            entity_palette PALETTE_OFFSET(1, 1), 7, red1_4, yellow_3
        town_map_entity_load_group_descriptor_0_0_pal1:
            entity_palette PALETTE_OFFSET(2, 11), 5, flame_5

    town_map_entity_load_slot_descriptor_1:
        .dc.w   0
        .dc.l   town_map_entity_load_group_descriptor_1_0

        town_map_entity_load_group_descriptor_1_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   town_map_entity_load_group_descriptor_1_0_pal0
            .dc.l   town_map_entity_load_group_descriptor_1_0_pal1
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 0, ENTITY_TYPE_BAD_BROTHER_BLUE, 208, 240, GAME_PLAY_VRAM_RESERVED_TILE_MAX + DRAGON_TILE_COUNT

            town_map_entity_load_group_descriptor_1_0_pal0:
                entity_palette PALETTE_OFFSET(1, 8), 8, skin_4, red2_4
            town_map_entity_load_group_descriptor_1_0_pal1:
                entity_palette PALETTE_OFFSET(3, 8), 8, towndoor_8


    town_map_entity_load_slot_descriptor_2:
        .dc.w   0
        .dc.l   town_map_entity_load_group_descriptor_2_0

        town_map_entity_load_group_descriptor_2_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   town_map_entity_load_group_descriptor_2_0_pal0
            .dc.l   0
            .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX + DRAGON_TILE_COUNT))
            .dc.l   nem_pat_bitter
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 0, ENTITY_TYPE_BITTER_SILVER, 112, 160, GAME_PLAY_VRAM_RESERVED_TILE_MAX + DRAGON_TILE_COUNT

            town_map_entity_load_group_descriptor_2_0_pal0:
                entity_palette PALETTE_OFFSET(1, 8), 8, skin_4, silver_4


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
            map_entity_definition 0, ENTITY_TYPE_THIEF, 176, 96, 0x3A3, ENTITY_TYPE_THIEF_BLUE(1) | 0x8000
            map_entity_definition 1, ENTITY_TYPE_THIEF, 184, 96, 0x3A3, ENTITY_TYPE_THIEF_GREEN(1)
            map_entity_definition 2, ENTITY_TYPE_THIEF, 192, 32, 0x3A3, ENTITY_TYPE_THIEF_BLUE(1)
            map_entity_definition 3, ENTITY_TYPE_THIEF, 176, 32, 0x3A3, ENTITY_TYPE_THIEF_GREEN(1)
