meta:
  id: bounds_index
  title: Golden Axe bounds format
  endian: be
seq:
  - id: index
    type: u1
instances:
  bounds:
    type: bounds
    io: _root._io
    pos: param_bounds_table_address + (index * 8)
params:
  - id: param_bounds_table_address
    type: u4
types:
  bounds:
    seq:
      - id: x_offset
        type: s2
      - id: width
        type: u2
      - id: y_offset
        type: s2
      - id: height
        type: u2
