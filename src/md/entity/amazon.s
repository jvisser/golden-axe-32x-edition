/*
 * Amazon entity patches
 */

#include "entity.h"
#include "patch.h"


    /**********************************************************
     * Set the amazon tile data address in the entity to point to the uncompressed data in ROM
     */
    patch_start 0x011040
        move.l  #pat_amazon, ENTITY_DMA_SOURCE_BASE(%a0)
    patch_end

    patch_start 0x0052f8    // Cast screen entity property table entry
        .dc.l   pat_amazon
    patch_end
