# Map event handling

##
Map events are stored in the following format.

```
    ; Struct MapEvent
        dc.b id     ; Stored as an offset (so in increments of 4)
        dc.b data 
```

Up to 4 events can be active at one time.

## Code/data pointers
- `MapEventQueue`: **$FFC22E**
  - 4 slot map event queue. Contains loaded `MapEvent` structs values of all active events.
- `HandleMapEvents` routine: **$1D0E**
  - Runs event handling routine for all non null slots in `MapEventQueue`
  - Map event handlers are themselves responsible for unregistering their slot (by writing null) when finished.

## Map events

### Map event id's
- **$00**: Do nothing
- **$04**: [Palette transition](#04-palette-transition)
- **$08**: [Move camera up on horizontal movement](#08-move-camera-up-on-horizontal-movement)
- **$0c**: [Set vertical scroll limits](#0c-set-vertical-scroll-limits)
- **$10**: [Wait for enemy defeat](#10-wait-for-enemy-defeat)
- **$14**: [Camera transition](#14-camera-transition)
- **$18**: [Switch to camp site once all enemies are defeated](#18-switch-to-camp-site-once-all-enemies-are-defeated)
- **$1c**: [Goto next level once all enemies are defeated](#1c-goto-next-level-once-all-enemies-are-defeated)
- **$20**: [End game once all enemies are defeated](#20-end-game-once-all-enemies-are-defeated)
- **$24**: [Start water animation](#24-start-water-animation)
- **$28**: [Start spawning feathers](#28-start-spawning-feathers)
- **$2c**: [Boss music](#2c-boss-music)

#### $04: Palette transition
`MapEvent.data` is the index into `PaletteTransitionSequencePointerTable`. Which contains pointers to palette transition sequences.  

Palette transition sequences are stored in the following format:
```
    ; Struct PaletteTransitionSequence
        dc.w numberOfTransitions
        ; Repeat numberOfTransitions times  
          dc.l partialPaletteAddress 
```

Both the `BasePalette` and `DynamicPalette` are updated using the `PartialPalette`'s pointed to by `.partialPaletteAddress`. This means the new palette is permanent.
See [palette.md](./palette.md) for more details.

##### Code/data pointers 
- `MapEvent_TransitionPalette` routine: **$1DA8**
  - Handles palette transitions
  - With an interval of 10 frames
- `PaletteTransitionSequencePointerTable`: **$39956**
  - Contains entries for the following transitions:
    - Level 3 pre boss elves
    - Level 3 boss
    - Level 1 boss*
    - Level 2 boss
    - Level 4 mid level transition*
    - Level 7 mid level transition*
  - Starred transitions seem to be the only usefull ones

#### $08: Move camera up on horizontal movement
Does the following:
- Sets new vertically scroll limits.
- Whenever the screen scrolls horizontally:
  - Stop processing the event immediately if the current vertical scroll value is within vertical max bounds.
  - Whenever the camera moves horizontally (only forward possible)
    - Move the camera up by the given amount.

`MapEvent.data` is the index into `VerticalScrollTransitionTable` that contains pointers to `VerticalScrollTransition` structures. 

```
    ; Struct VerticalScrollTransition
      ; Struct ScrollLimit
          dc.w min
          dc.w max
      dc.l verticalScrollAmount ; in 16:16 fixed point format
```

##### Code/data pointers
- `MapEvent_MoveCameraUpOnHScroll` routine: **$1E8C**
- `VerticalScrollTransitionTable`: **$398D2**
  - Contains 4 entries

#### $0c: Set vertical scroll limits
`MapEvent.data` is the index into `VScrollLimitsTable`.

Vertical Scroll limits are stored as follows
```
    ; Struct ScrollLimit
        dc.w min
        dc.w max
```

##### Code/data pointers
- `MapEvent_SetVerticalScrollLimits` routine: **$1D8A**
- `VScrollLimitsTable`: **$398D2**
  - Contains 7 entries

#### $10: Wait for enemy defeat
This prepares the continue sword sign and disables horizontal scrolling until all entity load slots have been processed. In other words when all enemies have been killed.

##### Code/data pointers
- `MapEvent_WaitForEnemyDefeat` routine: **$1D74**

#### $14: Camera transition
Does the following:
- Sets new vertically scroll limits.
- Moves the camera vertically by `.verticalScrollAmount` if:
  - Movement indicated by `.verticalScrollAmount` is up: Starts moving up if the current scroll value is within the vertical scroll min bounds.
  - Movement indicated by `.verticalScrollAmount` is down: Starts moving down if the current scroll value is within the vertical scroll max bounds.
- Moves the camera horizontally by `horizontalScrollAmount` if the horizontal scroll value is within the horizontal scroll max bounds (based on map width)
  - Must be positive (only forward scrolling allowed)
- Event ends once a vertical or horizontal scroll limit has been reached

`MapEvent.data` is the index into `CameraTransitionTable` that contains pointers to `CameraTransition` structures.

```
    ; Struct CameraTransition
      ; Struct ScrollLimit
          dc.w min
          dc.w max
      dc.l verticalScrollAmount   ; in 16:16 fixed point format. Negative means down, positive up.
      dc.l horizontalScrollAmount ; in 16:16 fixed point format
```
##### Code/data pointers
- `MapEvent_CameraTransition` routine: **$1E02**
- `CameraTransitionTable`: **$398EE**
  - Contains 6 entries

#### $18: Switch to camp site once all enemies are defeated
This is used for enemy wave type bosses.

##### Code/data pointers
- `MapEvent_GotoCampSite` routine: **$1D5C**
- `SwitchToCampSite`: **$1282**

#### $1c: Goto next level once all enemies are defeated
This is used for bosses with no camp site after. This has a lower processing priority than event $18.

##### Code/data pointers
- `MapEvent_GotoNextLevel` routine: **$1D60**
- `GotoNextLevel`: **$12A8**

#### $20: End game once all enemies are defeated
This has a lower processing priority than event $18 and $1c

##### Code/data pointers
- `MapEvent_EndGame` routine: **1D64**
- `HandleNormalEnding`: **$26DE**
- `HandleBeginnerEnding`: **$271E**

#### $24: Start water animation
Spawns water entity ($2a) that handles the moving water in turtle village (level 2).

##### Code/data pointers
- `MapEvent_StartWaterAnimation` routine: **$1EC0**
- `WaterEntityLogic`: **$B140**

#### $28: Start spawning feathers
Spawns one feather entity ($29) every 8 frames. These are the feathers that move across the screen in the fiend's path (Level 4).
This event does not end (except by finishing the level).

##### Code/data pointers
- `MapEvent_RepeatSpawnFeathers` routine: **$1ECE**
- `FeatherEntityLogic`: **$B108**

#### $2c: Boss music
First does a music fadeout that lasts $b4 frames. Then starts the boss music.

##### Code/data pointers
- `MapEvent_StartBossMusic` routine: **$1F0E**
