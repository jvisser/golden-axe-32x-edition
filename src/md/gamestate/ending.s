/*
 * Game ending sequence patches
 */

#include "patch.h"


    /**********************************************************
     * End game after map 5 (instead of 7)
     */
    patch_start 0x0026d8
        .dc.w   0x0004
    patch_end
