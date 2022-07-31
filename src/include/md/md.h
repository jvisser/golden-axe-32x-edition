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



/**********************************************************
 * Macros
 */

#define TILE_ADDR(tile_id)          tile_id * 0x20
#define VRAM_ADDR_SET(vram_addr)    0x40000000 | (((vram_addr) & 0x3fff) << 16) | (((vram_addr) & 0xc000) >> 14)

#endif
