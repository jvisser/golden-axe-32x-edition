meta:
  id: map
  title: Golden Axe map format
  endian: be
  imports:
    - palette_ptr
    - map_entity_load_trigger_list
    - nemesis_symbol
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
  - id: base_y_table_address
    type: u4
instances:
  calculated_initial_vertical_scroll_pixels:
    value: initial_vertical_scroll_blocks * 16
  calculated_initial_horizontal_scroll_pixels:
    value: initial_horizontal_scroll_blocks * 16
  calculated_height_pixels:
    value: height_blocks * 16
  calculated_width_pixels:
    value: width_blocks * 16
  external_base_y_position_table:
    type: map_base_y_position_table
    io: _root._io
    pos: base_y_table_address
    if: base_y_table_address != 0
types:
  nemesis_data:
    seq:
      - id: vram_address_set_command
        type: u4
        doc: |
          VDP write address set command for the tile data address
      - id: nemesis_data_address
        type: nemesis_symbol
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
  map_entity_load_trigger_list_ptr:
    seq:
      - id: address
        type: u4
    instances:
      de_reference:
        type: map_entity_load_trigger_list
        io: _root._io
        pos: address
  map_base_y_position_start:
    seq:
      - id: map_x_end
        type: u2
        doc: |
          End x position for which base_y is valid
      - id: base_y
        type: u2
  map_base_y_position_table:
    seq:
      - id: number_position_changes
        type: u2
      - id: base_y_position_array
        type: map_base_y_position_start
        repeat: expr
        repeat-expr: number_position_changes + 1
