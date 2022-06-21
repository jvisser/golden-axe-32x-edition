# Game variables

## Game related variables

- Active game mode: **$FFC172**
  - **$00**: Sega logo
  - **$04**: Title
  - **$08**: Player select
  - **$0c**: Gameplay
  - **$10**: Demo
  - **$14**: Character profile
  - **$18**: Intermission
  - **$1c**: Camping
  - **$20**: Results
  - **$24**: Ending
  - **$28**: Beginner ending
  - **$2c**: Cast
  - **$30**: Credits
  - **$34**: Duel vs info
  - **$38**: Duel
  - **$3c**: Next duel
  - **$40**: Game over
- Requested game mode: **$FFC170**
  - When requesting a game mode change set this to the requested mode
- Game mode flags: **$FFC104**
  - bit 0: ?
  - bit 1: duel mode
  - bit 2: beginner mode
- Enemies:
  - Number of active enemies: **$FFC26C**
  - Number of pending enemy load slots: **$FFC272**

## Technical
The hud/magic effect/screen transition etc is rendered on plane a.
The map is rendered on plane b.

- Initial VDP register values: **$E4E**
- Cached values of VDP registers
  - VPDReg_Mode1: **$FFC114**
  - VPDReg_Mode2: **$FFC116**
  - VPDReg_Plane_Size: **$FFC118**
  - VPDReg_Mode3: **$FFC11A**
  - VPDReg_Mode4: **$FFC11C**
- Scroll values in map coordinates
  - MapVerticalScroll: **$FFC20C** (16:16 fp)
  - MapHorizontalScroll: **$FFC210** (16:16 fp)
  - MapMinVerticalScroll: **FFC224**
  - MapMaxVerticalScroll: **$FFC226**
    - Map height in pixels - 224
  - MapMaxHorizontalScroll: **$FFC228**
    - Map width in pixels - 320
- VDP scroll values
  - PlaneAVerticalScroll: **$FFC218**
  - PlaneAHorizontalScroll: **FFC21A**
  - PlaneBVerticalScroll: **$FFC21C**
  - PlaneBHorizontalScroll: **FFC21E**
