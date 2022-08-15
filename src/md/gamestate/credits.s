/*
 * Credits patches
 */

#include "goldenaxe.h"
#include "patch.h"
#include "marscomm.h"


    /**********************************************************
     * Set 320 pixel wide display mode
     */
    patch_start 0x006616
        jsr     game_state_handler_credits_init.l
        nop
    patch_end

    game_state_handler_credits_init:
        ori     #0x0700, %sr
        jsr     vdp_disable_display
        jsr     vdp_set_mode_h40    // Game relied in display mode set by previous mode (cast in original game code)

        moveq   #SONG_CREDITS, %d7  // Sound from cast would be reused before, now we need to explicitly start it
        jmp     sound_command


    /**********************************************************
     * Allow skipping to the results by pressing an action button
     */
    #define credits_cycle 0xffffc334    // Seems to be shared by screen transition code...

    patch_start 0x0065f2
        jsr     game_state_handler_credits.l
    patch_end

    game_state_handler_credits:
        move.b  ctrl_player_1_changed, %d0
        or.b    ctrl_player_2_changed, %d0
        andi.b  #CTRL_ABCS, %d0
        beq     .exit

        move.w  #1, (credits_cycle) // Skip to the next mode (results)
    .exit:
        rts


    /**********************************************************
     * Add credits at the end
     */
    #define extended_credits_count  1
    #define current_credit_index    0xffffc33e

    .equ credits_role_table,        0x00039002
    .equ credits_name_table,        0x00039056

    .macro load_credits_table credits_type
            move.w  (current_credit_index), %d0
            cmpi.w  #0x0015, %d0
            blt     .load_base_table\@
            lea     (extended_credits_\credits_type\()_table - (0x0015 * 4)), %a1
            rts
        .load_base_table\@:
            lea     (credits_\credits_type\()_table), %a1
            rts
    .endm


    patch_start 0x006968
        .dc.w   0x0015 + extended_credits_count
    patch_end

    patch_start 0x006730
        .dc.w   0x2184 + (extended_credits_count * 0x400)
    patch_end

    patch_start 0x006ca2
        jsr     game_state_handler_credits_load_role_table.l
    patch_end

    patch_start 0x006cf6
        jsr     game_state_handler_credits_load_name_table.l
    patch_end


    game_state_handler_credits_load_role_table:
        load_credits_table role


    game_state_handler_credits_load_name_table:
        load_credits_table name


    // Credits data
    .section .rodata

    .balign 2

    extended_credits_role_table:
        .dc.l   role

    extended_credits_name_table:
        .dc.l   name

    role:
        // "32x conversion"
        .dc.b 13, 0x04, 0x03, 0x22, 0x00, 0x0d, 0x19, 0x18, 0x20, 0x0f, 0x1c, 0x1d, 0x13, 0x19, 0x18

    name:
        // "jeroen visser"
        .dc.b 12, 0x14, 0x0f, 0x1c, 0x19, 0x0f, 0x18, 0x00, 0x20, 0x13, 0x1d, 0x1d, 0x0f, 0x1c
