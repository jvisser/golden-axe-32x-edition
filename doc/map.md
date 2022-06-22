# Map

## Map descriptor format

This struct contains all data to load a level. 

```
    ; Struct MapDescriptor
    
        ; Palette data
            ; Repeat # times (until list terminator is encountered)
            dc.l partialPaletteAddress
        dc.l 0  ; List terminator
        
        ; Compressed tile data
            ; Repeat # times (until list terminator is encountered i.e. VDPAddressSetCommand == 0)
            Struct NemesisVRAMData
                dc.l vdpAddressSetCommand
                dc.l nemesisCompressedTileDataAddress
        dc.l 0  ; List terminator
        
        ; Graphics map data
        dc.l graphicsBlockDataAddress
        dc.l compressedGraphicsBlockMapDataAddress
        
        ; Map dimensions (in 16x16 blocks)
        dc.w mapHeight
        dc.w mapWidth
        
        ; Initial scroll position (in block coordinates so pixel position *= 16)
        dc.w initialVScroll
        dc.w initialHScroll
        
        ; Map events
        dc.l eventListAddress
        
        ; Height map data
        dc.l compressedHeightBlockMapDataAddress
        dc.l heightBlockDataAddress  ; NB: This is only present if compressedHeightBlockMapDataAddress is non null!
        
        ; Entity load data
        dc.l entityLoadData
        
        ; Player entity initialisation
        dc.w player1.baseYOffset
        dc.w player1.entityX
        dc.w player2.baseYOffset
        dc.w player2.entityX
        
        ; Music
        dc.w musicId
```

