# Golden Axe 32X edition

Golden Axe 32X conversion patch for the original Sega Mega Drive game.

## How to build
### Prerequisites
#### Required
- `rom/rom.bin`: Golden Axe ROM image file 
  - SHA256: `e9f5340ecf8151253eb6fcda136c4d4d8940e373340ce2eeb2bf24f9f6c1004d`
- `jdk 17+`: To build and run the tools
- `maven 3+`: To build the tools
- [`marsdev`](https://github.com/andwn/marsdev): To build the patch file. 
  - Version [`2022.02`](https://github.com/andwn/marsdev/releases/tag/2022.02) was used. This still included the [`mdcomp`](https://github.com/flamewing/mdcomp) tools which are required.

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
