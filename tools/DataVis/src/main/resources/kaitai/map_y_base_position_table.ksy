meta:
  id: map_base_y_position_table
  title: Golden Axe map base Y position table format
  endian: be
seq:
  - id: number_position_changes
    type: u2
  - id: base_y_position_array
    type: map_base_y_position_start
    repeat: expr
    repeat-expr: number_position_changes + 1
types:
  map_base_y_position_start:
    seq:
      - id: map_x_end
        type: u2
        doc: |
          End x position for which base_y is valid
      - id: base_y
        type: u2
