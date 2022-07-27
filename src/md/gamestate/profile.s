|--------------------------------------------------------------------
| Character profile patches
|--------------------------------------------------------------------

    .include "goldenaxe.i"
    .include "md.i"
    .include "patch.i"
    .include "marscomm.i"


    |-------------------------------------------------------------------
    | Change end screen transition from palette fade out to arcade transition
    |-------------------------------------------------------------------
    patch_start 0x005494
        bsr     screen_transition_to_dark.w
    patch_end


    |-------------------------------------------------------------------
    | Show death adder profile
    |-------------------------------------------------------------------
    patch_start 0x0054a8
        jsr     game_state_handler_profile_end.l
        nop
    patch_end

    game_state_handler_profile_end:
        lea     (img_death_adder), %a0
        jsr     mars_comm_image
        jsr     screen_transition_from_dark
    
        | Show death adder profile for 5 seconds or until the player presses an action button
        move.w  #5*60, %d1
    1:  move.w  #VBLANK_UPDATE_CONTROLLER, %d0
        jsr     vdp_vsync_wait

        move.b  (ctrl_player_1_changed), %d0
        or.b    (ctrl_player_2_changed), %d0
        andi.b  #CTRL_ABCS, %d0
        bne     .exit_profile
        dbf     %d1, 1b
    .exit_profile:
        
        jsr     screen_transition_to_dark
        jsr     vdp_clear_palette
        
        clr.b   (demo_index)
        move.w  #GAME_STATE_TITLE, %d0
        rts
