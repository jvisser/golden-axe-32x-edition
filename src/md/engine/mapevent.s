/*
 * Map event system patches
 */

#include "patch.h"
#include "marscomm.h"
#include "goldenaxe.h"
#include "entity.h"
#include "map.h"


    /**********************************************************
     * Event: MAP_EVENT_PALETTE_TRANSITION
     *
     * Patch palette transition event to run on the 32X
     */
    patch_start 0x001da8
        jmp     map_event_palette_transition
    patch_end

    map_event_palette_transition:
        move.w  #0x0100, %d0                // Request transition
        move.b  map_event_data(%a0), %d0    // Set target palette index

        clr.w   map_event_id(%a0)           // Unregister event immediately

        mars_comm_call_start
        mars_comm_p1 MARS_COMM_SLAVE, MARS_COMM_CMD_MAP_PALETTE, %d0
        mars_comm_call_end
        rts


    /**********************************************************
     * Event: MAP_EVENT_CHANGE_MUSIC
     *
     * Turn original event MAP_EVENT_START_BOSS_MUSIC into a generic play music event
     */
    patch_start 0x001f30
        jsr     map_event_change_music.l
        nop
    patch_end

    #define fade_count_down 0xffffc24b      // Used here only

    map_event_change_music:
        move.b  map_event_data(%a0), %d7    // Get song id from event
        clr.w   map_event_id(%a0)           // Unregister event
        clr.b   (fade_count_down)
        rts


    /**********************************************************
     * Event: MAP_EVENT_SPAWN_ENTITY
     *
     * Turn original event MAP_EVENT_START_WATER_ANIMATION into a generic entity spawner
     */
    patch_start 0x001ec0
        jmp     map_event_spawn_entity.l
    patch_end

    map_event_spawn_entity:
        jsr     find_free_entity_slot
        move.b  map_event_data(%a0), entity_id(%a5)
        clr.w   map_event_id(%a0)           // Unregister event
        rts


    /**********************************************************
     * Event: MAP_EVENT_SCROLL_LOCK
     *
     * Load parameter address from the current map's extended event data table
     */
    patch_start 0x001e9c
        movea.l (map_extended_event_data_table).l, %a1
        adda.w  %d0, %a1
        movea.l (%a1), %a1
    patch_end


    /**********************************************************
     * Event: MAP_EVENT_VERTICAL_SCROLL_LIMITS
     *
     * Load parameter address from the current map's extended event data table
     */
    patch_start 0x001d90
        movea.l (map_extended_event_data_table).l, %a1
        adda.w  %d0, %a1
        movea.l (%a1), %a1
        nop
    patch_end


    /**********************************************************
     * Event: MAP_EVENT_CAMERA_TRANSITION
     *
     * Load parameter address from the current map's extended event data table
     */
    patch_start 0x001e08
        movea.l (map_extended_event_data_table).l, %a1
        adda.w  %d0, %a1
        movea.l (%a1), %a1
        nop
    patch_end
