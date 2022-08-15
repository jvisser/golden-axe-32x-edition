/*
 * Complete replacement of the town door entity
 */

#include "goldenaxe.h"
#include "entity.h"
#include "patch.h"


    /**********************************************************
     * Replace logic
     */
    patch_start 0x00b0aa
        jmp     logic_entity_town_door
    patch_end

    logic_entity_town_door:
        subq.b  #1, entity_animation_frame_time_left(%a0)
        bcc     .exit

        // Next frame
        moveq   #0, %d0
        move.b  entity_animation_frame_index(%a0), %d0
        addq.b  #1, entity_animation_frame_index(%a0)

        lea     (door_animation_table), %a1
        add.w   %d0, %d0
        adda.l  %d0, %a1
        adda.l  %d0, %a1
        adda.l  %d0, %a1
        movea.l (%a1)+, %a6
        move.w  #12, %d5
        move.w  #11, %d6
        move.l  #VRAM_ADDR_SET(VDP_NAME_TBL_B + (124 * 2 + 13 * 128)), %d7  // Bad brother door
        tst.b   entity_data(%a0)
        beq     .bad_bro_door
        move.l  #VRAM_ADDR_SET(VDP_NAME_TBL_B + (166 * 2)), %d7             // Bitter/Death Adder jr door
    .bad_bro_door:
        jsr     name_table_update_rect_safe

        move.w  (%a1), %d0
        beq     .done
        move.b  %d0, entity_animation_frame_time_left(%a0)

    .exit:
        rts

    .done:
        jsr     remove_entity
        rts


    .section .rodata

    .balign 2

    door_animation_table:
        .dc.l   tmap_towndoor_1
        .dc.w   5
        .dc.l   tmap_towndoor_2
        .dc.w   12
        .dc.l   tmap_towndoor_1
        .dc.w   6
        .dc.l   tmap_towndoor_0
        .dc.w   0
