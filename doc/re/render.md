# Rendering 

## General

### Gameplay tile data VRAM allocation
- `0000-5fff`: background
- `6000-6bff`: player
- `6c00-a7ff`: entities

### Code/data pointers
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
Map rendering is done in full 32 block (16 pixels wide/high) columns from the `TileMap` to `NametableRAMCache`.

VDP updates are done by filling `MapColumnDMABuffer` with a full 64 VDP nametable sized column (8 pixels wide/high) from `NametableRAMCache`.
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
Only if bit 0 of `VBlankUpdateFlags` is set.

In `AllocateEntitySprites` all entities are rendered front to back.

### Sorting
There is a sprite order buffer at `SpriteSortBuffer` made of of 256 `SpriteSlots`' indexed by `Entity.baseY`.
There is one slot per 2 lines so it covers the whole map range of 512 possible Y values.

```
  struct SpriteSlots
    dc.b    freeSlotIndex
    dcb.b   31,slots
```

Entities are added after screen clipping as follows:

```
  spriteSlots = SpriteSortBuffer[(entity.baseY & 0x1FF) >> 1]             // at a 2 line resolution
  spriteSlots[spriteSlots.freeSlotIndex] = entityOffset / SizeOf(Entity)  // =128
  spriteSlots.freeSlotIndex++
```

The `SpriteSortBuffer` is iterated over top to bottom (front to back). This is done because VDP sprites are rendered front to back.
For each entry with a non 0 `SpriteSlots.freeSlotIndex` the entity address for all entities in the slot is calculated back as `EntityBase + slot.slots[index] * SizeOf(Entity)` and `AllocateVDPSpritesForEntity` is called.  

### Rendering
The next step is rendering the VDP sprites to the `SpriteAttributeTableCache`.
This is done per entity in `AllocateVDPSpritesForEntity`.

The current sprite link is kept in register d7 and increased with each allocation.
`CurrentVDPSpriteAllocationAddress` contains the address to the current VDP sprite in `SpriteAttributeTableCache` during processing.

The current meta sprite address is loaded from `EntityInstance.metaSpriteAddress`.

The VDP sprite (hardware) structure:

```
  ; Struct VDPSprite
    dc.w y
    dc.b size
    dc.b link
    dc.w attr
    dc.w x
```

Is created for each `Sprite` in the `MetaSprite` as follows:

```
  VDPSprite.y = entity.entityY + Sprite.yOffset
  VDPSprite.size = Sprite.size
  VDPSprite.link = d7
  VDPSprite.attr = (entity.spriteBaseTileId + Sprite.relativePatternId) | entity.attributeFlags
  VDPSprite.x = entity.entityX + Sprite.xOffset
```

Note: Left/right orientations of the same graphics are represented by separate meta sprites instead of calculating the flipped positions.

The `SpriteAttributeTableCache` is terminated at the end of `AllocateEntitySprites`.

### Code/data pointers
- `EntityBase`: **$FFD000**
- `SpriteAttributeTableCache`: **$FFCB00**
- `AllocateEntitySprites`: **$B7F8**
- `SpriteSortBuffer`: **$FF6000**
- `AllocateVDPSpritesForEntity`: **$B8C0**
  - Parameters:
    - a0: `EntityInstance`
    - d7: Sprite link
- `CurrentVDPSpriteAllocationAddress`: **$FFC184**
  - Pointer (short) to the current VDP sprite allocation slot in `SpriteAttributeTableCache` only valid/usable when `AllocateEntitySprites` exists in the call stack.

## Palette 
Palette is always/unconditionally updated in full in `VBlankInterruptHandler` from the `DynamicPalette`.
See [palette.md](./palette.md) for more details.

### Code/data pointers
- `VDPUpdatePalette`: **$2EFE**
  - Sends the `DynamicPalette` to CRAM