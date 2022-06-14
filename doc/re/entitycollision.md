# Entity collision
See [entity.md](./entity.md) for details on the `EntityInstance` structure.

See [entityanimation.md](./entityanimation.md) for details on the `MetaSprite` structure.

Entity collision bounds are stored in a separate table referenced by `EntityInstance.boundsTableAddress` where each entry has the following format:
```
    ; Struct EntityBounds
       dc.w xOffset ; Relative to Entity.entityX (negative for left)
       dc.w width
       dc.w yOffset ; Relative to Entity.entityY (negative for top)
       dc.w height
```
`EntityInstance.boundsTableAddress` is initialized by entity logic.

To get the bounds address do `EntityInstance.boundsTableAddress + boundsIndex * SizeOf(EntityBounds) (=8)`

Each entity has both damage bounds `.damageBoundsIndex` (used to deal damage) and hurt bounds `.hurtBoundsIndex` (used to receive damage) indices into `EntityInstance.boundsTableAddress`.
They are sourced from:
- `MetaSprite`: for both types.
- `AnimationFrame`: only `.damageBoundsIndex`.

The entity bounds indices are updated like this:
- Always: When rendering the `MetaSprite` referenced in `EntityInstance.metaSpriteAddress` in routine `AllocateVDPSpritesForEntity` (See [render.md](./render.md)) both bounds indices are copied from the `MetaSprite` into the `EntityInstance`.
- Sometimes: When loading a new animation frame only `EntityInstance.damageBoundsIndex` is copied from `AnimationFrame.damageBoundsIndex`.
    - Depending on which animation routines are used (not sure what the purpose is atm other than maybe preventing delayed processing of damage by one frame)

The actual collision checks are then performed via the `EntityInstance`.

## Collision checks

All entity<->player collision checks are performed in screen space and initiated by the entities.

The player screenspace bounds are precalculated once per frame in `WritePlayerBounds` by adding the `EntityBounds` to player's screen base position of `(EntityInstance.entityX, EntityInstance.entityY)`.
The bounds are written to:
- **$CE80**: Player 1 hurt bounds
- **$CE88**: Player 1 damage bounds
- **$CF00**: Player 2 hurt bounds
- **$CF08**: Player 2 damage bounds

All entity<->player collision checks use these precalculated bounds values.
Entities call one of the `Check*Collision` routines to do the collision checks against the players.

### Code/data pointers
- `WritePlayerBounds`: **$C184**
  - Parameters:
    - a0: The player entity
- `CheckPlayerCollision`: **$BF62**
  - Tests (in that order):
    1. If the player damages entity: If the entity's hurt box intersects with the player's damage box.
    2. If the entity damages the player: If the entity's damage box intersects with the player's hurt box.
  - Parameters:
    - a0: The entity
    - a3: The player entity
    - d2: Required closeness in y (depth) direction in pixels at sea level (using `EntityInstance.baseY`)
      - Fat enemies use bigger value.
- `CheckTwoPlayerCollision`: **$BF4A**
  - Checks collision against both players. Player one has priority.
  - Parameters:
    - a0: The entity
    - d2: Required closeness in y (depth) direction in pixels at sea level (using `EntityInstance.baseY`)
      - Fat enemies use bigger value.
- `CheckTwoPlayerCollisionDefaultCloseness`
  - Calls `CheckTwoPlayerCollision` with closeness value of 8px.
