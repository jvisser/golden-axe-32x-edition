# Rendering 

## Table of contents
1. [General](#general)
   1. [Gameplay VRAM allocation](#gameplay-vram-allocation)
2. [Map rendering](#map-rendering)
   1. [Map data](#map-data)
   2. [VDP data/updates](#vdp-dataupdates)
3. [Sprite rendering](#sprite-rendering)
   1. [Sorting](#sorting)
   2. [Rendering](#rendering-1)
   3. [Updating sprite tiles](#updating-sprite-tiles)
      1. [Entity DMA addresses](#entity-dma-addresses)
4. [Palette](#palette)

## General

### Gameplay VRAM allocation
- `$0000-$97FF`: Background + Non DMA enabled entities (Usable in map entity slot 4-7)
- `$9800-$9BFF`: Map entity slot 0 DMA target: 32 tiles ($400 bytes)
- `$9C00-$9FFF`: Map entity slot 1 DMA target: 32 tiles ($400 bytes)
- `$A000-$A3FF`: Map entity slot 2 DMA target: 32 tiles ($400 bytes)
- `$A400-$A7FF`: Map entity slot 3 DMA target: 32 tiles ($400 bytes)
- `$A800-$AA7F`: Sprite attribute table
- `$AC00-$AC03`: Horizontal scroll table (only plane based scrolling used)
- `$AA80-$B3FF`: Hud/Font
- `$B400-$B9FF`: player1: 48 tiles ($600 bytes)
- `$BA00-$BFFF`: player1: 48 tiles ($600 bytes)
- `$C000-$DFFF`: Scroll A name table
- `$E000-$FFFF`: Scroll B name table

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

VDP updates are done by filling `MapColumnDMABuffer` with a full 64 VDP nametable entry sized (128 bytes) column (8 pixels wide/high) from `NametableRAMCache`.
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

The current meta sprite address is loaded from `EntityInstance.metaSpriteAddress`. See [entityanimation.md](./entityanimation.md) for details on the `MetaSprite` structure.


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

### Updating sprite tiles
The 2 player entity slots and the first 4 map entity slots are DMA enabled.
Player entities are updated at full frame rate.

Map entities are updated at half frame rate.
- Even frames: Entity 0-1
- Odd frames: Entity 2-3

The table pointed to by `EntityInstance.dmaFrameTableAddress` contains pointers to lists of `DMATransfer` structs.
The table functions as a dictionary into the tile data pointed to by `EntityInstance.dmaSourceBaseAddress`.

```
  ; Struct DMATransfer
    dc.w dmaLength        // In words
    dc.w sourceOffset     // Offset relative to EntityInstance.dmaSourceBaseAddress
```
The list is terminated by any negative value of `.dmaLength`.

The update process looks something like this per entity.
```
void DoEntityDMA(Entity* entity, u8* targetVRAMAddress)
{
  if (entity->currentDMAIndex != entity->lastDMAIndex)
  {
    entity->lastDMAIndex = entity->currentDMAIndex;

    DMATransfer *dmaTransfer = &entity->dmaFrameTableAddress[entity.currentDMAIndex];
    while (dmaTransfer->dmaLength > 0) // Should never be zero though (which means $10000)
    {
      u32 sourceAddress = entity.dmaSourceBaseAddress + dmaTransfer.sourceOffset;

      doVRAMDMATransfer(sourceAddress, targetVRAMAddress, dmaTransfer.dmaLength);

      targetVRAMAddress += dmaLength * 2;

      *dmaTransfer++;
    }
  }
}
```

`EntityInstance.currentDMAIndex` is updated by the animation system. When changed a DMA transfer will be automatically handled by the system.
See [entityanimation.md](entityanimation.md) for more details.

The entity selects it's VRAM target address at initialization time by calling `SetEntitySpriteBaseDMATileId` which selects the target VRAM address based on the entity's slot index.

#### Entity DMA addresses
- Ax: (Init address **$86B6**)
  - `.dmaSourceBaseAddress`: **$44B98**
  - `.dmaFrameTableAddress`: **$4492E**
- Tyris: (Init address **$86B6**)
  - `.dmaSourceBaseAddress`: **$607A6**
  - `.dmaFrameTableAddress`: **$60570**
- Gilius: (Init address **$86B6**)
  - `.dmaSourceBaseAddress`: **$4FDA2**
  - `.dmaFrameTableAddress`: **$4FB58**
- Heninger: (Init address **$E762**)
  - `.dmaSourceBaseAddress`: **$69340**
  - `.dmaFrameTableAddress`: **$69166**
- Longmoan: (Init address **$F82C**)
  - `.dmaSourceBaseAddress`: **$6D772**
  - `.dmaFrameTableAddress`: **$6D5E0**
- Amazon: (Init address **$11040**)
  - `.dmaSourceBaseAddress`: **$FF8000**
    - Amazon graphics data is Nemesis compressed and is always decompressed to this address when starting a level.
    - Probably to be able squeeze everthing in the 512KB ROM space.
      - See all usages of `DecompressTileDataToRAM`. All except the one for the sega logo...
  - `.dmaFrameTableAddress`: **$7A08E**
- Skeleton: (Init address **$D608**)
  - `.dmaSourceBaseAddress`: **$59BEC**
  - `.dmaFrameTableAddress`: **$59A42**

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
- `DoEntityDMA` routine: **$8A40**
- `VBlankProcessDMA` routine: **$89CA**
- `SetEntitySpriteBaseDMATileId`: **$D372**: Sets the proper `.spriteBaseTileId` to the fixed DMA VRAM target for the current `MapEntityInstanceSlots` slot (0-3).

## Palette 
Palette is always/unconditionally updated in full in `VBlankInterruptHandler` from the `DynamicPalette`.
See [palette.md](./palette.md) for more details.

### Code/data pointers
- `VDPUpdatePalette`: **$2EFE**
  - Sends the `DynamicPalette` to CRAM