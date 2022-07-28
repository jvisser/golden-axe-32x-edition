# Golden Axe 32X edition

Golden Axe 32X conversion patch for the original Sega Mega Drive game.

## How to build
### Prerequisites
#### Required
- `rom/rom.bin`: Golden Axe ROM image file 
  - SHA256: `e9f5340ecf8151253eb6fcda136c4d4d8940e373340ce2eeb2bf24f9f6c1004d`
- `jdk 17+`: To build and run the tools
- `maven 3+`: To build the tools
- [`marsdev`](https://github.com/andwn/marsdev): To build the patch file

#### Optional
- [`flips`](https://github.com/Alcaro/Flips): To apply the patch file

### Build targets
Run once:
- `make init`

Run either:
- `make` to produce the IPS patch file `out/patch.ips`
- `make patch` to run make and apply the patch file to produce `out/rom.32x`
    - This requires `flips`

### Other targets
- `make clean`: Clean the output directory
- `make rebuild`: Clean + make
- `make dump-gfx`: Dump original game graphics and visual metadata for game resources defined in `config/datavis.yaml` to directory `dump`.

## Documentation
The `doc` dir contains some early reverse engineering notes of the game.
As such they are not written in a completely user friendly way but do contain useful information about some of the game's inner workings.

The Kaitai struct files in the `doc/struct` dir are specifically made for exploration of the game's data structures in the [Kaitai Web IDE](https://ide.kaitai.io/devel/#).
More formal struct files that can be used to generate a binary parser can be found in the `src/main/resources/kaitai` dir in the source code of the `DataVis` tool.
