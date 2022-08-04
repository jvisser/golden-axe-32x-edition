/*
 * Intermission screen patches
 */

#include "goldenaxe.h"
#include "patch.h"
#include "marscomm.h"


    /**********************************************************
     * Skip cast and go straight to the credits
     */
    patch_start 0x005820
        moveq   #GAME_STATE_CREDITS, %d0
    patch_end
