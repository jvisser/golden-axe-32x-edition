meta:
  id: pre_load_animation
  title: Golden Axe pre load animation format
  endian: be
  imports:
    - meta_sprite
seq:
  - id: frame_count
    type: u1
  - id: frame_time
    type: u1
  - id: animation_frames
    type: meta_sprite_ptr
    repeat: expr
    repeat-expr: frame_count
params:
  - id: param_bounds_table_address
    type: u4
types:
  meta_sprite_ptr:
    seq:
      - id: address
        type: u4
    instances:
      de_reference:
        type: meta_sprite(_parent.param_bounds_table_address)
        io: _root._io
        pos: address
