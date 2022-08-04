/*
 * Death Bringer entity patches
 */

#include "goldenaxe.h"
#include "patch.h"


    /**********************************************************
     * Remove chair sitting sequence
     */
    patch_start 0x0119c8
        move.b  #4, 0x4c(%a0)       // Set attack mode
        .rept 7
            nop
        .endr
    patch_end
