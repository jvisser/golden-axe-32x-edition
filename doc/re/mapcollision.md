# Map collision detection

See [entity.md](./entity.md) for details on entity structure.

## Height values

Height values are based around a `baseHeight` of $8000. A height value lower means up and higher down.

Access to a tile on then map is granted as follows:

`accessible = EntityInstance.height <= SampleHeightMap(EntityInstance.baseY, EntityInstance.baseX)`

When an entity is spawned the initial height value is sampled from the map at the `(.baseY, .baseX)` position of the entity and stored into `EntityInstance.height`.

## Height motion
When jumping/falling `EntityInstance.heightAcceleration` is set to a negative/positive value to implement physics. This is then added to `EntityInstance.height` for each update.

### Jumping
Initiated by player. It is not possible to jump vertically so it is impossible to jump on heights directly to the back of the player, only to the side.

### Falling
Initiated by walking on a tile with a height value bigger than `EntityInstance.height`.

## Code/data pointers
- `SampleHeightMap`: **$C382**
  - Parameters:
    - d0: y In map coords (maps to `EntityInstance.baseY`)
    - d1: x In vdp coords (maps to `EntityInstance.entityX`)
    - d2: y displacement value
    - d3: x displacement value
  - Output:
    - d7: collision value (8x8 pixel resolution)
- `baseHeight`: $8000
  - Reference height (0 value)
- Height constant `$8200`: Seems to be used as fall through value hardcoded. Makes sense as this is just outside the max vertical range (0-511) supported by the map system.
  - See `CheckPlayerCollision` routine at **$B608**
