meta:
  id: palette
  title: Golden Axe palette format
  endian: be
seq:
  - id: color_offset
    type: u1
  - id: color_count
    type: u1
  - id: colors
    type: u2
    repeat: expr
    repeat-expr: color_count + 1
