/*
 * Skeleton entity patches
 */

#include "patch.h"


    /**********************************************************
     * Replace hole graphics
     */
    patch_start 0x00d5a8
        lea     (tmap_hole).l, %a6
    patch_end
