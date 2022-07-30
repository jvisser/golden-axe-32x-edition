/*
 * Demo/attract mode patches
 */

#include "patch.h"


    /**********************************************************
     * Disable demo ending transition like the arcade version
     */
    patch_start 0x001980
        nop
        nop
    patch_end
