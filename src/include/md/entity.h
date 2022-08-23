/*
 * Golden Axe entity macros/constants
 */

#ifndef __ENTITY_H__
#define __ENTITY_H__

#include "md.h"
#include "goldenaxe.h"


/**********************************************************
 * Sub routines
 */

#define update_active_entities                          0x0000b954
#define find_free_entity_slot                           0x00008a8a
#define remove_entity                                   0x0000b70e


/**********************************************************
 * Memory addresses/variables
 */

#define entity_slot_base                                0xffffd100
#define entity_slot_magic                               0xffffd500  // Magic special attacks use this
#define entity_slot_alloc_base                          0xffffd580  // Free allocatable. See find_free_entity_slot (51 entries)

#define ENTITY_SLOT_ALLOC_COUNT                         51

#define ENTITY_SLOT_ADDR(slot)      (entity_slot_base + (slot) * 0x80)


/**********************************************************
 * Entity struct
 */

#define ENTITY_SIZE                                     0x80

#define entity_id                                       0x00
#define entity_data                                     0x01
#define entity_flags_02                                 0x02
#define entity_flags_03                                 0x03
#define entity_map_init_data                            0x06
#define entity_tile_id                                  0x08
#define entity_animation_table                          0x0e
#define entity_animation_offset                         0x12
#define entity_animation_frame_index                    0x14
#define entity_animation_frame_time                     0x15
#define entity_animation_frame_time_left                0x16
#define entity_sprite_attr                              0x17
#define entity_y                                        0x18
#define entity_x                                        0x1c
#define entity_base_y                                   0x20
#define entity_height                                   0x24
#define entity_interacting_entity                       0x38
#define entity_mount                                    0x3c
#define entity_state                                    0x42    // TODO: 0x4c seems be be main state and 0x42 sub state (in most cases)
#define entity_state_main                               0x4c
#define entity_flags_44                                 0x44
#define entity_hp                                       0x64
#define entity_dma_source_base                          0x74


#define ENTITY_FLAGS_02_ANIMATION_MARKER_HIT            0x02
#define ENTITY_FLAGS_02_HIDE_SPRITE                     0x80

#define B_ENTITY_FLAGS_02_ANIMATION_MARKER_HIT          1
#define B_ENTITY_FLAGS_02_HIDE_SPRITE                   7


#define ENTITY_FLAGS_03_KNOCKDOWN                       0x02
#define ENTITY_FLAGS_03_MOUNTED                         0x04
#define ENTITY_FLAGS_03_DAMAGE_RECEIVED                 0x40
#define ENTITY_FLAGS_03_DAMAGE_DEALT                    0x80

#define B_ENTITY_FLAGS_03_KNOCKDOWN                     1
#define B_ENTITY_FLAGS_03_MOUNTED                       2
#define B_ENTITY_FLAGS_03_DAMAGE_RECEIVED               6
#define B_ENTITY_FLAGS_03_DAMAGE_DEALT                  7


#define ENTITY_FLAGS_44_MOVE_LEFT                       0x01
#define ENTITY_FLAGS_44_MOVE_UP                         0x02

#define B_ENTITY_FLAGS_44_MOVE_LEFT                     0
#define B_ENTITY_FLAGS_44_MOVE_UP                       1


/**********************************************************
 * Entity types
 */

