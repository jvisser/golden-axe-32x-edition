/*
 * Dragon entity patches
 */

#include "entity.h"
#include "md.h"
#include "patch.h"


    /**********************************************************
     * Use palette 3 for the blue dragon
     */
    patch_start 0x01268a
        move.b  #HIGH_BYTE(VDP_ATTR_PAL3), entity_sprite_attr(%a0)
    patch_end
