# Golden Axe 32X edition

## Layout
```
    ./config        Config files for tools
    ./docs          Reverse engineering notes.
        /struct     Kaitai struct files for use in the Web IDE.
    ./tools
        /DataVis    Data visualization tool
    ./rom           Place the Golden Axe rev 1.1 ROM file here as rom.bin
```

### Docs
The docs dir contains some reverse engineering notes complementing my (internal) disassembly of the game. 
As such they are not written in a completely user friendly way but do contain useful information about some of the game's inner workings.

The Kaitai struct files in the docs dir are specifically made for exploration of the game's data structures in the [Kaitai Web IDE](https://ide.kaitai.io/devel/#). 
More formal struct files that can be used to generate a parser can be found in the resources dir inside the source code of the `DataVis` tool.  

### Tools
- `DataVis`: Dumps graphical data from the ROM image enhanced with visual metadata
  