/*
 * Cheats for debug purposes
 */

#include "patch.h"


//#define CHEAT_ENEMY_HP                  1
//#define CHEAT_NO_MAGIC_CONSUMPTION
//#define CHEAT_MAGIC_START_COUNT         9
//#define CHEAT_GOD_MODE


#ifdef CHEAT_ENEMY_HP

    /**********************************************************
     * Give all enemies 1 hp
     */
    patch_start 0x00d3d2
        move.b  #CHEAT_ENEMY_HP, 0x64(%a0)
        rts
    patch_end

#endif


#ifdef CHEAT_NO_MAGIC_CONSUMPTION

    /**********************************************************
     * Don't clear flask count after magic use
     */
    patch_start 0x007c5c
        nop
    patch_end

#endif


#ifdef CHEAT_MAGIC_START_COUNT

    /**********************************************************
     * Start with n amount of flasks
     */
    patch_start 0x004260
        .dc.b   CHEAT_MAGIC_START_COUNT
    patch_end

#endif


#ifdef CHEAT_GOD_MODE

    /**********************************************************
     * Can't die
     */
    patch_start 0x006ebe    // Damage
        nop
        nop
    patch_end

    patch_start 0x007d5c    // Fall death
        nop
        nop
    patch_end

#endif
