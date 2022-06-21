meta:
  id: map_entity_load_trigger_list
  title: Golden Axe entity load trigger list format
  endian: be
  imports:
    - map_entity_load_group
seq:
  - id: trigger_list
    type: map_entity_load_trigger
    repeat: until
    repeat-until: _.h_scroll_trigger == 0xffff
types:
  map_entity_load_group_ptr:
    seq:
      - id: address
        type: u4
    instances:
      de_reference:
        type: map_entity_load_group
        io: _root._io
        pos: address
  map_entity_load_slot_descriptor:
    seq:
      - id: num_load_slots
        type: u2
      - id: load_group
        type: map_entity_load_group_ptr
        repeat: expr
        repeat-expr: num_load_slots + 1
  map_entity_load_slot_descriptor_ptr:
    seq:
      - id: address
        type: u4
    instances:
      de_reference:
        type: map_entity_load_slot_descriptor
        io: _root._io
        pos: address
  map_entity_load_slot_descriptor_index:
    seq:
      - id: load_slot_index
        type: u2
    instances:
      load_slot_address:
        type: map_entity_load_slot_descriptor_ptr
        io: _root._io
        # MapEntityLoadSlotDescriptorTable address = 0x37AEE = 228078
        # Kaitai does not seem happy when using hex notation in the .pos field.
        # See: https://github.com/kaitai-io/kaitai_struct/issues/456
        pos: 228078 + (load_slot_index * 4)
  map_entity_load_trigger:
    seq:
      - id: h_scroll_trigger
        type: u2
      - id: load_index
        type: map_entity_load_slot_descriptor_index
        if: h_scroll_trigger != 0xffff