#define ENTITY_TYPE_NONE                                0x00
#define ENTITY_TYPE_THIEF                               0x1e
#define ENTITY_TYPE_EYE_BALL                            0x27
#define ENTITY_TYPE_TOWN_DOOR                           0x28
#define ENTITY_TYPE_WATER                               0x2a
#define ENTITY_TYPE_ROPE                                0x2b
#define ENTITY_TYPE_KING                                0x2c
#define ENTITY_TYPE_QUEEN                               0x2d
#define ENTITY_TYPE_SKELETON_1                          0x2e
#define ENTITY_TYPE_SKELETON_2_FROM_HOLE                0x2f
#define ENTITY_TYPE_SKELETON_3                          0x30
#define ENTITY_TYPE_HENINGER_SILVER                     0x31
#define ENTITY_TYPE_HENINGER_PURPLE                     0x32
#define ENTITY_TYPE_HENINGER_RED                        0x33
#define ENTITY_TYPE_HENINGER_GOLD                       0x34
#define ENTITY_TYPE_HENINGER_DARK                       0x35
#define ENTITY_TYPE_HENINGER_BRONZE                     0x36
#define ENTITY_TYPE_HENINGER_GREEN                      0x37
#define ENTITY_TYPE_LONGMOAN_SILVER                     0x38
#define ENTITY_TYPE_LONGMOAN_PURPLE                     0x39
#define ENTITY_TYPE_LONGMOAN_RED                        0x3a
#define ENTITY_TYPE_LONGMOAN_GOLD                       0x3b
#define ENTITY_TYPE_LONGMOAN_DARK                       0x3c
#define ENTITY_TYPE_LONGMOAN_BRONZE                     0x3d
#define ENTITY_TYPE_LONGMOAN_GREEN                      0x3e
#define ENTITY_TYPE_BAD_BROTHER_GREEN                   0x3f
#define ENTITY_TYPE_BAD_BROTHER_BLUE                    0x40
#define ENTITY_TYPE_BAD_BROTHER_RED                     0x41
#define ENTITY_TYPE_AMAZON_1                            0x42
#define ENTITY_TYPE_AMAZON_2                            0x43
#define ENTITY_TYPE_AMAZON_3                            0x44
#define ENTITY_TYPE_AMAZON_4                            0x45
#define ENTITY_TYPE_AMAZON_5                            0x46
#define ENTITY_TYPE_BITTER_SILVER                       0x47
#define ENTITY_TYPE_BITTER_RED                          0x48
#define ENTITY_TYPE_BITTER_GOLD                         0x49
#define ENTITY_TYPE_DEATH_ADDER                         0x4a
#define ENTITY_TYPE_DEATH_BRINGER                       0x4b
#define ENTITY_TYPE_DEATH_ADDER_JR                      0x4c
#define ENTITY_TYPE_BLUE_DRAGON                         0x4d
#define ENTITY_TYPE_RED_DRAGON                          0x4e
#define ENTITY_TYPE_CHICKEN_LEG                         0x4f
#define ENTITY_DRAGON_FLAME                             0x50
#define ENTITY_DRAGON_FIRE_BALL                         0x51
#define ENTITY_TYPE_VILLAGER_1                          0x56
#define ENTITY_TYPE_VILLAGER_2                          0x57
#define ENTITY_TYPE_SKELETON_4                          0x60

#define ENTITY_TYPE_THIEF_BLUE(item_count)              (item_count)
#define ENTITY_TYPE_THIEF_GREEN(item_count)             (0x0080 | item_count)


/**********************************************************
 * Entity graphics data
 */

// Remapped tile id for death adder special
#define DEATH_ADDER_SPECIAL_TILE_ID (GAME_PLAY_VRAM_DYNAMIC_TOP_TILE - DEATH_ADDER_SPECIAL_TILE_COUNT)

#define entity_nemesis_data_table                       0x00013a74

// Nemesis data table offsets
#define ENTITY_NEMESIS_OFFSET_THIEF                     0x00
#define ENTITY_NEMESIS_OFFSET_BAD_BROTHER               0x04
#define ENTITY_NEMESIS_OFFSET_DEATH ADDER               0x08
#define ENTITY_NEMESIS_OFFSET_BITTER                    0x0c
#define ENTITY_NEMESIS_OFFSET_CHICKEN_LEG               0x10
#define ENTITY_NEMESIS_OFFSET_DRAGON                    0x14
#define ENTITY_NEMESIS_OFFSET_VILLAGERS                 0x18
#define ENTITY_NEMESIS_OFFSET_KING_AND_QUEEN            0x1c
#define ENTITY_NEMESIS_OFFSET_DEATH_ADDER_SPECIAL       0x20