Details
1. [Palette data](#palette-data)
2. [Compressed tile data](#compressed-tile-data)
3. [Graphics map data](#graphics-map-data)
4. [Map events](#map-events)
5. [Height map data](#height-map-data)
6. [Entity load data](#entity-load-data)
7. [Player entity initialisation](#player-entity-initialisation)
8. [Music](#music)

### Code/data pointers
- `MapDescriptorAddressTable`: **$15AC**
    - Contains entries for the following maps using long pointers pointing to `MapDescriptor`'s:
      - Level1
      - Level2
      - Level3
      - Level4
      - Level5
      - Level6
      - Level7
      - Level8
      - Duel
      - Ending
      - Demo1
- `LoadMap` routine: **$14FE**
    - Parameters:
        - d0: Offset into `MapDescriptorAddressTable` (not index! thus in increments of 4)
- `LoadMapSelectedLevel` routine: **$14FE**
    - Calls LoadMap with `MapDescriptorAddressTable` index based on current level as indicated by **$FFFE2C.w**

## Details

### Palette data
Palette data is stored as a null terminated list of pointers to `PartialPalette` structures these are loaded into the `BasePalette`. See [palette.md](./palette.md) for more details.

### Compressed tile data
Tile data is stored as a list Nemesis compressed blocks. These are directly decompressed to VRAM. The target VRAM address is set by writing `NemesisVRAMData.vdpAddressSetCommand` to the VDP control port. See [compression.md](./compression.md) for more details.
 
### Graphics map data
Maps are stored using tilemaps where each byte (=blockId) in the tilemap points to a 16x16 pixel block.
Blocks are stored as 4 words in plain VDP [nametable format](https://plutiedev.com/tile-id). Stored in the following manner (number = offset):
```
01
23
```

The block data is uncompressed and can be read directly from address `graphicsBlockDataAddress` + `blockId * 8`.

The tilemap is compressed using a custom compression scheme as described in [compression.md](./compression.md).
The tilemap is decompressed into a fixed 128x32 byte buffer `TileMap` in RAM.  

#### Code/data pointers
- `TileMap`: **$FF4000**
  - Decompressed background tilemap

### Map events
Each map can have triggers for things like palette transitions. These are stored in the following format:

```
    ; Struct MapEventTriggerList
        ; # entries not terminated (runtime terminated by out of bounds hScrollTrigger)
        ; Struct MapEventTrigger
            dc.w hScrollTrigger
            ; Struct MapEvent
                dc.b id
                dc.b data 
```

When the map is scrolling the current horizontal scroll value is compared to `NextMapEventTrigger->hScrollTrigger` to determine if the event is to be activated.
See [mapevents.md](./mapevents.md) for more details on map events.

#### Code/data pointers
- `CheckMapEventTrigger` routine: **$1CD2**
    - Checks if the scroll value matches the trigger position if so activates the event by adding it to a free slot in `MapEventQueue`.
- `NextMapEventTrigger`: **$FFC22A**
    - Pointer to next `MapEventTrigger`

### Height map data
Height data is stored like the graphics map with a compressed tilemap in the same format and of the same size but pointing to height blocks instead of graphics blocks.

Height blocks consist of 4 words where each word is a height value (8x8 pixel resolution). The `baseHeight` value is $8000.
Lower values are up, higher values down.

For more details see [mapcollision.md](./mapcollision.md).

#### Code/data pointers
- `HeightTileMap`: **$FF5000**

### Entity load data
Entity spawn points are stored in the following format 

```
    ; Struct MapEntityLoadTriggerList
        ; # entries either terminated by -1 .hScrollTrigger or by out of bounds .hScrollTrigger
        ; Struct MapEntityLoadTrigger
            dc.w hScrollTrigger
            dc.w loadIndex      ; not offset
```

When the map is scrolling the current horizontal scroll value is compared to `NextMapEntityLoadTrigger->hScrollTrigger` to determine if the entity group is to be loaded. 
This is checked in routine `CheckMapEntityLoadTrigger`. When the trigger activates, the `loadIndex` is used to load the address of the `MapEntityLoadSlotDescriptor` struct from `MapEntityLoadSlotDescriptorTable`.

```
    ; Struct MapEntityLoadSlotDescriptor
        dc.w numLoadSlots                       ; numLoadSlots - 1 as this is stored dbf/dbra adjusted
            ; Repeat numLoadSlots + 1 times
            dc.l mapEntityLoadGroupDescriptorAddress
```

The `MapEntityLoadGroupDescriptor` addresses are then loaded into `MapEntityLoadSlots` in RAM. 
From which the actual instantiation of entities is done in routine `InstantiateMapEntities`.

```
    ; Struct MapEntityLoadGroupDescriptor
        dc.b canLoadWithActiveEnemies
        dc.b mapEntityGroupGraphicsOffset
        dc.w numEntities
            ; Repeat numEntities
            ; Struct MapEntityInstanceData
                dc.b entityInstanceSlot     ; MapEntityInstanceSlots index
                dc.b entityId               ; Entity logic id
                dc.w entityY                ; Entity y in map coordinate system
                dc.w entityX                ; Entity x in VDP sprite coordinate system (this means to get the position in the map coordinate system, horizontal scroll(=MapEntityLoadTrigger.hScrollTrigger) must be added and 128 must be subtracted).
                dc.w spriteBaseTileId
                dc.w initValue
```

When an `MapEntityLoadSlots` slot is loaded by routine `InstantiateMapEntities` the following happens.

If `.canLoadWithActiveEnemies` is false (zero). A check for any active enemies is made. If any are active enemies the slot is skipped (made pending).
In any other case the load slot is processed and enemies are instantiated.

Graphics are loaded for the complete group based on `.mapEntityGroupGraphicsOffset` (must be >0) which is an offset into table `MapEntityGroupGraphicsTable` (Max 64 entries, 0 is unused) which contains (long) pointers to `MapEntityGroupGraphics` structs.

```
    ; Struct MapEntityGroupGraphics
        dc.b palette1Index
        dc.b palette2Index
        ; Repeat until vramAddress = 0
        ; Struct NemesisLoad
            dc.w vramAddress
            dc.w nemesisEntityTileDataOffset
```

Any non zero `.palette*Index` is an index into `MapEntityGroupPaletteTable` which contains pointers to `PartialPalette` structs which are loaded into the base and dynamic palette.
Palette allocation is as follows in general:
- 1: Player/Hud (and some entities like thiefs)
- 2: Entities + other mutually exclusive stuff like continue sign
- 3: Entities
- 4: Background

Tile data is decompressed to `.vramAddress` which is an actual address (not a VDP address set command).
The address of the Nemesis compressed graphics is loaded from `MapEntityGroupTileAddressTable` offset by `.nemesisEntityTileDataOffset`.
Then the tiles are decompressed to VRAM. This is repeated until a `.vramAddress` of 0 is found.

The tile data loaded here is typically a full pre load of all animation frames (i.e. for non DMA animated entities).
One `NemesisLoad` entry per entity type.

Next the entities are instanced. There are 8 `EntityInstance` data slots at `MapEntityInstanceSlots` which are loaded from the `MapEntityInstanceData` structures as follows:

```
    // NB: Entity types that use DMA for their animation system must be allocated to slots 0-3
    mapEntityInstance = MapEntityInstanceSlots[mapEntityInstanceData.entityId];

    mapEntityInstance.entityId = mapEntityInstanceData.entityId;
    mapEntityInstance.baseY = mapEntityInstanceData.entityY;        // Only the integer part is loaded
    mapEntityInstance.entityX = mapEntityInstanceData.entityX;      // Only the integer part is loaded
    mapEntityInstance.initValue = mapEntityInstanceData.initValue;
    mapEntityInstance.spriteBaseTileId = mapEntityInstanceData.spriteBaseTileId

    mapEntityInstance.height = SampleHeightMap(EntityInstance.baseY, EntityInstance.baseX);
    mapEntityInstance.entityY = calculateEntityY();                 // Sprite location with height incorporated. See entity.md

    if (.entityX >= 288) // 288 = Half screen width (160 + VDPSpriteVisibleArea.TOP (=128))
    {
        mapEntityInstance.flags2 |= L //=1 Left facing
    }
```

See [entity.md](./entity.md) for details on runtime entity handling.

#### Init values
`MapEntityInstanceData.initValue` contains an entity specific init value that is copied into the entity instances `EntityInstance.initValue` field.

Known uses:
- **Thief**: Contains the number of items dropped. Bit 7 indicates green thief.

#### Special cases
- In beginner mode the level 3 trigger list is overridden with a custom version `Level3BeginnerModeEntityList` in routine `StartGameplay` at **$12FC**.
- The level 8 load slots are manually filled in routine `StartGameplay` at **$1364**.
  - The trigger list referenced in the `MapDescriptor` for level 8 is empty.
  - Not sure why this is as a `MapEntityLoadTrigger` at position 0 should do the trick.

#### Code/data pointers
- `CheckMapEntityLoadTrigger` routine: **$138FE**
    - Checks if the scroll value matches the trigger position and if so starts loading entities.
- `InstantiateMapEntities` routine: **$13950**
  - Instantiates entities from `MapEntityLoadSlots`
- `StartGameplay` routine: **$12EC**
- `Level3BeginnerModeEntityList`: **$37ACC**
  - Level 3 beginner mode trigger list
- `MapEntityLoadSlotDescriptorTable`: **$37AEE**
  - Table of `MapEntityLoadSlotDescriptor` addresses
  - This table is used for all maps
- `MapEntityGroupGraphicsTable`: **$13A98**
- `MapEntityGroupPaletteTable`: **$389E8**
- `MapEntityGroupTileAddressTable`: **$13A74**
- `MapEntityLoadSlots`: **$FFC27A**
  - An 8 slot load queue of `MapEntityLoadGroupDescriptor` addresses
- `MapEntityInstanceSlots`: **$FFD100**
  - An 8 slot 128 byte per slot data area for up to 8 entity instances
- `NextMapEntityLoadTrigger`: **$FFC26E**
  - Pointer to the next `MapEntityLoadTrigger`

### Player entity initialisation
Player follows the same runtime structure as `EntityInstance`.
- `.entityX` is loaded as is from the map.
- `.entityY` is calculated from `.entityX` as specified below.

For each `Map` there is a sorted list with the `.baseY` per horizontal map area.
```
    ; Struct MapBaseYPositionTable
        dc.w numberOfPositionChanges
        ; Repeat numberOfPositionChanges + 1
        ; Struct BaseYPositionWindow
            dc.w mapXEnd                ; End position of window
            dc.w baseY
```
There is a table with pointers to `MapBaseYPositionTable` structs at `MapBaseYPositionTableDirectory`.
There is one entry for each map indexed by the current play level.

Routine `SetEntityX` is used to recalculate all positions based on a new `.entityX` value. It looks something like this:
```
    void SetEntityX(EntityInstance *entity, u16 entityX, u16 baseYDisplacement, u16 maxEntityY)
    {
        entity->entityX = entityX;
     
        u16 *posTable = MapBaseYPositionTableDirectory[currentLevel]
        for(;;)
        {
            u16 mapX = Math.max(0, entity.entityX - 128) + hscroll
            
            // The last entry contains the default value
            BaseYPositionWindow *pos = posTable->baseYPositionWindowArray;
            for (int i = 0; i <= posTable->numberOfPositionChanges && pos->mapXEnd < mapX;  i++, pos++);
            entity->baseY = pos->baseY + baseYDisplacement;
        
            u16 height = sampleHeight(entity->baseY, mapX);
            
            if (isUnreachableHeight(height)) // 0x8200 or 0x7e00
            {
                entity->entityX -= 16;  // Search one block back
                continue;
            }
            
            entity->height = height;
            entity->entityY = entity.baseY + height - 0x8000 + 128 - vscroll;            
            
            if (entity.entityY > maxEntityY)
            {
                entity->entityX -= 16;// Search one block back
                continue;
            }
            
            break;
        }
    }
```

The final players' positions are then calculated as:
```
    SetEntityX(player1, map.player1.EntityX, map.player1.baseYOffset, 360);
    SetEntityX(player2, map.player2.EntityX, map.player1.baseYOffset, 360);
```
NB: During map loading the player's `.entityY` member is temporarily repurposed/loaded with `Map.player*.baseYOffset`.

See [entity.md](entity.md) for more details on the runtime the structure.

#### Code/data pointers
- `MapBaseYPositionTableDirectory`: **$877E**
- `Player1Entity`: **$FFD000**
- `Player2Entity`: **$FFD080**
- `InitPlayers` routine: **$13FE**
- `SetEntityX` routine: **$86FE**

### Music
Contains the song id for the map. Start playing immediately after loading the map.

#### Code/data pointers
- `SoundCommand`: **$35E8**
