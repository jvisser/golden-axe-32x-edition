/*
 * Demo patches
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
    patch_start 0x0015d4
        .dc.l   demo_map_definition                     // Patch map table entry
    patch_end

    demo_map_definition:
        // Palette list
        .dc.l   hud_player_palette
        .dc.l   0

        // Nemesis tile data list
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(1))             // Pre load entity tile data
        .dc.l   nem_pat_chicken_leg
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX))
        .dc.l   nem_pat_bad_brother
        .dc.l   0

        // Tile map data
        .dc.l   map_wilderness_foreground_blocks
        .dc.l   map_wilderness_foreground_map

        // Map dimensions
        .dc.w   map_wilderness_block_height
        .dc.w   map_wilderness_block_width

        // Initial scroll positions in blocks
        .dc.w   0       // Vertical
        .dc.w   0       // Horizontal

        // Event list
        .dc.l   demo_event_list
        .dc.l   0

        // Height map data
        .dc.l   map_wilderness_height_map
        .dc.l   map_wilderness_height_blocks

        // Entity load list
        .dc.l   demo_entity_load_list

        // Player starting positions
        .dc.w   -20     // Player 1 Y (Baseline relative offset)
        .dc.w   256     // Player 1 X
        .dc.w   0       // Player 2 Y (Baseline relative offset)
        .dc.w   0       // Player 2 X

        // Music id
        .dc.w   SONG_WILDERNESS


    /**********************************************************
     * Event list
     */
    demo_event_list:
        .dc.w   1280    // horizontal trigger position
        .dc.b   MAP_EVENT_NOTHING
        .dc.b   0x00


    /**********************************************************
     * Entity load list
     */
    demo_entity_load_list:
        .dc.w   0       // horizontal trigger position
        .dc.l   demo_map_entity_load_slot_descriptor_0

        .dc.w   -1      // Terminate


    demo_map_entity_load_slot_descriptor_0:
        .dc.w   0       // number of load groups descriptors - 1
        .dc.l   demo_map_entity_load_group_descriptor_0_0

        demo_map_entity_load_group_descriptor_0_0:
            .dc.w   0   // load allowed when there are active enemies?

            // Palette list
            .dc.l   demo_map_entity_load_group_descriptor_0_0_pal0
            .dc.l   demo_map_entity_load_group_descriptor_0_0_pal1
            .dc.l   0  // Terminate

            // Nemesis tile data list
            .dc.l   0  // Terminate

            // Entity descriptors
            .dc.w   5  // number of entities

                map_entity_definition 6, ENTITY_TYPE_CHICKEN_LEG,       180, 216, 1
                map_entity_definition 0, ENTITY_TYPE_LONGMOAN_SILVER,   180, 216
                map_entity_definition 1, ENTITY_TYPE_AMAZON_1,          210, 270
                map_entity_definition 2, ENTITY_TYPE_HENINGER_SILVER,   210, 186
                map_entity_definition 5, ENTITY_TYPE_BAD_BROTHER_RED,   160, 190, GAME_PLAY_VRAM_RESERVED_TILE_MAX

            demo_map_entity_load_group_descriptor_0_0_pal0:
                entity_palette PALETTE_OFFSET(1, 1), 15, red1_4, yellow_3, skin_4, green_4

            demo_map_entity_load_group_descriptor_0_0_pal1:
                entity_palette PALETTE_OFFSET(2, 5), 6, yellow_3, purple_3