// Absolute nemesis data addresses
#define nem_pat_chicken_leg                             0x00040e8a
#define CHICKEN_LEG_TILE_COUNT                          176

#define nem_pat_bad_brother                             0x0007532a
#define BAD_BROTHER_TILE_COUNT                          531

#define nem_pat_death_adder                             0x00077d6e
#define DEATH_ADDER_TILE_COUNT                          232

#define nem_pat_bitter                                  0x0007d088
#define BITTER_TILE_COUNT                               376

#define nem_pat_death_adder_special                     0x0005fc2a
#define DEATH_ADDER_SPECIAL_TILE_COUNT                  45

#define nem_pat_death_adder_special_explosion           0x00032c8e
#define DEATH_ADDER_SPECIAL_EXPLOSION_TILE_COUNT        81

#define nem_pat_death_adder_axe                         0x00075150
#define DEATH_ADDER_AXE_TILE_COUNT                      26

#define nem_pat_king_and_queen                          0x0007ec7a
#define KING_AND_QUEEN_TILE_COUNT                       81

#define nem_pat_dragon                                  0x000420FE
#define DRAGON_TILE_COUNT                               273

#define nem_pat_water                                   0x00022e88
#define WATER_TILE_COUNT                                72

#define nem_pat_thief                                   0x000733ea
#define THIEF_TILE_COUNT                                49


// Tile counts for new nemesis data included via resources.s
#define TOWNDOOR_TILE_ID                                1
#define TOWNDOOR1_TILE_COUNT                            98
#define TOWNDOOR2_TILE_COUNT                            83

#define TURTLE_EYE_TILE_COUNT                           12
#define TURTLE_EYE_TILE_ID                              (GAME_PLAY_VRAM_DYNAMIC_TOP_TILE - TURTLE_EYE_TILE_COUNT)
#define TURTLE_EYE_X                                    674
#define TURTLE_EYE_Y                                    293
#define TURTLE_EYE_WIDTH                                16
#define TURTLE_EYE_HEIGHT                               16

#define EAGLE_EYE_TILE_COUNT                            48
#define EAGLE_EYE_TILE_ID                               (GAME_PLAY_VRAM_DYNAMIC_TOP_TILE - EAGLE_EYE_TILE_COUNT)
#define EAGLE_EYE_X                                     573
#define EAGLE_EYE_Y                                     312
#define EAGLE_EYE_WIDTH                                 32
#define EAGLE_EYE_HEIGHT                                32

#define HOLE_TILE_COUNT                                 16
#define HOLE_TILE_ID                                    (GAME_PLAY_VRAM_DYNAMIC_TOP_TILE - EAGLE_EYE_TILE_COUNT - HOLE_TILE_COUNT)


#ifdef __ASSEMBLER__

/**********************************************************
 * Assembler macros
 */

.macro map_entity_definition slot, id, base_y, x, tile_id=0, init_value=0
    .dc.b   \slot
    .dc.b   \id
    .dc.w   \base_y
    .dc.w   (\x) + 128
    .dc.w   \tile_id        // Ignored for entity types that use DMA for animation frame updates
    .dc.w   \init_value
.endm


.macro entity_palette offset, count, palettes:vararg
    .dc.b \offset, \count - 1
    .irp palette_name, \palettes
        entity_palette_\palette_name
    .endr
.endm

/**********************************************************
 * Partial palette macros
 */

// Palette 1:5: Amazon
// Palette 2:5: Chicken leg
.macro entity_palette_yellow_3
    .irp color, 0x00cc, 0x0088, 0x0044
        .dc.w \color
    .endr
.endm

// Palette 2:8: Chicken leg
.macro entity_palette_purple_3
    .irp color, 0x0e6e, 0x0a4a, 0x0606
        .dc.w \color
    .endr
.endm

// Palette 1:8: All
.macro entity_palette_skin_4
    .irp color, 0x068c, 0x046a, 0x0248, 0x0026
        .dc.w \color
    .endr
