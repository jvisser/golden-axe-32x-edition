# Entity collision
See [entity.md](./entity.md) for details on the `EntityInstance` structure.

See [entityanimation.md](./entityanimation.md) for details on the `MetaSprite` structure.

## Bounds

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

### Bounds types
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
- **$FFCE80**: Player 1 hurt bounds
- **$FFCE88**: Player 1 damage bounds
- **$FFCF00**: Player 2 hurt bounds
- **$FFCF08**: Player 2 damage bounds

All entity<->player collision checks use these precalculated bounds values.
Entities call one of the `Check*Collision` routines to do the collision checks against the players.

The algorithm looks something like this:
```
int playerCollisionCheck(Entity *player, Entity *entity, int closeness)
{
  if (abs(player->baseY - entity->baseY) < closeness)
  {
    EntityBounds entityHurtBounds = entity->boundsTableAddress[entity->hurtBoundsIndex];

    Rectangle entityHurtScreenRect = Rectangle(
      xLeft: entity->entityX + entityHurtBounds->xOffset,
      yTop: entity->entityY + entityHurtBounds->yOffset
      xRight: .xLeft + entityHurtBounds->width
      yBottom: .yTop + entityHurtBounds->height);

    // Check if player damages entity
    if (PrecalculatedPlayerDamageScreenRect.intersects(entityHurtScreenRect))
    {
      entity->interactingEntityAddress = player;
      player->interactingEntityAddress = entity;

      // Set some flags on both sides
      // ...

      return ...;
    }

    // Check if entity damages player

    // ... same but with opposite bounds on both sides
  }
}
```

### Code/data pointers
- `WritePlayerBounds`: **$C184**
  - Parameters:
    - a0: The player entity
- `CheckPlayerVsEntityDamage`: **$BF62**
  - Tests (in that order):
    1. If the player damages entity: If the entity's hurt box intersects with the player's damage box.
    2. If the entity damages the player: If the entity's damage box intersects with the player's hurt box.
  - Also turns the damaged entity towards the damaging entity.
  - Parameters:
    - a0: The entity
    - a3: The player entity
    - d2: Required closeness in y (depth) direction in pixels at sea level (using `EntityInstance.baseY`)
      - Fat enemies use bigger value.
- `CheckTwoPlayerVsEntityDamage`: **$BF4A**
  - Checks collision against both players. Player one has priority.
  - Parameters:
    - a0: The entity
    - d2: Required closeness in y (depth) direction in pixels at sea level (using `EntityInstance.baseY`)
      - Fat enemies use bigger value.
- `CheckTwoPlayerVsEntityDamageDefaultCloseness`: **$BF48**
  - Calls `CheckTwoPlayerCollision` with closeness value of 8px.
- `CheckHitBoundsAgainstEntityHitBounds`: **$C246**
  - Parameters:
    - a0: this entity
    - a3: other entity
- `CheckHitBoundsAgainstManyOtherEntity`: **$C256**
  - Call `CheckHitBoundsAgainstEntity` over a range of entities
  - Parameters:
    - a0: this entity
    - a3: First entity to check
    - d7: Number of entities to check in total
