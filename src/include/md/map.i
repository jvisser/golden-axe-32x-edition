|--------------------------------------------------------------------
| Golden Axe map macros/constants
|--------------------------------------------------------------------

    .ifnotdef   __MAP_I__
    .equ        __MAP_I__, 1

    .include "md.i"


    |--------------------------------------------------------------------
    | Map event id's/offsets
    |--------------------------------------------------------------------
    .equ MAP_EVENT_NOTHING,                           0x00
    .equ MAP_EVENT_PALETTE_TRANSITION,                0x04
    .equ MAP_EVENT_CAMERA_UP_ON_HORIZONTAL_MOVEMENT,  0x08
    .equ MAP_EVENT_VERTICAL_SCROLL_LIMITS,            0x0c
    .equ MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT,             0x10
    .equ MAP_EVENT_CAMERA_TRANSITION,                 0x14
    .equ MAP_EVENT_CAMPSITE_ON_ENEMY_DEFEAT,          0x18
    .equ MAP_EVENT_NEXT_LEVEL_ON_ENEMY_DEFEAT,        0x1c
    .equ MAP_EVENT_END_GAME_ON_ENEMY_DEFEAT,          0x20
    .equ MAP_EVENT_START_WATER_ANIMATION,             0x24
    .equ MAP_EVENT_START_FEATHER_ANIMATION,           0x28
    .equ MAP_EVENT_START_BOSS_MUSIC,                  0x2c


    |--------------------------------------------------------------------
    | Define map tile data entry
    |--------------------------------------------------------------------
    .macro map_tile_data nemesis_address, load_tile_number
        .dc.l 0x40000000 | (((\load_tile_number * 0x20) & 0x3fff) << 16) | ((\load_tile_number * 0x20) & 0xc000) >> 14)
        .dc.l \nemesis_address
    .endm

    .endif
