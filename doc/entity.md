# Entity runtime

## Table of contents
1. [Structure](#structure)
   1. [Flags](#flags)
   2. [Position](#position)
   3. [Animation](#animation)
   4. [Collision](#collision)
   5. [Palette](#palette)
2. [Entity allocation area](#entity-allocation-area)
3. [Entity logic](#entity-logic)
4. [Player entities](#player-entities)
5. [Map instanced entities](#map-instanced-entities)
6. [Secondary instanced entities](#secondary-instanced-entities)
7. [Entity id's](#entity-ids)

## Structure
Runtime entity data structure.

```
    ; Struct EntityInstance  ; Total 128 bytes
        ; offset, size, name
        $00: dc.b entityId
        $02: dc.b flags1
        $03: dc.b flags3
        $04: dc.b hurtBoundsIndex
        $05: dc.b damageBoundsIndex
        $06: dc.w initValue                     ; Loaded from map
        $08: dc.w spriteBaseTileId              ; Base tile id of the entity tile data in VRAM
        $0a: dc.l metaSpriteAddress             ; Meta sprite for the current animation frame
        $0e: dc.l animationTableAddress         ; Contains pointers to meta sprite animation sequences
        $12: dc.w currentAnimationOffset
        $14: dc.b currentAnimationFrameIndex
        $15: dc.b currentAnimationFrameTime
        $16: dc.b currentAnimationFrameTimeLeft
        $17: dc.b attributeFlags                ; Basically high byte of VDPSprite.attr. Only used/usable for palette id.
        $18: dc.l entityY                       ; As 16:16 fixed point.
        $1c: dc.l entityX                       ; As 16:16 fixed point.
        $20: dc.l baseY                         ; As 16:16 fixed point.
        $24: dc.l height                        ; As 16:16 fixed point.
        $2c .dc.l entityXIncrement              ; As 16:16 fixed point.
        $30 .dc.l baseYIncrement                ; As 16:16 fixed point.
        $34: dc.l heightIncrement               ; As 16:16 fixed point.
        $38: dc.l interactingEntityAddress      ; Set by collision detection code
        $3c: dc.l mountEntityAddress
        $44: dc.b flags2
        $6c: dc.l boundsTableAddress            ; Contains bounds for entity collision detection
        $70: dc.w currentDMAIndex
        $72: dc.w lastDMAIndex
        $74: dc.w dmaSourceBaseAddress
        $78: dc.w dmaFrameTableAddress
        $7c: dc.w mirrorAnimationTableOffset
```

### Flags
- `.flags1`: [H??? ??A?]
  - H: Hide sprite
  - A: Animation marker frame hit?
- `.flags2`: [???? ??UL]
  - L: Moving left
  - U: Moving up
- `.flags3`: [HD?? ?MK?]
  - H: Damage dealt to interacting entity
  - D: Damage received from interacting entity
  - M: Mounted
  - K: Knockdown (does not unmount if set)

### Position
- `.entityY`: The y position in the VDP sprite coordinate system. This position is `.height` adjusted. Bottom position.
  - Calculated as: `.baseY` + `.height` - `baseHeight` (=$8000) + `VDPSpriteVisibleArea.TOP` (=128) - `currentVScroll`;
- `.baseY`: The y position at the `baseHeight` of $8000.
  - This is basically Y in the map coordinate system
- `.entityX`: The X position in the VDP sprite coordinate system. Center position.
- `.baseX`: This is an implicit/derived value from `.entityX` (i.e. not stored but used here only to describe positioning more easily).
  - This is basically the map X coordinate of the entity
  - Calculated as: `.entityX` - `VDPSpriteVisibleArea.TOP` (=128) + `currentHScroll`
- `.height`: This is the current height value of the entity
- `.heightAcceleration` used to modify `.height`.
  - This is used for jumping/falling physics

In short `.entityY` and `.entityX` contain the screen coordinates. And `.baseY` and `.baseX` contain the map coordinates;

For more details on height calculations see [mapcollision.md](./mapcollision.md).

### Animation
See [entityanimation.md](entityanimation.md)

### Collision
See [entitycollision.md](./entitycollision.md)

### Palette
Palette is hardcoded by entity logic. By updating `EntityInstance.attributeFlags`.

## Entity allocation area
The `EntityBase` is an array of 64 slots allocated as follows:
- `00-01`: Player1/Player 2
- `02-09`: Map loaded entities
- `0a-3f`: Secondary instanced entities

2 Players can be instantiated at positions specified in the map.
Up to 8 entities can be instantiated from the map based on horizontal scroll advancements. See [map.md](./map.md) for details on how instancing/loading from the map works.
The map instanced entities can then spawn up to 54 additional entities such as fireballs etc.

### Code/data pointers
- `EntityBase`: **$FFD000**

## Entity logic
All entities are updated through routine `UpdateActiveEntities`.

For non player entity logic handlers bit 7 of the entity id is used to check if initialisation is needed (needed if 0).
So the single logic handler does both initialisation and normal logic.

Entities call `RemoveEntity` to de-spawn themselves.

### Code/data pointers
- `UpdateActiveEntities` routine: **$B954**
  - Updates both players through `UpdatePlayers` 
  - Map instanced: Loops over all 8 `MapEntityInstanceSlots` slots and runs `UpdateMapEntity`
  - Secondary instanced: Loops over al 54 `EntityInstanceSlots` and calls `UpdateEntity`
- `RemoveEntity` routine: **$B70E**
  - Clears `EntityInstance` in `a0` (fill with 0)
- `EntityLogicJumpTable`: **$BA72**
  - Jumps to a handler based on `.entityId`

## Player entities
At the start of the level `.entityX` and `.entityY` are loaded directly from the map. The remaining position values are calculated from this.
See [map.md](./map.md) for details.

Player entities are updated though routine `UpdatePlayers`.

### Code/data pointers
- `UpdatePlayers` routine: **$B4C4**
- `Player1Entity`: **$FFD000**
- `Player2Entity`: **$FFD080**

## Map instanced entities
Map instanced entities are loaded from the map's `MapEntityInstanceData`. See [map.md](./map.md) for details.

Only map instanced entities increase the `ActiveEnemyCount`. Some non enemies like dragons and chicken leg manually decrease the counter at instantiation time to counteract this.

### Instancing
Loaded into `MapEntityInstanceSlots` through `InstantiateMapEntities`.
See [map.md](./map.md) for details on how and what data is loaded exactly.

### Code/data pointers
- `InstantiateMapEntities` routine: **$13950**
  - See [map.md](./map.md) for details on how loading works. 
- `MapEntityInstanceSlots`: **$FFD100**
    - An 8 slot `MapEntityInstance` data area for up to 8 map loaded entity instances
- `UpdateMapEntity` routine: **$BA4C**
    - Parameters:
        - a0: `MapEntityInstance` address
    - Runs entity logic based on `MapEntityInstance.entityId`
- `ActiveEnemyCount`: **$FFC26C**

## Secondary instanced entities

These entities are (dynamically) instanced by other entities.

### Code/data pointers
- `EntityInstanceSlots`: **$FFD500**
  - 54 entry `EntityInstance`
- `UpdateEntity` routine: **$BA1A**
- `FindFreeEntitySlot` routine: **$8A8A**
  - Used to instantiate a new entity
  - _NB: This seems to skip the first and last available slot for some reason._

## Entity id's
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

