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

The entity bounds indices are updates like this:
- Always: When rendering the `MetaSprite` referenced in `EntityInstance.metaSpriteAddress` in routine `AllocateVDPSpritesForEntity` (See [render.md](./render.md)) both bounds indices are copied from the `MetaSprite` into the `EntityInstance`.
- Sometimes: When loading a new animation frame only `EntityInstance.damageBoundsIndex` is copied from `AnimationFrame.damageBoundsIndex`.
    - Depending on which animation routines are used (not sure what the purpose is atm other than maybe preventing delayed processing of damage by one frame)

The actual collision checks are then performed via the `EntityInstance`.