.endm

// Palette 2:11 Dragon flame
.macro entity_palette_flame_5
    .irp color, 0x0008, 0x000e, 0x008e, 0x00ce, 0x0cee
        .dc.w \color
    .endr
.endm

// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
.macro entity_palette_silver_4
    .irp color, 0x0cc6, 0x0882, 0x0440, 0x0220
        .dc.w \color
    .endr
.endm

// Palette 1:1: Amazon
// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
.macro entity_palette_green_4
    .irp color, 0x08c4, 0x0682, 0x0460, 0x0240
        .dc.w \color
    .endr
.endm

// Palette 1:1: Amazon
.macro entity_palette_purple1_4
    .irp color, 0x0e4c, 0x0828, 0x0404, 0x0002
        .dc.w \color
    .endr
.endm

// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
.macro entity_palette_purple2_4
    .irp color, 0x0e8c, 0x0c4a, 0x0806, 0x0402
        .dc.w \color
    .endr
.endm

// Palette 1:1: Amazon
// Palette 1:1: Red dragon
.macro entity_palette_red1_4
    .irp color, 0x086e, 0x060c, 0x0208, 0x0002
        .dc.w \color
    .endr
.endm

// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
.macro entity_palette_red2_4
    .irp color, 0x066e, 0x022c, 0x0008, 0x0004
        .dc.w \color
    .endr
.endm

// Palette 1:12: Bitter
.macro entity_palette_red3_4
    .irp color, 0x088e, 0x044a, 0x0228, 0x0206
        .dc.w \color
    .endr
.endm

// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
.macro entity_palette_gold_4
    .irp color, 0x02cc, 0x0066, 0x0044, 0x0022
        .dc.w \color
    .endr
.endm

// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
// Palette 1:8: All skin
.macro entity_palette_dark_4
    .irp color, 0x0666, 0x0444, 0x0222, 0x0000
        .dc.w \color
    .endr
.endm

// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
// Palette 1:8: All skin
.macro entity_palette_bronze_4
    .irp color, 0x06A4, 0x0462, 0x0240, 0x0020
        .dc.w \color
    .endr
.endm

// Palette 2:1: Blue dragon
.macro entity_palette_blue1_4
    .irp color, 0x0ca6, 0x0864, 0x0642, 0x0220
        .dc.w \color
    .endr
.endm

// Palette 1:12: Heninger, Longmoan, Bad brother, Death adder
.macro entity_palette_blue2_4
    .irp color, 0x0a84, 0x0642, 0x0420, 0x0200
        .dc.w \color
    .endr
.endm

// Palette 2:1: Skeleton hole
.macro entity_palette_hole_4
    .irp color, 0x0466 0x0244, 0x0022, 0x0000
        .dc.w \color
    .endr
.endm

// Palette 3:8: Flowing water (turtle village)
.macro entity_palette_water_5
    .irp color, 0x0200, 0x0024, 0x0664, 0x0440, 0x0220
        .dc.w \color
    .endr
.endm

// Palette 3:8
.macro entity_palette_towndoor_8
    .irp color, 0x0000, 0x0246, 0x0466, 0x0244, 0x06aa, 0x068a, 0x0468, 0x08cc
        .dc.w \color
    .endr
.endm

// Palette 2:8
.macro entity_palette_eagle_eye_7
    .irp color, 0x0222, 0x0644, 0x0866, 0x0a86, 0x0aa8, 0x0cca, 0x0eee
        .dc.w \color
    .endr
.endm

// Palette 3:8
.macro entity_palette_turtle_eye_6
    .irp color, 0x0000, 0x0246, 0x0246, 0x0268, 0x048a, 0x0ccc
        .dc.w \color
    .endr
.endm

// Palette 2:8
.macro entity_palette_explosion_8
    .irp color, 0x008e, 0x00ee, 0x0eee, 0x0068, 0x008a, 0x00ac, 0x00ee, 0x0eee
        .dc.w \color
    .endr
.endm

#endif

#endif
