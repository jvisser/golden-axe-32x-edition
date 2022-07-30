/*
 * Golden Axe map macros/constants
 */

#ifndef __MAP_H__
#define __MAP_H__

#include "md.h"


/**********************************************************
 * Map event id's/offsets
 */
#define MAP_EVENT_NOTHING                               0x00
#define MAP_EVENT_PALETTE_TRANSITION                    0x04
#define MAP_EVENT_CAMERA_UP_ON_HORIZONTAL_MOVEMENT      0x08
#define MAP_EVENT_VERTICAL_SCROLL_LIMITS                0x0c
#define MAP_EVENT_WAIT_FOR_ENEMY_DEFEAT                 0x10
#define MAP_EVENT_CAMERA_TRANSITION                     0x14
#define MAP_EVENT_CAMPSITE_ON_ENEMY_DEFEAT              0x18
#define MAP_EVENT_NEXT_LEVEL_ON_ENEMY_DEFEAT            0x1c
#define MAP_EVENT_END_GAME_ON_ENEMY_DEFEAT              0x20
#define MAP_EVENT_START_WATER_ANIMATION                 0x24
#define MAP_EVENT_START_FEATHER_ANIMATION               0x28
#define MAP_EVENT_START_BOSS_MUSIC                      0x2c

#endif
