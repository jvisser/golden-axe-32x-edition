meta:
  id: map_entity_load_group
  title: Golden Axe entity load group format
  endian: be
  imports:
    - palette_ptr
    - nemesis_symbol
seq:
  - id: padding
    type: u1
  - id: group_graphics_offset
    type: map_entity_group_graphics_offset
  - id: num_entities
    type: u2
  - id: entity_instance_data
    type: map_entity_instance_data
    repeat: expr
    repeat-expr: num_entities
types:
  map_entity_instance_data:
    seq:
      - id: entity_instance_slot
        type: u1
      - id: entity_id
        type: u1
        enum: entity_id
      - id: entity_y
        type: u2
      - id: entity_x
        type: u2
      - id: sprite_base_tile_id
        type: u2
      - id: init_value
        type: u2
    enums:
      entity_id:
        0x00: none
        0x1e: thief               # bit 7 in init data set = green thief
        0x27: death_adder_door
        0x28: level_3_door
        0x29: level_4_feather
        0x2a: level_2_water
        0x2d: walk_to_dungeon_entrance_cutscene
        0x2e: skeleton_1
        0x2f: skeleton_2_from_hole
        0x30: skeleton_3
        0x31: heninger_silver
        0x32: heninger_purple
        0x33: heninger_red
        0x34: heninger_gold
        0x35: heninger_dark
        0x36: heninger_bronze
        0x37: heninger_green
        0x38: longmoan_silver
        0x39: longmoan_purple
        0x3a: longmoan_red
        0x3b: longmoan_gold
        0x3c: longmoan_dark
        0x3d: longmoan_bronze
        0x3e: longmoan_green
        0x3f: bad_brother_green
        0x40: bad_brother_blue    # also spawns level_3_door entity (non boss version)
        0x41: bad_brother_red
        0x42: amazon_1
        0x43: amazon_2
        0x44: amazon_3
        0x45: amazon_4
        0x46: amazon_5
        0x47: bitter_silver
        0x48: bitter_red
        0x49: bitter_gold
        0x4a: death_adder           # also spawns death_adder_door entity
        0x4b: death_bringer
        0x4c: death_adder_jr        # also spawns level_3_door entity (boss version)
        0x4d: blue_dragon
        0x4e: red_dragon
        0x4f: chicken_leg
        0x56: villager_1
        0x57: villager_2
        0x60: skeleton_4
  map_entity_group_graphics_palette_index:
    seq:
      - id: palette_index
        type: u1
    instances:
      palette_address:
        type: palette_ptr
        io: _root._io
        # MapEntityGroupPaletteTable address = 0x389E8 = 231912
        pos: 231912 + (palette_index * 4)
        if: palette_index != 0
  map_entity_group_graphics_nemesis_data_ptr:
    seq:
      - id: address
        type: nemesis_symbol
  map_entity_group_graphics_nemesis_data_offset:
    seq:
      - id: offset
        type: u2
        enum: entity_tile_data
    enums:
      entity_tile_data:
        0x00: nemesis_thief
        0x04: nemesis_bad_brother
        0x08: nemesis_death_adder
        0x0C: nemesis_bitter
        0x10: nemesis_chicken_leg
        0x14: nemesis_dragon
        0x18: nemesis_villagers
        0x1c: nemesis_king_and_queen
        0x20: nemesis_death_adder_special_attack
    instances:
      address:
        type: map_entity_group_graphics_nemesis_data_ptr
        io: _root._io
        # MapEntityGroupTileAddressTable = 0x13A74 = 80500
        pos: 80500 + offset.to_i
  map_entity_group_graphics_nemesis_data:
    seq:
      - id: vram_address
        type: u2
      - id: nemesis_offset
        type: map_entity_group_graphics_nemesis_data_offset
        if: vram_address != 0
  map_entity_group_graphics:
    seq:
      - id: palette_index_1
        type: map_entity_group_graphics_palette_index
      - id: palette_index_2
        type: map_entity_group_graphics_palette_index
      - id: nemesis_data
        type: map_entity_group_graphics_nemesis_data
        repeat: until
        repeat-until: _.vram_address == 0
  map_entity_group_graphics_ptr:
    seq:
      - id: address
        type: u4
    instances:
      de_reference:
        type: map_entity_group_graphics
        io: _root._io
        pos: address
  map_entity_group_graphics_offset:
    seq:
      - id: graphics_offset
        type: u1
    instances:
      group_graphics_address:
        type: map_entity_group_graphics_ptr
        io: _root._io
        # MapEntityGroupGraphicsTable address 0x13A98 = 80536
        pos: 80536 + graphics_offset
        if: graphics_offset != 0
