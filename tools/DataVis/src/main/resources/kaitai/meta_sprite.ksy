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
      - id: relative_pattern_id
        type: u2
      - id: x_offset
        type: s1
    instances:
      calculated_width:
        value: ((vdp_sprite_attr_size >> 2) & 0x03) + 1
      calculated_height:
        value: (vdp_sprite_attr_size & 0x03) + 1
      calculated_relative_tile_id:
        value: relative_pattern_id & 0x7ff
      calculated_relative_vram_address:
        value: calculated_relative_tile_id * 0x20
      calculated_hflip:
        value: (relative_pattern_id & 0x800) != 0
      calculated_vflip:
        value: (relative_pattern_id & 0x1000) != 0
