/*
 * Mega Drive hardware addresses/constants etc
 */

#ifndef __MD_H__
#define __MD_H__

/**********************************************************
 * Memory map
 */

#define VDP_DATA                0xc00000
#define VDP_CTRL                0xc00004

#define Z80_BUS_REQUEST         0xa11100
#define MARS_REG_BASE           0xa15100

#define MARS_ROM_BANK0          0x880000    // Fixed bank
#define MARS_ROM_BANK1          0x900000    // Switchable bank see MARS_BANK_SELECT

#define RAM_START               0xff0000
#define RAM_SIZE                0x010000


/**********************************************************
 * Register offsets from MARS_REG_BASE
 */

#define MARS_ADP_CTL            0x00
#define MARS_INT_CTL            0x02
#define MARS_BANK_SELECT        0x04
#define MARS_DMAC               0x06

#define MARS_COMM0              0x20
#define MARS_COMM1              0x22
#define MARS_COMM2              0x24
#define MARS_COMM3              0x26
#define MARS_COMM4              0x28
#define MARS_COMM5              0x2a
#define MARS_COMM6              0x2c
#define MARS_COMM7              0x2e


/**********************************************************
 * Controller inputs
 */

#define CTRL_UP                 0x01
#define CTRL_DOWN               0x02
#define CTRL_LEFT               0x04
#define CTRL_RIGHT              0x08
#define CTRL_B                  0x10
#define CTRL_C                  0x20
#define CTRL_A                  0x40
#define CTRL_START              0x80
#define CTRL_ABCS               0xf0

#define B_CTRL_UP               0
#define B_CTRL_DOWN             1
#define B_CTRL_LEFT             2
#define B_CTRL_RIGHT            3
#define B_CTRL_B                4
#define B_CTRL_C                5
#define B_CTRL_A                6
#define B_CTRL_START            7


/**********************************************************
 * VDP
 */

#define VDP_SPRITE_SIZE

#define VDP_SPRITE_SIZE_H1_V1           0x00
#define VDP_SPRITE_SIZE_H2_V1           0x04
#define VDP_SPRITE_SIZE_H3_V1           0x08
#define VDP_SPRITE_SIZE_H4_V1           0x0c
#define VDP_SPRITE_SIZE_H1_V2           0x01
#define VDP_SPRITE_SIZE_H2_V2           0x05
#define VDP_SPRITE_SIZE_H3_V2           0x09
#define VDP_SPRITE_SIZE_H4_V2           0x0d
#define VDP_SPRITE_SIZE_H1_V3           0x02
#define VDP_SPRITE_SIZE_H2_V3           0x06
#define VDP_SPRITE_SIZE_H3_V3           0x0a
#define VDP_SPRITE_SIZE_H4_V3           0x0e
#define VDP_SPRITE_SIZE_H1_V4           0x03
#define VDP_SPRITE_SIZE_H2_V4           0x07
#define VDP_SPRITE_SIZE_H3_V4           0x0b
#define VDP_SPRITE_SIZE_H4_V4           0x0f

#define VDP_ATTR_TILE_ID(tile_id)       ((tile_id) & 0x7ff)
#define VDP_ATTR_HFLIP                  0x0800
#define VDP_ATTR_VFLIP                  0x1000
#define VDP_ATTR_PAL0                   0x0000
#define VDP_ATTR_PAL1                   0x2000
#define VDP_ATTR_PAL2                   0x4000
#define VDP_ATTR_PAL3                   0x6000
#define VDP_ATTR_PRIO                   0x8000

#define TILE_ADDR(tile_id)              ((tile_id) * 0x20)
#define VRAM_ADDR_SET(vram_addr)        (0x40000000 | (((vram_addr) & 0x3fff) << 16) | (((vram_addr) & 0xc000) >> 14))

#define PALETTE_OFFSET(palette, color)  ((palette) * 0x20 + (color) * 2)

/**********************************************************
 * General macros
 */

#define LOW_BYTE(value)                 ((value) & 0xff)
#define HIGH_BYTE(value)                (((value) >> 8) & 0xff)

#endif
