meta:
  id: dma_animation
  title: Golden Axe DMA based animation format
  endian: be
  imports:
    - meta_sprite
    - bounds_index
seq:
  - id: max_frame_index
    type: u1
  - id: marker_frame_index
    type: u1
  - id: frame_count
    type: u1
  - id: frame_time
    type: u1
  - id: animation_frames
    type: animation_frame_ptr
    repeat: expr
    repeat-expr: frame_count
params:
  - id: param_bounds_table_address
    type: u4
  - id: param_dma_frame_table_address
    type: u4
types:
  dma_transfer:
    seq:
      - id: dma_length
        type: s2
        doc: |
          DMA length in words
      - id: source_offset
        type: u2
        if: dma_length > 0
  dma_frame:
    seq:
      - id: dma_transfer_list
        type: dma_transfer
        repeat: until
        repeat-until: _.dma_length <= 0
  dma_frame_ptr:
    seq:
      - id: address
        type: u4
    instances:
      de_reference:
        type: dma_frame
        io: _root._io
        pos: address
  dma_frame_index:
    seq:
      - id: index
        type: u1
    instances:
      dma_frame_ptr:
        type: dma_frame_ptr
        io: _root._io
        pos: _parent._parent._parent.param_dma_frame_table_address + (index * 4)
        if: _parent._parent._parent.param_dma_frame_table_address != 0
  animation_frame:
    seq:
      - id: damage_bounds_index
        type: bounds_index(_parent._parent.param_bounds_table_address)
      - id: dma_index
        type: dma_frame_index
      - id: meta_sprite
        type: meta_sprite(_parent._parent.param_bounds_table_address)
  animation_frame_ptr:
    seq:
      - id: address
        type: u4
    instances:
      de_reference:
        type: animation_frame
        io: _root._io
        pos: address
