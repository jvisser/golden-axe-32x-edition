meta:
  id: palette_ptr
  title: Utility for dereferencing palette pointers
  endian: be
  imports:
    - palette
seq:
  - id: address
    type: u4
instances:
  de_reference:
    type: palette
    io: _root._io
    pos: address
    if: address != 0
