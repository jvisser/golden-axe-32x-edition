|--------------------------------------------------------------------
| Render the title background using the 32X
|--------------------------------------------------------------------

    .include "goldenaxe.i"
    .include "mars.i"
    .include "marscomm.i"
    .include "patch.i"


    .equ    title_palette_dark, 0x015be0


    |-------------------------------------------------------------------
    | Disable loading the MD version of the title background
    |-------------------------------------------------------------------
    patch_start 0x003ff4
        nop
        nop
    patch_end

    patch_start 0x004004
        moveq   #0x3f, %d5
        moveq   #0x3f, %d6
        bsr     name_table_clear_rect.w
    patch_end

    patch_start 0x00401c
        nop
        nop
    patch_end


    |-------------------------------------------------------------------
    | Load the background on the 32X
    |-------------------------------------------------------------------
    patch_start 0x00406e
        jsr     game_state_handler_title_init.l
    patch_end

    game_state_handler_title_init:
        move.l  %a0, -(%sp)
        lea     (img_title_background), %a0
        jsr     mars_comm_image_fade_in
        movea.l (%sp)+, %a0

        jmp     sound_command


    |-------------------------------------------------------------------
    | Update vertical scroll for the background on the 32X
    |-------------------------------------------------------------------
    patch_start 0x0040ac
        jmp     game_state_handler_title_update_v_scroll.l
    patch_end

    game_state_handler_title_update_v_scroll:
        move.w  %d0, (vdp_vertical_scroll_plane_b)
        neg     %d0
        jsr     mars_comm_vertical_scroll
        rts


    |-------------------------------------------------------------------
    | Background palette fade
    |-------------------------------------------------------------------
    patch_start 0x004174
        jmp     game_state_handler_title_fade_palette_step.l
    patch_end

    game_state_handler_title_fade_palette_step:

        | d0 is fade down palette index at this point
        move.w  %d0, -(%sp)
        move.w  %d1, -(%sp)

        | Create subtract color (same value for each color component)
        lsr.w   #1, %d0
        addq.w  #2, %d0
        move.w  %d0, %d1
        lsl.w   #5, %d1
        or.w    %d1, %d0
        lsl.w   #5, %d1
        or.w    %d1, %d0

        jsr     mars_comm_palette_subtract

        move.w  (%sp)+, %d1
        move.w  (%sp)+, %d0

        movea.l (%a0), %a6
        jsr     palette_update_dynamic

        rts


    |-------------------------------------------------------------------
    | Set dark background palette
    |-------------------------------------------------------------------
    patch_start 0x003ab2
        jsr     game_state_handler_title_set_dark_palette.l
    patch_end

    game_state_handler_title_set_dark_palette:
        move.w  #0x294a, %d0                    | No need to save d0 here
        jsr     mars_comm_palette_subtract

        lea     (title_palette_dark).l, %a6     | Prepare palette_update_dynamic call
        rts