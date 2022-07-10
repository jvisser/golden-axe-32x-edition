|--------------------------------------------------------------------
| Golden Axe game constants/variables and subroutine addresses
|--------------------------------------------------------------------

    |-------------------------------------------------------------------
    | Constants
    |-------------------------------------------------------------------
    .equ GAME_STATE_SEGA,           0x00
    .equ GAME_STATE_TITLE,          0x04
    .equ GAME_STATE_PLAYER,         0x08
    .equ GAME_STATE_GAME_PLAY,      0x0c
    .equ GAME_STATE_DEMO,           0x10
    .equ GAME_STATE_PROFILE,        0x14
    .equ GAME_STATE_INTERMISSION,   0x18
    .equ GAME_STATE_CAMP,           0x1c
    .equ GAME_STATE_RESULT,         0x20
    .equ GAME_STATE_END,            0x24
    .equ GAME_STATE_BEGINNER_END,   0x28
    .equ GAME_STATE_CAST,           0x2c
    .equ GAME_STATE_CREDITS,        0x30
    .equ GAME_STATE_VS,             0x34
    .equ GAME_STATE_DUEL,           0x38
    .equ GAME_STATE_NEXT_DUEL,      0x3c
    .equ GAME_STATE_GAME_OVER,      0x40


    |-------------------------------------------------------------------
    | Variables
    |-------------------------------------------------------------------
    .equ requested_game_state,      0xffffc170  | .w
    .equ current_game_state,        0xffffc172  | .w

    .equ vblank_update_flags,       0xffffc183  | .b

    .equ vdp_reg_mode1,             0xffffc114  | .w in register set command format
    .equ vdp_reg_mode2,             0xffffc116  | .w in register set command format
