meta:
  id: map_file
  title: Golden Axe map format
  endian: be
  imports:
    - palette
seq:
  - id: palettes
    type: palette_ptr
    repeat: until
    repeat-until: _.address == 0
  - id: tile_data
    type: nemesis_data
    repeat: until
    repeat-until: _.vram_address_set_command == 0
  - id: graphics_block_data_address
    type: u4
    doc: |
      16x16 graphics block base address.
      Each block is stored as 4 VDP nametable words.
      Stored left to right and top to bottom order.
      Uncompressed.
  - id: compressed_graphics_block_map_data_address
    type: u4
    doc: |
      Address of the compressed graphics tilemap data.
  - id: height_blocks
    type: u2
    doc: |
      Height in blocks
  - id: width_blocks
    type: u2
    doc: |
      Width in blocks
  - id: initial_vertical_scroll_blocks
    type: u2
    doc: |
      Initial vertical scroll value in blocks
  - id: initial_horizontal_scroll_blocks
    type: u2
    doc: |
      Initial horizontal scroll value in blocks
  - id: events
    type: map_event_trigger_list_ptr
  - id: compressed_height_block_map_data_address
    type: u4
    doc: |
      Address of the compressed height tilemap data.
  - id: height_block_data_address
    type: u4
    if: compressed_height_block_map_data_address != 0
    doc: |
      16x16 height block base address.
      Each block is stored as 4 words containing the height of the tile.
      Stored left to right and top to bottom order.
      Uncompressed.
  - id: entity_load_data
    type: map_entity_load_trigger_list_ptr
  - id: player_1_base_y_offset
    type: u2
    doc: |
      In VDP sprite coordinates (screenspace)
  - id: player_1_entity_x
    type: u2
    doc: |
      In VDP sprite coordinates (screenspace)
  - id: player_2_base_y_offset
    type: u2
    doc: |
      In VDP sprite coordinates (screenspace)
  - id: player_2_entity_x
    type: u2
    doc: |
      In VDP sprite coordinates (screenspace)
  - id: music_id
    type: u2
params:
  - id: map_entity_load_slot_descriptor_table_address
    type: u4
  - id: map_entity_group_graphics_table_address
    type: u4
  - id: map_entity_group_palette_table_address
    type: u4
  - id: map_entity_group_tile_address_table_address
    type: u4
instances:
  calculated_initial_vertical_scroll_pixels:
    value: initial_vertical_scroll_blocks * 16
  calculated_initial_horizontal_scroll_pixels:
    value: initial_horizontal_scroll_blocks * 16
  calculated_height_patterns:
    value: height_blocks * 2
  calculated_width_patterns:
    value: width_blocks * 2
  calculated_height_pixels:
    value: height_blocks * 16
  calculated_width_pixels:
    value: width_blocks * 16
types:
  palette_ptr:
    seq:
      - id: address
        type: u4
    instances:
      de_reference:
        type: palette
        io: _root._io
        pos: address
        if: address != 0
  nemesis_data:
    seq:
      - id: vram_address_set_command
        type: u4
        doc: |
          VDP write address set command for the tile data address
      - id: nemesis_data_address
        type: u4
        if: vram_address_set_command != 0
        doc: |
          Address of the nemesis compressed tile data
    instances:
      calculated_vram_address:
        if: vram_address_set_command != 0
        value: ((vram_address_set_command >> 16) & 0x3fff) | ((vram_address_set_command & 0x03) << 14)
  map_event_trigger:
    seq:
      - id: h_scroll_trigger
        type: u2
      - id: event_id
        type: u1
        enum: map_event_id
      - id: event_data
        type: u1
    enums:
      map_event_id:
        0x00: nothing
        0x04: palette_transition
        0x08: move_camera_up_on_horizontal_movement
        0x0c: set_vertical_scroll_limits
        0x10: wait_for_enemy_defeat
        0x14: camera_transition
        0x18: switch_to_camp_site_once_all_enemies_are_defeated
        0x1c: goto_next_level_once_all_enemies_are_defeated
        0x20: end_game_once_all_enemies_are_defeated
        0x24: start_water_animation
        0x28: start_spawning_feathers
        0x2c: boss_music
  map_event_trigger_list_ptr:
    seq:
      - id: address
        type: u4
    instances:
      de_reference:
        type: map_event_trigger
        io: _root._io
        pos: address
        repeat: until
        repeat-until: _.h_scroll_trigger == 0x500
  map_entity_load_group:
    seq:
      - id: can_load_with_active_enemies
        type: u1
        doc: |
            Any non zero value indicates true
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
            pos: _root.map_entity_group_palette_table_address + (palette_index * 4)
            if: palette_index != 0
      map_entity_group_graphics_nemesis_data_ptr:
        seq:
          - id: address
            type: u4
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
            pos: _root.map_entity_group_tile_address_table_address + offset.to_i
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
            pos: _root.map_entity_group_graphics_table_address + graphics_offset
            if: graphics_offset != 0
  map_entity_load_trigger_list:
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
          - id: load_groups
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
            pos: _root.map_entity_load_slot_descriptor_table_address + (load_slot_index * 4)
      map_entity_load_trigger:
        seq:
          - id: h_scroll_trigger
            type: u2
          - id: load_index
            type: map_entity_load_slot_descriptor_index
            if: h_scroll_trigger != 0xffff
  map_entity_load_trigger_list_ptr:
    seq:
      - id: address
        type: u4
    instances:
      de_reference:
        type: map_entity_load_trigger_list
        io: _root._io
        pos: address
