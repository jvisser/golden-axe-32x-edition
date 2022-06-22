meta:
  id: dma_animation
  title: Golden Axe DMA based animation format
  endian: be
  imports:
    - meta_sprite
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
  animation_frame:
    seq:
      - id: damage_bounds_index
        type: u1
      - id: dma_index
        type: u1
      - id: meta_sprite
        type: meta_sprite
  animation_frame_ptr:
    seq:
      - id: address
        type: u4
    instances:
      de_reference:
        type: animation_frame
        io: _root._io
        pos: address
