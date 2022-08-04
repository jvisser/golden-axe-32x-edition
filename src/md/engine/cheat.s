/*
 * Cheats for debug purposes
 */

#include "patch.h"


#define CHEAT_ENEMY_HP


#ifdef CHEAT_ENEMY_HP

    /**********************************************************
     * Give all enemies 1 hp
     */
    patch_start 0x00d3d2
        move.b  #1, 0x64(%a0)
        rts
    patch_end

#endif
