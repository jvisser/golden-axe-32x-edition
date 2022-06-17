meta:
  id: meta_sprite
  title: Golden Axe meta sprite format
  endian: be
  imports:
    - bounds_index
seq:
  - id: sprite_count
    type: u1
  - id: hurt_bounds_index
    type: bounds_index(param_bounds_table_address)
  - id: damage_bounds_index
    type: bounds_index(param_bounds_table_address)
  - id: sprites
    type: sprite
    repeat: expr
    repeat-expr: sprite_count + 1
params:
  - id: param_bounds_table_address
    type: u4
types:
  sprite:
    seq:
      - id: y_offset
        type: s1
      - id: vdp_sprite_attr_size
        type: u1
        enum: size
      - id: relative_pattern_id
        type: u2
      - id: x_offset
        type: s1
    enums:
      size:
        0x00: h1_v1
        0x04: h2_v1
        0x08: h3_v1
        0x0c: h4_v1
        0x01: h1_v2
        0x05: h2_v2
        0x09: h3_v2
        0x0d: h4_v2
        0x02: h1_v3
        0x06: h2_v3
        0x0a: h3_v3
        0x0e: h4_v3
        0x03: h1_v4
        0x07: h2_v4
        0x0b: h3_v4
        0x0f: h4_v4
    instances:
      calculated_relative_tile_id:
        value: relative_pattern_id & 0x7ff
      calculated_relative_vram_address:
        value: calculated_relative_tile_id * 0x20
      calculated_hflip:
        value: (relative_pattern_id & 0x800) != 0
