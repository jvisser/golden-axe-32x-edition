# Entity runtime

Runtime entity data structure.

```
    ; Struct EntityInstance     ; Total 128 bytes
        dc.b    entityId        ; Entity logic id
        dcb.b   127,*           ; Entity specific
        ...
```

## Instantiation
Up to 8 entities can be instantiated from the map based on horizontal scroll advancements. See [map.md](./map.md) for details on how instancing/loading from the map works.
The map instanced entities can then spawn up to 54 additional entities such as fireballs etc.

## Entity logic
All entities are updated through routine `UpdateActiveEntities`.

In entity logic handlers bit 7 of entity id is used to check if initialisation is needed (needed if 0).
So the single logic handler does both initialisation and normal logic.

Entities call `RemoveEntity` to de-spawn themselves.

### Entity id's
- **$00**: Nothing
- **$1e**: Blue thief
- **$27**: Death adder door
- **$28**: Level 3 door for both the "bad brothers" door and the boss door
- **$29**: Level 4 feather animation
- **$2a**: Level 2 water animation
- **$2d**: Walk to dungeon entrance cutscene
- **$2f**: Skeleton from hole
- **$31**: Heninger silver
- **$32**: Heninger purple
- **$33**: Heninger green
- **$38**: Longmoan silver
- **$39**: Longmoan purple
- **$3f**: Bad brother
- **$46**: Amazon purple
- **$4f**: Chicken leg
- ...

### Code/data pointers
- `UpdateActiveEntities` routine: **$B954**
  - Map instanced: Loops over all 8 `MapEntityInstanceSlots` slots and runs `UpdateMapEntity`
  - Entity instanced: Loops over al 54 `EntityInstanceSlots` and calls `UpdateEntity`
- `RemoveEntity` routine: **$B70E**
  - Clears `EntityInstance` in `a0` (fill with 0)
- `EntityLogicJumpTable`: **$BA72**
  - Jumps to a handler based on `.entityId`

## Map instanced entities
Map instanced entities all have a specific structure into which data from the map's `MapEntityInstanceData` is loaded.

```
    ; Struct MapEntityInstance  ; Total 128 bytes
        ; offset, size, name
        $00: dc.b entityId
        $06: dc.w unknown1                      ; ? Loaded from map
        $08: dc.w unknown2                      ; ? Loaded from map
        $18: dc.l entityY                       ; As 16:16 fixed point.
        $1c: dc.l entityX                       ; As 16:16 fixed point.
        $20: dc.l baseY                         ; As 16:16 fixed point.
        $24: dc.l height                        ; As 16:16 fixed point.
        $34: dc.l heightAcceleration            ; As 16:16 fixed point.
```
_NB: Probably all sprite based entities use this structure (Player entities follow the same structure)_

Only map instanced entities increase the enemy counter. Some non enemies like dragons and chicken leg manually decrease the enemy counter at instantiation time to counteract this.

### Loading
Loaded into `MapEntityInstanceSlots` through `InstantiateMapEntities`.
See [map.md](./map.md) for details on how and what data is loaded exactly.

### Position
- `.entityY`: The y position in the VDP sprite coordinate system. This position is `.height` adjusted. At the bottom.
  - Calculated as: `.baseY` + `.height` - `baseHeight` (=$8000) + `VDPSpriteVisibleArea.TOP` (=128) - `currentVScroll`;
- `.baseY`: The y position at the `baseHeight` of $8000.
  - This is basically Y in the map coordinate system
- `.entityX`: The X position in the VDP sprite coordinate system. At the center.
- `.baseX`: This is an implicit/derived value from `.entityX` (i.e. not stored but used here only to describe positioning more easily).
  - This is basically the map X coordinate of the entity
  - Calculated as: `.entityX` - `VDPSpriteVisibleArea.TOP` (=128) + `currentHScroll`
- `.height`: This is the current height value of the entity
  - At instantiation time this is sampled from the height map at `(.baseY, .baseX)`;
- `.heightAcceleration` used to modify `.height`.
  - This is used for jumping/falling physics

In short `.entityY` and `.entityX` contain the screen coordinates. And `.baseY` and `.baseX` contain the map coordinates;

For more details on height calculations see [mapcollision.md](./mapcollision.md).

### Code/data pointers
- `InstantiateMapEntities` routine: **$13950**
  - See [map.md](./map.md) for details on how loading works. 
- `MapEntityInstanceSlots`: **$FFD100**
    - An 8 slot `MapEntityInstance` data area for up to 8 map loaded entity instances
- `UpdateMapEntity` routine: **$BA4C**
    - Parameters:
        - a0: `MapEntityInstance` address
    - Runs entity logic based on `MapEntityInstance.entityId` 

## Secondarily instanced entities

These entities are (dynamically) instanced by other entities.

### Code/data pointers
- `EntityInstanceSlots`: **$FFD500**
  - Basically a direct continuation of `MapEntityInstanceSlots`
  - 54 entry `EntityInstance`
- `UpdateEntity` routine: **$BA1A**
- `FindFreeEntitySlot` routine: **$8A8A**
  - Used to instantiate a new entity
  - _NB: This seems to skip the first and last available slot for some reason._

## Player entities
Have the same structure as map entities.

### Code/data pointers
- `Player1Entity`: **$FFD000**
- `Player2Entity`: **$FFD080**
