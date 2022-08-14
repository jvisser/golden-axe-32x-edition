/*
 * Speech bubble patches
 */

#include "patch.h"
#include "md.h"


    /**********************************************************
     * Fix: Speech bubble unalligned due to map scroll
     *
     * The proper fix would have been to take the horizontal scroll value into account but as
     *  there is only one remaining instance (wilderness intro) just hardcode it for that.
     */
    patch_start 0x005644
        move.l  #VRAM_ADDR_SET(0xdffe + (8 * 2)), %d7
    patch_end
