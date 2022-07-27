|--------------------------------------------------------------------
| Mega Drive hardware addresses/constants etc
|--------------------------------------------------------------------

    .ifnotdef   __MD_I__
    .equ        __MD_I__, 1

    |-------------------------------------------------------------------
    | Memory map
    |-------------------------------------------------------------------
    .equ VDP_DATA,              0xc00000
    .equ VDP_CTRL,              0xc00004

    .equ Z80_BUS_REQUEST,       0xa11100
    .equ MARS_REG_BASE,         0xa15100

    .equ MARS_ROM_BANK0,        0x880000           | Fixed bank
    .equ MARS_ROM_BANK1,        0x900000           | Switchable bank, see MARS_BANK_SELECT

    .equ RAM_START,             0xff0000
    .equ RAM_SIZE,              0x010000


    |-------------------------------------------------------------------
    | Register offsets from MARS_REG_BASE
    |-------------------------------------------------------------------
    .equ MARS_ADP_CTL,          0x00
    .equ MARS_INT_CTL,          0x02
    .equ MARS_BANK_SELECT,      0x04
    .equ MARS_DMAC,             0x06

    .equ MARS_COMM0,            0x20
    .equ MARS_COMM1,            0x22
    .equ MARS_COMM2,            0x24
    .equ MARS_COMM3,            0x26
    .equ MARS_COMM4,            0x28
    .equ MARS_COMM5,            0x2a
    .equ MARS_COMM6,            0x2c
    .equ MARS_COMM7,            0x2e


    |-------------------------------------------------------------------
    | Controller inputs
    |-------------------------------------------------------------------

    .equ CTRL_UP,               0x01
    .equ CTRL_DOWN,             0x02
    .equ CTRL_LEFT,             0x04
    .equ CTRL_RIGHT,            0x08
    .equ CTRL_B,                0x10
    .equ CTRL_C,                0x20
    .equ CTRL_A,                0x40
    .equ CTRL_START,            0x80
    .equ CTRL_ABCS,             0xf0

    .endif
