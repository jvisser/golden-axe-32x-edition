meta:
  id: rom
  title: Golden Axe data points collection for use in Kaitai struct web IDE.
  endian: be
  imports:
    - map
    - map_entity_load_group
    - map_entity_load_trigger_list
    - palette
    - animation_list
seq:
  - id: maps
    type: map_collection
  - id: custom_entity_load_groups
    type: custom_entity_load_group_collection
  - id: custom_entity_load_triggers
    type: custom_entity_load_trigger_collection
  - id: animation_collection
    type: animation_collection
  - id: palettes
    type: palettes
types:
  pre_load_animation_instance:
    doc: |
      A collection of animation related addresses/data structures
        for animations for which all the tile data is preloaded to VRAM (normally through the map entity loading system)
      These addresses are not structurally stored.
      But are set by initialization code on a per entity basis.
    seq:
      - id: animation_list
        type: animation_list(param_mirror_animation_offset, param_bounds_table_address, 0)
    params:
      - id: param_mirror_animation_offset
        type: u2
      - id: param_bounds_table_address
        type: u4
      - id: param_nemesis_data_address
        type: u4
    instances:
      nemesis_source:
        value: param_nemesis_data_address
  dma_animation_instance:
    doc: |
      A collection of DMA animation related addresses/data structures.
      These addresses are not structurally stored.
      But are set by initialization code on a per entity basis.
    seq:
      - id: animation_list
        type: animation_list(param_mirror_animation_offset, param_bounds_table_address, param_dma_frame_table_address)
    params:
      - id: param_mirror_animation_offset
        type: u2
      - id: param_bounds_table_address
        type: u4
      - id: param_dma_frame_table_address
        type: u4
      - id: param_dma_source_address
        type: u4
    instances:
      dma_source:
        value: param_dma_source_address
  animation_collection:
    instances:
      ax:
        type: dma_animation_instance(0x7c, 0x399AA, 0x4492E, 0x44B98)
        pos: 0x3A350
        doc: |
          Uses palette 0
          Init code at: 0x86B6
      tyris:
        type: dma_animation_instance(0x7c, 0x399AA, 0x60570, 0x607A6)
        pos: 0x3D41A
        doc: |
          Uses palette 0
          Init code at: 0x86B6
      gylius:
        type: dma_animation_instance(0x7c, 0x399AA, 0x4FB58, 0x4FDA2)
        pos: 0x3BCB0
        doc: |
          Uses palette 0
          Init code at: 0x86B6
      heninger:
        type: dma_animation_instance(0x70, 0x40262, 0x69166, 0x69340)
        pos: 0x43656
        doc: |
          Uses palette 1
          Init code at: 0xE762
      longmoan:
        type: dma_animation_instance(0x70, 0x40262, 0x6D5E0, 0x6D772)
        pos: 0x71F72
        doc: |
          Uses palette 1
          Init code at: 0xF82C
      amazon:
        type: dma_animation_instance(0x70, 0x40262, 0x7A08E, 0xFF8000)
        pos: 0x790D2
        doc: |
          The amazon is a special case in that the dma source tile data is Nemesis compressed.
          The nemesis source data can be found at address 0x7A25A.
          Uses palette 1
          Init code at: 0x11040
      skeleton:
        type: dma_animation_instance(0x54, 0x40262, 0x59A42, 0x59BEC)
        pos: 0x3ED06
        doc: |
          Uses palette 0
          Init code at: 0xD608
      bad_brother:
        type: pre_load_animation_instance(0x34, 0x40262, 0x7532A)
        pos: 0x737AE
        doc: |
          Uses palette 1
          Init code at: 0x102CC
      bitter:
        type: pre_load_animation_instance(0x28, 0x40262, 0x7D088)
        pos: 0x7C718
        doc: |
          Uses palette 1
          Init code at: 0x110C4
      death_adder:
        type: pre_load_animation_instance(0x30, 0x40262, 0x77D6E)
        pos: 0x74192
        doc: |
          Death Adder is special case. He is composed of both the Bad brother tile set and an additional tile set for his custom animation frames.
          So both sets of nemesis data must be loaded (on top of each other in VRAM).
          The nemesis source specified here is only for the Death Adder part.
          Uses palette 1
          Init code at: 0x119F8
      death_adder_specials:
        type: pre_load_animation_instance(0x0C, 0x40262, 0x5FC2A)
        pos: 0x5FB2C
        doc: |
          Animations:
          - 0: Conjuring
          - 1: Moving projectile
          - 2: Explosion
          The tile data is loaded from 2 separate sources. One for the projectile and one for the explosion:
          - Projectile: 0x5FC2A
          - Explosion: 0x32C8E (Shared with ax magic attack level 3)
          For Death bringer the explosion tile area is used by his sitting animation.
          The explosion tile data will be manually loaded by the death adder/bringer logic. See address 0x1201C.
          Uses palette 2
          Init code at: 0x131CC (Conjuring/projectile), 0x13770 (explosion), 0x1201C (explosion death bringer).
      chicken_leg:
        type: pre_load_animation_instance(0x14, 0x40262, 0x40E8A)
        pos: 0x4086A
        doc: |
          Uses palette 2
          Init code at: 0x12B76
      dragon:
        type: pre_load_animation_instance(0x14, 0x40262, 0x420FE)
        pos: 0x41B16
        doc: |
          Blue dragon: Uses palette 2 (Includes fire breath/ball colors)
          Red dragon: Uses palette 1
          Init code at: 0x1267C (Blue), 0x126B2 (Red)
      blue_dragon_flame:
        type: pre_load_animation_instance(0x04, 0x40262, 0x420FE)
        pos: 0x41B3E
        doc: |
          Nemesis data is contained in the dragon tile data.
          Init code at: 0x12F74
      red_dragon_fire_ball:
        type: pre_load_animation_instance(0x08, 0x40262, 0x420FE)
        pos: 0x41B46
        doc: |
          Nemesis data is contained in the dragon tile data.
          Init code at: 0x13096
      thief:
        type: pre_load_animation_instance(0x10, 0x3A192, 0x733EA)
        pos: 0x731F2
        doc: |
          Blue: Uses palette 0
          Green: Used palette 1
          Init code at: 0xA9F8
      villager:
        type: pre_load_animation_instance(0x4, 0x40262, 0x60096)
        pos: 0x5FFD0
        doc: |
          Bounds data is not used and there is no mirror animation table.
          We just set the offset to 4 here so we can see both animations...
          Uses palette 0
          Villager 1 uses animation 0
          Villager 2 uses animation 1
          Init code at: 0x138A4
  map_collection:
    instances:
      level_1:
        type: map
        pos: 0x15D8
        doc: |
          Level 1: Wilderness
      level_2:
        type: map
        pos: 0x161A
        doc: |
          Level 2: Turtle village
      level_3:
        type: map
        pos: 0x1664
        doc: |
          Level 3: Mainland coast
      level_4:
        type: map
        pos: 0x16A6
        doc: |
          Level 4: Fiend's Path
      level_5:
        type: map
        pos: 0x16F0
        doc: |
          Level 5: Eagle's Head
      level_6:
        type: map
        pos: 0x1732
        doc: |
          Level 6: Death Adder's Castle
      level_7:
        type: map
        pos: 0x1784
        doc: |
          Level 7: Dungeons
      level_8:
        type: map
        pos: 0x17C6
        doc: |
          Level 8: Death Bringer's Lair
      duel:
        type: map
        pos: 0x182C
        doc: |
          Duel map
      ending:
        type: map
        pos: 0x1876
        doc: |
          Ending map (after death bringer)
      demo1:
        type: map
        pos: 0x18C0
        doc: |
          Just level 1 map with event/entity trigger list addresses adjusted for h scroll.
  custom_entity_load_group_collection:
    instances:
      level8_load_group_1:
        type: map_entity_load_group
        pos: 0x38308
        doc: |
          For death bringer the entity load slots are filled by custom code.
          Death Adder/Bringer's animation tiles are pre-loaded by the map tile loading system instead of through the MapEntityLoadGroup in this specific case.
      level8_load_group_2:
        type: map_entity_load_group
        pos: 0x38316
        doc: |
          For death bringer the entity load slots are filled by custom code
  custom_entity_load_trigger_collection:
    instances:
      level3_beginner_mode_entity_load_trigger_list:
        type: map_entity_load_trigger_list
        pos: 0x37ACC
        doc: |
          Custom entity trigger list for beginner mode level 3. Ends with Death Adder jr. boss.
  palettes:
    doc: |
      Collection of palette examples
      Palette 0 is used for players and some entities. Allocation is [0sssssmmmmbbrrgg]
        - s: skin tones
        - m: metal
        - b: blue tones
        - r: red tones
        - g: green tones
      Palette 1 is used for most entities. Allocation is [0aaaayyysssscccc]
        - a: Amazon clothes + red dragon skin
        - y: yellow for amazon + dragon saddle
        - s: skin tones
        - c: clothes for non amazon entities
      Palette 2 is used for rideable`s. Allocation is [0ddddyyycccfffff]
        - d: blue dragon
        - y: yellow for dragon saddle
        - c: chicken leg skin tones
        - f: fireball
    instances:
      player:
        type: palette
        pos: 0x38492
      purple:
        type: palette
        pos: 0x38A66
      green:
        type: palette
        pos: 0x38A88
      blue:
        type: palette
        pos: 0x38B32
      silver:
        type: palette
        pos: 0x38B54
      red:
        type: palette
        pos: 0x38BDC
      gold:
        type: palette
        pos: 0x38C64
      dark:
        type: palette
        pos: 0x38B98
      bronze:
        type: palette
        pos: 0x38BFE
      red_dragon:
        type: palette
        pos: 0x38B10
        doc: |
          Also shared colors with amazon clothing
      blue_dragon_chicken:
        type: palette
        pos: 0x38ACC
      dragon_fire:
        type: palette
        pos: 0x43632
        doc: |
          Actually contains 3 palettes directly following each other. Each containing 5 colors.
          These are cycled when on fire breath.
      magic_tyris_3:
        type: palette
        pos: 0x3597A
        doc: |
          Actually contains 3 palettes directly following each other. Each containing 5 colors.
          NB: At least used in 2 cases updates the same color range as dragon_fire.
      magic_tyris_5:
        type: palette
        pos: 0x387D8
        doc: |
          Actually contains 6 palettes directly following each other. Each containing 31 colors. replacing both palettes 1 (excluding the first color) and 2
          These are cycled on tyris level 5 magic.
          See code at 0x95B0
      fire_magic:
        type: palette
        pos: 0x38958
        doc: |
          Actually contains 3 palettes directly following each other. Each containing 23 colors. replacing palettes 1 (excluding the first color) and the first 8 of palette 2 (including the first color).
          These are cycled by the general full screen fire routine.
          The top 8 colors of palette 2 seem reserved for the specific magic effect going on at the time.
          See code at 0x8F7A
