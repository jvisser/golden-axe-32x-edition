|--------------------------------------------------------------------
| Export golden axe symbols so they are usable by any linkable object
|--------------------------------------------------------------------

    .macro symbol name, address
        .global \name
        .equ    \name, \address
    .endm

    |-------------------------------------------------------------------
    | Variables
    |-------------------------------------------------------------------
    symbol requested_game_state,        0xffffc170  | .w
    symbol current_game_state,          0xffffc172  | .w

    symbol vblank_update_flags,         0xffffc183  | .b

    symbol vdp_reg_mode1,               0xffffc114  | .w in register set command format
    symbol vdp_reg_mode2,               0xffffc116  | .w in register set command format

    symbol ctrl_player_1,               0xffffc176  | .b
    symbol ctrl_player_1_changed,       0xffffc177  | .b
    symbol ctrl_player_2,               0xffffc178  | .b
    symbol ctrl_player_2_changed,       0xffffc179  | .b

    symbol palette_base                 0xffffc000
    symbol palette_target               0xffffc080

    |-------------------------------------------------------------------
    | Original golden axe sub routines
    |-------------------------------------------------------------------
    symbol nemesis_decompress_vram,     0x00002fc8
    symbol sound_command,               0x000035e8
    symbol vblank_int_handler,          0x00000cf6
    symbol vdp_reset,                   0x00000df6
    symbol audio_init,                  0x000034bc
    symbol palette_interpolate_full,    0x00003126
