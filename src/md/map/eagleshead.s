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
        /* Palette list */
        .dc.l   hud_player_palette
        .dc.l   0

        /* Nemesis tile data list */
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(0))
        .dc.l   nem_pat_empty
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(1))
        .dc.l   nem_pat_dragon
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX))
        .dc.l   nem_pat_bad_brother
        .dc.l   VRAM_ADDR_SET(TILE_ADDR(GAME_PLAY_VRAM_RESERVED_TILE_MAX + BAD_BROTHER_TILE_COUNT))
        .dc.l   nem_death_adder
        .dc.l   0

        /* Tile map data */
        .dc.l   map_eagles_head_foreground_blocks
        .dc.l   map_eagles_head_foreground_map

        /* Map dimensions */
        .dc.w   map_eagles_head_block_height
        .dc.w   map_eagles_head_block_width

        /* Initial scroll positions in blocks */
        .dc.w   4       // Vertical
        .dc.w   0       // Horizontal

        /* Event list */
        .dc.l   eagles_head_event_list
        .dc.l   eagles_head_extended_event_data_table

        /* Height map data */
        .dc.l   map_eagles_head_height_map
        .dc.l   map_eagles_head_height_blocks

        /* Entity load list */
        .dc.l   eagles_head_entity_load_list

        /* Player starting positions */
        .dc.w   0       // Player 1 Y (Baseline relative offset)
        .dc.w   256     // Player 1 X
        .dc.w   0       // Player 2 Y (Baseline relative offset)
        .dc.w   296     // Player 2 X

        /* Music id */
        .dc.w   SONG_EAGLES_HEAD


    /**********************************************************
     * Patch map background tile data graphics table entry to point to empty tile data for each entry
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
        .dc.w   320
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x01

        .dc.w   952
        .dc.b   MAP_EVENT_PALETTE_TRANSITION
        .dc.b   0x02

        .dc.w   960
        .dc.b   MAP_EVENT_CHANGE_MUSIC
        .dc.b   SONG_DEATH_ADDER

        .dc.w   1216
        .dc.b   MAP_EVENT_NEXT_LEVEL_ON_ENEMY_DEFEAT
        .dc.b   0x00

        .dc.w   1280
        .dc.b   MAP_EVENT_NOTHING
        .dc.b   0x00

    eagles_head_extended_event_data_table:


    /**********************************************************
     * Entity load list
     */

    eagles_head_entity_load_list:
        .dc.w   800
        .dc.l   eagles_head_map_entity_load_slot_descriptor_0

        .dc.w   1216
        .dc.l   eagles_head_map_entity_load_slot_descriptor_1

        .dc.w   -1

    eagles_head_map_entity_load_slot_descriptor_0:
        .dc.w   0
        .dc.l   eagles_head_map_entity_load_group_descriptor_0_0

        eagles_head_map_entity_load_group_descriptor_0_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   eagles_head_map_entity_load_group_descriptor_0_0_pal0
            .dc.l   0
            .dc.l   0

            .dc.w   1  // number of entities
                map_entity_definition 6, ENTITY_TYPE_BLUE_DRAGON, 248, 320, 1

            eagles_head_map_entity_load_group_descriptor_0_0_pal0:
                entity_palette PALETTE_OFFSET(3, 1), 7, blue1_4, yellow_3


    eagles_head_map_entity_load_slot_descriptor_1:
        .dc.w   0
        .dc.l   eagles_head_map_entity_load_group_descriptor_1_0

        eagles_head_map_entity_load_group_descriptor_1_0:
            .dc.w   0   // load allowed when there are active enemies?

            .dc.l   eagles_head_map_entity_load_group_descriptor_1_0_pal0
            .dc.l   0

            // Death adder special attacks graphics
            .dc.l   VRAM_ADDR_SET(TILE_ADDR(DEATH_ADDER_SPECIAL_TILE_ID))
            .dc.l   nem_death_adder_special
            .dc.l   VRAM_ADDR_SET(GAME_PLAY_VRAM_RESERVED_MIN)              // Fixed address
            .dc.l   nem_death_adder_special_explosion
            .dc.l   0

            .dc.w   3  // number of entities
                map_entity_definition 0, ENTITY_TYPE_SKELETON_3,  168, -32
                map_entity_definition 1, ENTITY_TYPE_SKELETON_3,  246, -16
                map_entity_definition 2, ENTITY_TYPE_DEATH_BRINGER, 176, 320 / 2, GAME_PLAY_VRAM_RESERVED_TILE_MAX

            eagles_head_map_entity_load_group_descriptor_1_0_pal0:
                entity_palette PALETTE_OFFSET(1, 1), 15, red1_4, yellow_3, skin_4, red2_4
