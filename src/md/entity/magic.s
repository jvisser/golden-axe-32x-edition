/*
 * Magic effect patches
 */

#include "entity.h"
#include "patch.h"


    /**********************************************************
     * Map specific code patches due to the change in map order (map 5 = map 4)
     *
     * Restore tile data
     */
    patch_start 0x008db4
        .dc.w   0x0004
    patch_end

    // Death Adder ground sentry tile data load
    patch_start 0x008dd6
        .dc.w   0x0004
    patch_end

    // Death Adder explosion tile data load
    patch_start 0x008e34
        .dc.w   0x0004
    patch_end


    /**********************************************************
     * Tyris level 6 magic patches
     *
     * Skip palette fades
     */

    // Fadeout
    patch_start 0x008fcc
        bra     0x009000
    patch_end

    // Fade in
    patch_start 0x008db6
        bra     0x008dd4
    patch_end
