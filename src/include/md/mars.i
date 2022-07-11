|--------------------------------------------------------------------
| 32X hardware addresses/constants etc
|--------------------------------------------------------------------

    .ifnotdef   __MARS_I__
    .equ        __MARS_I__, 1

    |-------------------------------------------------------------------
    | 32x boot ROM response codes
    |-------------------------------------------------------------------
    .equ M_OK,                  0x4d5f4f4b
    .equ S_OK,                  0x535f4f4b


    |-------------------------------------------------------------------
    | Memory map
    |-------------------------------------------------------------------
    .equ MARS_ROM_BANK0,        0x880000           | Fixed bank
    .equ MARS_ROM_BANK1,        0x900000           | Switchable bank, see MARS_BANK_SELECT

    .equ MARS_REG_BASE,         0xa15100


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

    .endif
