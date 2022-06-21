# Compression

## Tiles
Tile data is compressed using [Nemesis](https://segaretro.org/Nemesis_compression) compression.

### Code pointers
- `NemesisDecompressToVRAM` routine: **$2FC8**
- `NemesisDecompressToRAM` routine: **$2FDA**

## Tile maps
Tile maps use a custom compression algorithm. This is used for both the graphics map and collision map.

This algorithm seems to be specifically designed for the game's in memory map data format. Map's are decompressed/stored in an 128x32 byte buffer in memory. 
This allows for maps of a maximum size of 2048x512 pixels. The decompression routine can decompress an arbitrary sized map into such a buffer. 

As an example lets say the map buffer is 8x4 and the map is 4x2 it will be decompressed into the buffer as follows (`M` is decompressed map data): 
```
MMMM0000
MMMM0000
00000000
00000000
```

The data is stored linearly in rows starting at the top left growing down.

### Code/data pointers
- `TileMapDecompress` routine: **$117C**
  - Parameters:
    - a1: Target buffer address
    - a2: Compressed data address
  - Indirect parameters (globals):
    - **$FFC202**.w = map width in 16x16 blocks

### Format 
It consists of a token byte stream where each token can be one of the following:
- `00000001`: Terminator token
- `0RRRRRRR`: Fill token
- `10RRRRRR`: Repeat token
- `110RRRRR`: Uncompressed data token
- `111RRRRR`: Increment token

#### Terminator token
Indicates end of data/stream

#### Fill token
Repeat the byte following the token `R` times.   

#### Repeat token
Repeat the following token `R` times. This next token can only be a true compression token so only `Fill` or `Increment`. 

#### Uncompressed data token
Copy `R` bytes following the token.

#### Increment token
Start with the byte value following the token. And for each repetition of `R` increment its value by 1.

