# Golden Axe 32X edition

Golden Axe 32X conversion patch for the original Sega Mega Drive game.

## How to build
### Prerequisites
- `rom/rom.bin`: Golden Axe ROM image
  - SHA256: `e9f5340ecf8151253eb6fcda136c4d4d8940e373340ce2eeb2bf24f9f6c1004d`
- `java 17+`
- `maven 3+`
- [`marsdev`](https://github.com/andwn/marsdev)

### Run
- `make build-tools` once to build the required tools
- `make`

If successful the patch file `out/patch.ips` should exist.

### Other targets
- `make clean`: Cleanup the output directory
- `make dump-gfx`: Dump game graphics and visual metadata defined in `config/datavis.yaml` to directory `dump`.

## Documentation
The `doc` dir contains some reverse engineering notes complementing my (internal) disassembly of the game.
As such they are not written in a completely user friendly way but do contain useful information about some of the game's inner workings.

The Kaitai struct files in the `doc/struct` dir are specifically made for exploration of the game's data structures in the [Kaitai Web IDE](https://ide.kaitai.io/devel/#).
More formal struct files that can be used to generate a binary parser can be found in the `src/main/resources/kaitai` dir inside the source code of the `DataVis` tool.
