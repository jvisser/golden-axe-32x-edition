/*
 * Amazon entity patches
 */

#include "entity.h"
#include "patch.h"


    /**********************************************************
     * Set the amazon tile data address in the entity to point to the uncompressed data in ROM
     */
    patch_start 0x011040
        move.l  #pat_amazon, entity_dma_source_base(%a0)
    patch_end

    patch_start 0x0052f8    // Cast screen entity property table entry
        .dc.l   pat_amazon
    patch_end


    /**********************************************************
     * Make the wait time for amazon 2 configurable from the map definition
     */
    patch_start 0x00f594
        move.w  entity_map_init_data(%a0), 0x56(%a0)
    patch_end
