# Entity animation
See [entity.md](./entity.md) for details on the `EntityInstance` structure.

## Table of contents
1. [Sprites](#sprites)
2. [Animations](#animations)
   1. [Animation table offset](#animation-table-offset)
   2. [DMA based animations](#dma-based-animations)
      1. [Initializing an animation sequence](#initializing-an-animation-sequence)
      2. [Updating an animation sequence](#updating-an-animation-sequence)
      3. [Signals and limits](#signals-and-limits)
      4. [Enabling DMA support](#enabling-dma-support)
   3. [Pre loaded animations](#pre-loaded-animations)
3. [Entity animation table addresses by type](#entity-animation-table-addresses-by-type)

## Sprites
Because the sprites used in the game are larger than the hardware supports they are composed of multiple hardware sprites.
This composition is stored in a `MetaSprite` structure.

The meta sprite structure used is as follows:
```
    ; Struct MetaSprite
      dc.b    spriteCount             ; spriteCount - 1 as this is stored dbf/dbra adjusted
      dc.b    hurtBoundsIndex         ; hurt bounds index. Index into EntityInstance.boundsTableAddress
      dc.b    damageBoundsIndex       ; damage bounds index. Index into EntityInstance.boundsTableAddress
        ; Repeat spriteCount + 1 times
        ; Struct Sprite
          dc.b    yOffset             ; Relative to EntityInstance.entityY
          dc.b    size                ; VDPSprite.size format
          dc.w    relativePatternId   ; Pattern id relative to EntityInstance.spriteBaseTileId (also contains H/V flip)
          dc.b    xOffset             ; Relative to EntityInstance.entityX
```

The sprite patternId stored in `.relativePatternId` is relative to `EntityInstance.spriteBaseTileId`. I.e. add them to get the absolute tile address.
`.relativePatternId` also contains the flip bits if applicable.

`EntityInstance.spriteBaseTileId` is set as follows:
- By the map entity load system.
  - To a tile id in the tile data pre-loaded for the entity through `MapEntityLoadGroupDescriptor`.
  - See [map.md](./map.md) for details on this
- By entity logic.
  - For DMA based animations. To the tile id for one of fixed entity DMA VRAM addresses for DMA enabled entities.
    - See [render.md](./render.md) for the VRAM memory map
    - See [Animations->Enabling DMA support](#enabling-dma-support)
  - Or manually set

The current meta sprite address is stored in `EntityInstance.metaSpriteAddress` and is either:
- Set automatically by the animation system (generally).
- Or manually set

## Animations

Animation addresses are stored in a table pointed to by `EntityInstance.animationTableAddress`. This table address is initialized by the specific entity logic.

There are two types of animations.
- **Pre loaded**: All the tile data for the animation is pre loaded in VRAM by the map loading system
- **DMA based**: Individual animation frames are transfered to VRAM via DMA

Each type of animation had its own representation:

For DMA based animation the structure is as follows:
```
    ; Struct DMAAnimation
      dc.b maxFrameIndex
      dc.b markerFrameIndex
      dc.b frameCount
      dc.b frameTime
        ; Repeat frameCount times
        dc.l  animationFrameAddress
```

```
    ; Struct DMAAnimationFrame
      dc.b  damageBoundsIndex
      dc.b  dmaIndex
      ; Struct MetaSprite           ; Meta sprite follows directly after
        ; ...
```

For pre-loaded animations the Structure is as follows:
```
    ; Struct PreLoadedAnimation
      dc.b frameCount
      dc.b frameTime
        ; Repeat frameCount times
        dc.l  metaSpriteAddress

```

Which type of animation is used is entity specific. Generally bigger enemies such as bosses and rideable entities are preloaded. 

### Animation table offset
The animation table specified in `EntityInstance.animationTableAddress` actually contains 2 tables.
1. Right facing (=H flipped)
2. Left facing

Both tables contain exactly the same animations except the `MetaSprite`'s are mirrored by adding the hflip flag to `Sprite.relativePatternId` and mirroring the offsets for all `Sprite`'s.
The right facing table at the base of `EntityInstance.animationTableAddress` is horizontally flipped.

The offset into the second table is indicated by `EntityInstance.mirrorAnimationTableOffset`. The value is set by entity logic.
This offset is added to the base animation offset if the `L` flag (#0, Left facing) is set in `EntityInstance.flags2`.

See routine `GetAnimation`.

Base animation offsets are either:
- Passed directly through register d0
- Or, retreived from `EntityInstance.currentAnimationOffset`

Depending on which animation routines the entity logic uses.

### DMA based animations
#### Initializing an animation sequence
Animations are loaded from `EntityInstance.animationTableAddress` as follows:
```
animation = GetAnimation(entity, animationOffset)

entity.currentAnimationFrameIndex = 0
entity.currentAnimationFrameTime = animation.frameTime              // Set depending on which animation routine is used
entity.currentAnimationFrameTimeLeft = animation.frameTime

animationFrame = animation.animationFrameAddress[entity.currentAnimationFrameIndex]
entity.metaSpriteAddress = &animationFrame->metaSprite
entity.currentDMAIndex = animationFrame->dmaIndex
entity.damageBoundsIndex = animationFrame->damageBoundsIndex        // Seems to be mostly set during initialization, only depending on the routine used
```

#### Updating an animation sequence
The animation update logic looks something like this:
```
animation = GetAnimation(entity, animationOffset)

// Check if next frame should be loaded/i.e. current frame time has expired
entity.currentAnimationFrameTimeLeft--
if (entity.currentAnimationFrameTimeLeft == 0)
{
  entity.currentAnimationFrameTimeLeft = animation.frameTime    // Reset frame time, sometimes entity.currentAnimationFrameTime is used depending on the animation routine used.
  entity.currentAnimationFrameIndex++;                          // Next frame
}

if (entity.currentAnimationFrameIndex >= animation.frameCount)
{
  entity.currentAnimationFrameIndex = 0;                        // Reset animation frame
}

animationFrame = animation.animationFrameAddress[entity.currentAnimationFrameIndex]

entity.metaSpriteAddress = &animationFrame.metaSprite
entity.currentDMAIndex = animationFrame.dmaIndex
entity.damageBoundsIndex = animationFrame.damageBoundsIndex     // Seems to be mostly set during initialization only, depending on the routine used
```

#### Signals and limits
Animation properties
- `.maxFrameIndex`: Indicates the frame index to stop updating the animation.
    - The animation frame is not updated to this frame
- `.markerFrameIndex`: When this frame index is reached animation marker bit A (#1) is set in `entity.flags1`. Cleared otherwise.

These properties are only used in special cases through routine `UpdateAnimationBounded`. These values are checked before updating/advancing the animation.

When not applicable they equal to the frame count (ie out of bounds).

#### Enabling DMA support
Entity animations can be fully preloaded. Or transfer their individual frames via DMA.
But only `MapEntityInstanceSlots` 0-3 and the player entity slots have DMA support.

To enable DMA an entity must set:
- Be assigned a DMA enabled entity slot
- Set `EntityInstance.dmaSourceBaseAddress` member to a valid base address containing the graphics data blob for all animation frames of the entity
- Set `EntityInstance.dmaFrameTableAddress` member to a valid table
- Call `SetEntitySpriteBaseDMATileId` when initializing the entity to set the target address.
    - The `.relativePatternId` of the `Sprite`'s are all zero based for DMA based animations. Due to there being only one frame in VRAM at a time (Although technically the system can also be used to preload frames).

Then the `AnimationFrame.dmaIndex` member of the animation used must have indices that correctly map to the specified DMA frame table.

For details on how the DMA is performed see [render.md](./render.md)

### Pre loaded animations
Pre loaded animations are simpeler. All the graphics data is pre loaded into VRAM by the map entity load system or completely pre-loaded at the start of the level.

The timing code is basically the same as described in the DMA section.
The animations are stored as a list of `MetaSprite`'s that are directly assigned to `EntityInstance.metaSpriteAddress`.

Initialization looks something like this:
```
animation = GetAnimation(entity, animationOffset)

entity.currentAnimationFrameIndex = 0
entity.currentAnimationFrameTime = animation.frameTime              // Set depending on which animation routine is used
entity.currentAnimationFrameTimeLeft = animation.frameTime

entity.metaSpriteAddress = animation.metaSpriteAddress[entity.currentAnimationFrameIndex]
```

### Code/data pointers
- `GetAnimation`: **$887E**
    - Parameters:
        - a0: Entity
        - d0: Animation offset
    - Returns:
        - a1: Animation address from `EntityInstance.animationTableAddress` adjusted for the orientation of the entity.
    - NB: There are multiple similar routines
- `SetEntitySpriteBaseDMATileId`: **$D372**: Sets the proper `.spriteBaseTileId` to the fixed DMA VRAM target for the current `MapEntityInstanceSlots` slot (0-3).
- `StartAnimation`: **$880A**: Start the animation specified in d0 and run `UpdateAnimation`.
- `UpdateAnimation`: **$8814**: Advances animation one tick
    - Does not update
      - `entity.currentAnimationFrameTime`
      - `entity.damageBoundsIndex`
    - Resets `entity.currentAnimationFrameTimeLeft` directly from `Animation.frameTime`
    - Parameters:
        - d0: animation id/index
    - Returns:
        - d2: -1 if the animation has made a full cycle. 0 otherwise.
- `UpdateAnimationBounded` **$885E**: Checks current frame against frame limits and signal indices and runs `UpdateAnimation` if cleared.
    - Sets bit A (#1) in `entity.flags1` if the current frame equals `animation.markerFrameIndex`. Clears the bit otherwise.
    - If the current frame is `animation.maxFrameIndex` does not update the animation and returns -1 in d2.
    - Parameters:
        - d0: animation id/index
    - Returns:
        - d2: -1 if animation has made a full cycle or the frame limit has been reached. 0 other wise.
- `InitAnimationEx`: **$8894** Clears `entity.currentAnimationFrameIndex` and "calls" `LoadAnimationFrameEx`
- `LoadAnimationFrameEx`: **$8898** Loads the animation frame specified in `entity.currentAnimationFrameIndex` into the entity instance.
    - Loads `entity.currentAnimationFrameTime` from `animation.frameTime`
    - Loads `entity.damageBoundsIndex` from `animationFrame.damageBoundsIndex`
    - Sets `entity.lastDMAIndex` to -1 to force a DMA update on the next `UpdateAnimation/Ex`.
- `ResetAnimationEx`: **$88C4**: Reset animation to the initial frame and call `UpdateAnimationEx`.
- `UpdateAnimationEx`: **$88CE**: Mostly the same as `UpdateAnimation` except:
    - Does update
        - `entity.currentAnimationFrameTime`
    - Resets `entity.currentAnimationFrameTimeLeft` from `entity.currentAnimationFrameTime`.
    - Updates animation timing at a normal rate but only updates the actual frame information at half rate
        - Even display frame and the entity is in the even bucket of 2 entities (checked by address bit 9)
        - Odd display frame and the entity is in the odd bucket of 2 entities (checked by address bit 9)
        - This matches the half frame DMA updates for map entities in the VBlank interrupt handler.
- `FrameCounter`: **$FFC17A.w**

## Entity animation table addresses by type
- Ax: **$3A350**
- Tyris: **$3D41A**
- Gilius: **$3BCB0**
- Heninger: **$43656**
- Longmoan: **$71F72**
- Amazon: **$790D2**
- Skeleton: **$3ED06**
- ...