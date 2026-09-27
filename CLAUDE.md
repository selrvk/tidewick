# Tidewick — Project Context

Tidewick is a 2D pixel-art action roguelite made in Godot 4. The player is a lighthouse keeper on a cursed island, defending the lighthouse from fog creatures at night by aiming its beam. This is a solo hobby project and the developer's first game.

## Working with me

- I'm comfortable programming in another language but new to Godot and GDScript.
- **Write the code for me and explain briefly.** A few sentences on what changed and why is enough; call out any Godot concept I'm likely seeing for the first time (signals, scenes, node paths, etc.).
- I'm on **macOS**. The Godot binary (4.7) is at `~/Downloads/Godot.app/Contents/MacOS/Godot` if you need to run it from the terminal.
- When something must be done in the Godot editor rather than in files (e.g. drawing a collision polygon, assigning a texture in the inspector), tell me the exact steps instead of guessing at hand-edited `.tscn` internals.
- Keep scope small. Build the smallest playable version of each feature first. Don't add systems we haven't reached in the roadmap below unless I ask.
- I make all art myself in Aseprite. Use simple placeholder shapes (`ColorRect`, `Polygon2D`) for anything I haven't drawn yet; never block on art.

## Game design

### Core loop
- **Night (main gameplay):** fog creatures approach the lighthouse from all directions. The player aims the beam with the mouse; the beam damages/destroys creatures. The beam uses **fuel (oil)**, so it can't stay on forever.
- **Day:** the player walks around the island (top-down) collecting salvage and oil. The fog shrinks the island a little each night.
- **Between nights:** choose **lens upgrades** from a random selection, e.g. split beam, colored lenses (freeze, burn), rotating auto-beam, wider cone.
- A run ends when the lighthouse falls.

### Game modes
**Roguelite mode — "The Keeper's Tale" (default, main mode)**
- Salvage carries over between runs.
- Spend it rebuilding the harbor town. Buildings unlock things: smithy adds lenses to the upgrade pool, chapel gives one revive per run, tavern adds NPCs, side quests and lore.
- Unlockable keepers with different starting kits (e.g. old sailor: harpoon + weak beam; apprentice: extra fuel, fragile walls).
- Story revealed over runs about why the fog came, ending in sailing to the fog's source for a final boss.

**Roguelike mode — "The Endless Fog" (hardcore)**
- No meta-progression, base kit only, one life, full wipe on death.
- Fully randomized island layout, salvage, and enemies; fog advances faster each night.
- Score = nights survived, with leaderboard. Optional **daily seeded run**.
- **Fog Pacts:** accept a curse (faster enemies, flickering beam) in exchange for a rare lens.

**Build order:** the roguelike mode's core loop comes first (it's just the loop with no meta systems). The town/story layer is added on top later.

### Differentiation note
Drownlight (a Steam survival city-builder) also centers on keeping a lighthouse lit. Tidewick should stay clearly distinct by leaning into **real-time beam-aiming action and roguelite build variety**, not colony/city management.

## Art & presentation

- **View:** top-down 3/4 perspective (like Stardew Valley). The beam must rotate a full 360°.
- **Palette:** PICO-8 (16 colors) only.
- **Grid:** 16×16 tiles. Characters ~16×16 or 16×24. Characters need 4 directions (left can be flipped for right).
- **Existing asset:** `assets/tidewick_lighthouse.png` — 32×64 px canvas, 3/4 view, red/white striped tower, lamp room with railing (around y=12), stone base, soft ground shadow. In `lighthouse.tscn` the sprite has `offset = (0, -28)` so the node's origin sits at the bottom of the stone base for Y-sorting.
- **Mood:** dark navy night, the beam is the brightest thing on screen. Use Godot 2D lighting (`PointLight2D` with a cone texture, `LightOccluder2D` for shadows) once the basic beam works.
- Tall objects must Y-sort with the player (`y_sort_enabled`).

## Technical setup

- **Engine:** Godot 4 (standard, not .NET), GDScript. Use static typing where reasonable (`var speed: float = 20.0`).
- **Project settings** (should already be set; verify if something looks wrong):
  - Viewport 320×180, window override 1280×720
  - Stretch mode `canvas_items`, aspect `keep`, scale mode `integer`
  - Default texture filter `Nearest`
  - Main scene `res://scenes/game.tscn`
- **Suggested structure:**
  ```
  res://
    scenes/      # .tscn files (game.tscn, lighthouse.tscn, enemy.tscn, ...)
    scripts/     # .gd files matching scene names
    assets/      # PNGs exported from Aseprite, with their .aseprite sources alongside
    audio/       # OGG for music
  ```
- Naming: `snake_case` for files and variables, `PascalCase` for node names and class names.
- Use Git; commit after each working milestone.

## Current state

Roadmap steps 1–5 are done; the game is a small playable prototype.

- `scenes/game.tscn` (`Game`, `scripts/game.gd`) is the main scene: PICO-8 dark blue background, the `Lighthouse` instance at (160, 128), an `Enemies` container, a `SpawnTimer`, and a `UI` CanvasLayer with score, lives and game over labels. It spawns enemies just off a random screen edge, tracks lives (3), and on game over lets you click or press R to reload the scene.
- `scenes/lighthouse.tscn`: `Sprite2D` plus `Beam` (`scripts/beam.gd`) at the lamp room (0, -48). The beam turns toward the mouse at a capped `turn_speed` using `rotate_toward`, and builds one cone polygon in code that is shared by the visible `Light` (additive `Polygon2D`) and the `Hitbox` (`Area2D` in group `beam`). A `HitPoint` `Marker2D` at (0, -24) is where enemies aim.
- `scenes/enemy.tscn` (`scripts/enemy.gd`): placeholder lavender ghost (`Polygon2D`) on an `Area2D`. It dies after `burn_time` seconds in the beam and emits `burned` or `reached_lighthouse`.
- Collision layers: layer 1 = beam, layer 2 = enemies (enemies mask layer 1).
- Extras added beyond the roadmap (not yet confirmed as keepers): the 0.3 s burn delay instead of instant kill, a spawn-rate and enemy-speed ramp (belongs to step 7), a score counter, and the enemy wobble.
- Next up: fog creature art to replace the placeholder, then step 6 (fuel).

## Roadmap (do these in order)

1. **Lighthouse in scene:** `Sprite2D` with `lighthouse.png`, centered. Move the beam origin to the lamp room.
2. **Placeholder enemy:** `Area2D` + shape that moves toward the lighthouse with `move_toward`.
3. **Beam kills enemies:** `Area2D` + `CollisionPolygon2D` matching the cone; `queue_free()` enemies that enter it.
4. **Spawner:** spawn enemies from random screen edges on a timer.
5. **Lighthouse health + game over / restart.**
6. **Fuel:** beam drains oil while on; toggle beam with a mouse button; empty = no beam.
7. **Night structure:** waves per night, escalating difficulty, "nights survived" counter.
8. **Lens upgrades between nights** (pick 1 of 3).
9. **Day phase:** player character walking the island, collecting oil/salvage.
10. **Roguelike mode polish:** randomization, Fog Pacts, score screen, daily seed.
11. **Roguelite layer:** persistent save, harbor town, keepers, story, final boss.

Milestone goal for 1–4: a tiny playable game where you survive fog creatures by aiming the light. Art for the fog creature comes right after that works.
