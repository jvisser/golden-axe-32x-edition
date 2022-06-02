# Palette

## Palette formats

```
    ; Struct PartialPalette
        dc.w colorOffset
        dc.w colorCount                 ; Color count - 1 as this is stored dbf/dbra adjusted 
          ; Repeat colorCount + 1 times 
            dc.w color 
```

Colors are loaded at the specified offset into the 64 color palette.

## Code/data pointers
- `BasePalette`: **$FFC000**.
- `DynamicPalette`: **$FFC080**
- `UpdateBasePalettePartial` routine: **$2ED0**
    - Updates the base palette 
- `UpdateDynamicPalettePartial` routine: **$2EB4**
    - Updates the dynamic palette 
