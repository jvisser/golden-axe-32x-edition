# Rendering 

## Code/data pointers
- `VBlankInterruptHandler`: **$CF6**
- `VBlankUpdateFlags`: **$FFC183**
    - bit 0: 1 = update sprites
    - bit 1: 1 = read controllers and run game mode specific vblank routine

## Map rendering

### Map data 
The tile map is decompressed in RAM to `TileMap` 
This is a 128x32 byte buffer. This contains the complete map. The buffer size limits the map size to 2048x512.

Each byte in the tile map buffer is a block id. Blocks are stored as 4 words in plain VDP [nametable format](https://plutiedev.com/tile-id). Stored in the following manner (number = offset):
```
01
23
```  

The block data base address is stored in `BlockDataBaseAddress` which is ultimately loaded from `MapDescriptor.graphicsBlockDataAddress`
To get the block data address add `blockId * 8` to the stored address.

### VDP data/updates
The game uses a 64x64 nametable. There is a RAM cache `NametableRAMCache`. 
Map rendering is done in full 64 block (16 pixels wide) columns from the `TileMap` to `NametableRAMCache`.

VDP updates are done by filling `MapColumnDMABuffer` with a full 64 VDP nametable sized column (8 pixels wide) from `NametableRAMCache`.
This DMA data is then sent in `VBlankInterruptHandler`.

### Code/data pointers
- `UpdateMap` routine: **$E70**
  - Renders the map to the nametable and prepares column data VDP DMA
- `TileMap`: **$FF4000**
- `BlockDataBaseAddress`: **$FFC214**
- `NametableRAMCache`: **$FF0000**
  - 64x64 word nametable RAM cache
- `MapColumnDMABuffer`: **$FFF000**
  - 64 word DMA buffer

## Sprite rendering
There is a sprite attribute table RAM cache `SpriteAttributeTableCache` which gets DMA'ed in full in `VBlankInterruptHandler` using hardcoded DMA set commands (See **$D16**).
Only if bit 0 of `VBlankUpdateFlags` is set

### Code/data pointers
- `SpriteAttributeTableCache`: **$FFCB00**
- `CurrentVDPSpriteAllocationAddress`: **$FFC184**
  - Pointer to the current VDP sprite allocation slot in `SpriteAttributeTableCache`  
- `AllocateVDPSpritesForActiveEntities`: **$B7F8**
  - Seems to allocate VDP sprites from all active entity meta sprites. Not sure how it exactly works.
  - d7 contains the sprite link during processing
- `AllocateVDPSpritesForEntity`: **$B8C0**
  - Parameters:
    - a0: `EntityInstance`
    - d7: Sprite link
    - ?
  - Seems to allocate all VDP sprites for the specified entity

## Palette 
Palette is always/unconditionally updated in full in `VBlankInterruptHandler` from the `DynamicPalette`.
See [palette.md](./palette.md) for more details.

### Code/data pointers
- `VDPUpdatePalette`: **$2EFE**
  - Sends the `DynamicPalette` to CRAM