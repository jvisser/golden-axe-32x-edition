/*
 * Demo map data patches
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

        /* Extended map data is prefixed */
        .dc.l   demo_entity_palette_table - 4           // The first entry is always ignored so offset for that
        .dc.l   demo_entity_group_graphics_table - 4    // The first entry is always ignored so offset for that
        .dc.l   demo_entity_load_slot_descriptor_table
    demo_map_definition:
        /* Palette list */
        .dc.l   hud_player_palette
        .dc.l   0

        /* Nemesis tile data list */
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(1))             // Pre load entity tile data
        .dc.l   nem_pat_chicken_leg
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX))
        .dc.l   nem_pat_bad_brother
        .dc.l   0

        /* Tile map data */
        .dc.l   map_wilderness_foreground_blocks
        .dc.l   map_wilderness_foreground_map

        /* Map dimensions */
        .dc.w   map_wilderness_block_height
        .dc.w   map_wilderness_block_width

        /* Initial scroll positions in blocks */
        .dc.w   0       // Vertical
        .dc.w   0       // Horizontal

        /* Event list */
        .dc.l   demo_event_list

        /* Height map data */
        .dc.l   map_wilderness_height_map
        .dc.l   map_wilderness_height_blocks

        /* Entity load list */
        .dc.l   demo_entity_load_list

        /* Player starting positions */
        .dc.w   -20     // Player 1 Y (Baseline relative offset)
        .dc.w   256     // Player 1 X
        .dc.w   0       // Player 2 Y (Baseline relative offset)
        .dc.w   0       // Player 2 X

        /* Music id */
        .dc.w   SONG_WILDERNESS


    /**********************************************************
     * Event list
     */
    demo_event_list:
        .dc.w   1280
        .dc.b   MAP_EVENT_NOTHING
        .dc.b   0x00


    /**********************************************************
     * Entity load list
     */
    demo_entity_load_list:
        .dc.w   0x0000
        .dc.w   0x0000  // index into demo_entity_load_slot_descriptor_table

        .dc.w   0x0500
        .dc.w   0x0000

        .dc.w   -1


    demo_entity_group_graphics_table:
        .dc.l   demo_map_entity_load_group_descriptor_0_0_graphics


    demo_entity_palette_table:
        .dc.l   demo_map_entity_load_group_descriptor_0_0_pal0
        .dc.l   demo_map_entity_load_group_descriptor_0_0_pal1


    demo_entity_load_slot_descriptor_table:
        .dc.l   demo_map_entity_load_slot_descriptor_0

        demo_map_entity_load_slot_descriptor_0:
            .dc.w   0   // number of load groups - 1
            .dc.l   demo_map_entity_load_group_descriptor_0_0

            demo_map_entity_load_group_descriptor_0_0:
                .dc.b   0   // load allowed when there are active enemies?
                .dc.b   4   // offset (+4 0=skip) into demo_entity_group_graphics_table
                .dc.w   5   // number of entities

                    map_entity_definition 6, ENTITY_TYPE_CHICKEN_LEG,       180, 216, 1
                    map_entity_definition 0, ENTITY_TYPE_LONGMOAN_SILVER,   180, 216
                    map_entity_definition 1, ENTITY_TYPE_AMAZON_1,          210, 270
                    map_entity_definition 2, ENTITY_TYPE_HENINGER_SILVER,   210, 186
                    map_entity_definition 5, ENTITY_TYPE_BAD_BROTHER_GREEN, 160, 190, GAME_PLAY_VRAM_RESERVED_TILE_MAX

                demo_map_entity_load_group_descriptor_0_0_graphics:
                    /* Palettes to load */
                    .dc.b    1                                  // index (+1 0=skip) into demo_entity_palette_table
                    .dc.b    2                                  // index into demo_entity_palette_table

                    /* Nemesis data to load */
                    .dc.w   0                                   // Terminate

                    /*
                     * Keep this for documentation purposes on how to set this up. (Remove terminator above to enable)
                     *
                     * It's more efficient to load the graphics through the map definition as that loads with display off and before any gameplay.
                     * Loading data into VRAM during active display likely results in cpu stalls due to full write FIFO (depending on the decompression speed).
                     * So loading through the map definition is prefered whenever possible.
                     */
/*
                    .dc.w    TILE_ADDR(1)                       // VRAM address (this relates to the tile_id parameter of map_entity_definition)
                    .dc.w    ENTITY_NEMESIS_OFFSET_CHICKEN_LEG  // Nemesis data id

                    .dc.w    GAME_PLAY_VRAM_RESERVED_MAX
                    .dc.w    ENTITY_NEMESIS_OFFSET_BAD_BROTHER

                    .dc.w   0                                   // Terminate
*/
                demo_map_entity_load_group_descriptor_0_0_pal0:
                    .dc.b PALETTE_OFFSET(1, 1)
                    .dc.b 14
                        entity_palette_combine red1_4, yellow_3, skin_4, green_4

                demo_map_entity_load_group_descriptor_0_0_pal1:
                    .dc.b PALETTE_OFFSET(2, 5)
                    .dc.b 5
                        entity_palette_combine yellow_3, purple_3
