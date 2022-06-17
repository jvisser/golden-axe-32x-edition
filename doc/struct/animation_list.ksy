meta:
  id: animation_list
  title: Golden Axe animation list format
  endian: be
  imports:
    - dma_animation
    - pre_load_animation
seq:
  - id: animations
    type:
      switch-on: param_dma_frame_table_address
      cases:
        0: pre_load_animation_ptr
        _: dma_animation_ptr
    repeat: expr
    repeat-expr: param_mirror_animation_offset / 4
  - id: mirror_animations
    type:
      switch-on: param_dma_frame_table_address
      cases:
        0: pre_load_animation_ptr
        _: dma_animation_ptr
    repeat: expr
    repeat-expr: param_mirror_animation_offset / 4
params:
  - id: param_mirror_animation_offset
    type: u2
  - id: param_bounds_table_address
    type: u4
  - id: param_dma_frame_table_address
    type: u4
types:
  dma_animation_ptr:
    seq:
      - id: address
        type: u4
    instances:
      de_reference:
        type: dma_animation(_parent.param_bounds_table_address, _parent.param_dma_frame_table_address)
        io: _root._io
        pos: address
  pre_load_animation_ptr:
    seq:
      - id: address
        type: u4
    instances:
      de_reference:
        type: pre_load_animation(_parent.param_bounds_table_address)
        io: _root._io
        pos: address
