# Desert Frontline

Desert Frontline is an iOS SpriteKit RTS prototype inspired by the gameplay shape of Desert Stormfront and the provided reference screenshot. It does not reuse original game art; all map tiles, units, buildings, HUD elements, fog, and effects are generated with SpriteKit shapes.

## Current Features

- iOS SwiftUI app shell with a full-screen SpriteKit scene.
- Isometric desert map matching the reference's desert RTS layout: roads, ridges, coastline, water, oil fields, base clusters, desert villages, oases, farms, depots, wreckage, and fog of war.
- Economy loop: HQ base income, capturable oil derricks, front-line flag control points with income and scout vision, visible money/income HUD, and AI income scaling by difficulty.
- Production queues from War Factory, Airfield, Shipyard, and Carrier decks with selected/least-busy source routing, visible factory progress bars, factory/carrier rally points, and ready pulses on the map.
- Base construction from the HUD: place War Factory, Airfield, Shipyard, and Oil Derricks during play with a green/red placement preview, timed construction scaffolds, and visible build progress.
- Building rules: structures require vision and nearby friendly base coverage; Shipyards require coast tiles; Oil Derricks require oil fields.
- New structures are attackable while under construction but do not produce units, earn income, or extend base coverage until operational.
- Land units: Humvee scout, Tank, Artillery, Mechanic.
- Air units: Helicopter, Fighter.
- Naval units: Battleship, Submarine, Carrier.
- Carriers act as mobile sea-based air platforms that can build Helicopters and Fighters, launch aircraft from the deck, and set air rally points.
- Carrier strike visuals, naval combat, air-to-ground/naval combat, artillery range advantage, submarine stealth, sonar detection, and firing reveal pings.
- Combat units gain veterancy XP and kill counts from direct-fire kills, progressing from Recruit through Hardened, Veteran, and Elite with light damage, attack cooldown, and vision bonuses.
- Non-Recruit units show SpriteKit veterancy badges above the unit, and the selection panel reports rank, XP, kills, effective stats, and group veterancy distribution.
- Tactical support powers from the bottom command bar: `SCAN` reveals a target area, `REPR` restores damaged friendly assets, `AIRS` calls an air strike, and `BARR` calls naval fire support with economy costs, cooldowns, asset requirements, and map effects.
- Mission objective panel with automatic stage completion: secure oil, capture front-line flags, deploy mixed land/air/naval forces, break enemy production, then destroy the Red HQ.
- Unit selection, select-all army button, hold-position guard orders, attack-move advances, move orders, attack orders, health bars, explosions, automatic mechanic repairs, repair sparks.
- Tactical selection panel with current unit/building stats, production state, rally/queue information, and multi-unit formation composition.
- Under-attack alerts with throttled HUD warnings, battlefield pings, and minimap pulses when player units or structures take enemy fire.
- Domain-aware formation move orders keep land, air, and naval groups separated on valid terrain during player commands and AI assaults.
- Terrain-aware movement: land and naval units follow waypoint paths around blocked terrain while air units fly directly; land units prefer roads, move faster on roads, and slow slightly on oil fields.
- Drag selection box for player mobile units.
- Tactical minimap with terrain, friendly/enemy/neutral blips, camera box, and tap-to-jump camera control.
- Two-finger map pan, HQ focus, and select-all combat controls.
- Enemy AI that earns money, builds mixed land/air/naval forces, captures oil and front-line flags, rebuilds lost production structures, launches attack-move waves toward flags, oil fields, production structures, and HQ targets, assigns tactical targets per unit role, uses domain-aware attack approach positions for land/air/naval forces, pulls nearby defenders when its base is hit, and supports Easy/Normal/Hard difficulty from the HUD.
- Restartable skirmishes that cycle through map variants and reset the match state.
- Victory and defeat conditions based on HQ destruction.

## Controls

- Tap a player unit to select it.
- Drag on the battlefield to box-select mobile player units.
- Tap ground with units selected to move in formation.
- Tap a visible enemy with combat units selected to attack.
- Tap `HOLD` with mobile units selected to make them guard their current positions and return if pulled too far away.
- Tap `AMOV` with combat units selected, then tap the map to advance in formation while engaging visible enemies en route.
- Select a War Factory, Airfield, Shipyard, or Carrier, tap `RLY`, then tap the map to set its rally point for newly produced units.
- Tap the tactical minimap to move the camera.
- Use two fingers to pan the battlefield; pinch with two fingers to zoom the tactical camera in or out.
- Use `BASE` to cycle through buildable structures, drag or tap the map to preview valid placement, then tap a valid tile to start constructing the selected structure.
- Use `SCAN`, `REPR`, `AIRS`, or `BARR`, then tap the map to target recon, field repair, air strike, or naval barrage support.
- Use `ARMY`, any unit production button, HQ focus, or AI difficulty to leave structure placement/rally modes.
- Use `SKRM` to start a new skirmish map variant.
- Use the bottom HUD buttons to select the army, hold ground, build units, focus HQ, cycle AI difficulty, place structures, or restart the skirmish.

## Open In Xcode

Open `DesertFrontline.xcodeproj`, choose the `DesertFrontline` scheme, and run on an iPhone or iPad target.

The command-line validation used for this workspace was:

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
  -project DesertFrontline.xcodeproj \
  -scheme DesertFrontline \
  -configuration Debug \
  -sdk iphoneos \
  -destination generic/platform=iOS \
  -derivedDataPath build/DerivedDataDevice \
  CODE_SIGNING_ALLOWED=NO \
  build
```

The local simulator service in this environment was unavailable, so simulator launch was not verified here. The generic iOS device build succeeds.

## Development Workflow

Future Codex / programming-agent work should start from `AGENTS.md`, then read `update_log.md`, `md/flow/flow.md`, `md/flow/flowchart.md`, and `md/test/test.md`.

The project now uses an Agent A/B/C iteration loop:

- Agent A writes versioned implementation prompts under `md/prompt/`.
- Agent B implements on `main`, runs local lightweight checks, commits, and pushes to `origin/main`.
- GitHub Actions runs the cloud validation workflow and uploads an unencrypted CI results package.
- Agent C downloads the latest `main` results package, checks the manifest, JUnit summary, Xcode build log, and failure summary, then either accepts the run or returns a fix list to Agent B.

Feature changes must update this README with current behavior. Test or verification changes must update both this README and `md/test/test.md`.

## Collaboration And Cloud Validation

The default validation path is `main` direct push plus GitHub Actions. Local full Xcode builds are kept for explicit requests or extra investigation; routine agent work should rely on the CI results package described in `md/test/test.md`.
