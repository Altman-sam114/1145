# Desert Frontline

Desert Frontline is an iOS SpriteKit RTS prototype inspired by the gameplay shape of Desert Stormfront and the provided reference screenshot. It does not reuse original game art; all map tiles, units, buildings, HUD elements, fog, and effects are generated with SpriteKit shapes.

## Current Features

- iOS SwiftUI app shell with a full-screen SpriteKit scene.
- Isometric desert map matching the reference's desert RTS layout: roads, ridges, coastline, water, oil fields, base clusters, desert villages, oases, farms, depots, wreckage, and fog of war.
- Economy loop: HQ base income, capturable oil derricks, front-line flag control points with income, scout vision, limited build coverage, and one-time capture bonuses, visible money/income HUD, and AI income scaling by difficulty.
- Production queues from War Factory, Airfield, Shipyard, and Carrier decks with selected/least-busy source routing, visible factory progress bars, factory/carrier rally points, and ready pulses on the map.
- Base construction from the HUD: place War Factory, Airfield, Radar Outpost, Sonar Buoy, Guard Tower, SAM Site, Coastal Battery, Shipyard, and Oil Derricks during play with a green/red placement preview, timed construction scaffolds, and visible build progress.
- Building rules: structures require vision and nearby friendly operational structure or captured flag build coverage; Shipyards, Sonar Buoys, and Coastal Batteries require coast tiles; Oil Derricks require oil fields.
- New structures are attackable while under construction but do not produce units, earn income, provide vision, provide support assets, extend base coverage, or fire weapons until operational.
- Radar Outposts are buildable land structures that provide extended static scout vision and count as `SCAN` assets once operational.
- Sonar Buoys are buildable coastal detector structures that provide static vision and sonar detection once operational; they do not attack, produce units, earn income, or count as `SCAN` assets.
- Guard Towers are buildable land defense structures that automatically fire on visible land, air, and structure targets once operational; they do not attack naval units or submarines and do not provide sonar.
- SAM Sites are buildable land anti-air structures that automatically fire on visible air targets once operational; they do not attack land, naval, submarine, or structure targets and do not provide sonar.
- Coastal Batteries are buildable coastal defense structures that automatically fire on visible surface naval targets once operational; they do not attack submarines and do not provide sonar.
- Land units: Humvee scout, AA Truck, Tank, Artillery, Mechanic.
- AA Trucks are War Factory-built mobile anti-air units that fire on visible air targets; they do not attack land, naval, submarine, or structure targets and do not provide sonar.
- Air units: Helicopter, Fighter.
- Naval units: Battleship, Submarine, Carrier.
- Carriers act as mobile sea-based air platforms that can build Helicopters and Fighters, launch aircraft from the deck, and set air rally points.
- Carrier strike visuals, naval combat, air-to-ground/naval combat, artillery range advantage, submarine stealth, sonar detection, firing reveal pings, direct-fire ASW hit shock-ring feedback for player-known or visible submarines, and brief submarine exposure when `AIRS` or `BARR` actually hits a submarine.
- Combat units gain veterancy XP and kill counts from direct-fire kills, progressing from Recruit through Hardened, Veteran, and Elite with light damage, attack cooldown, and vision bonuses.
- Non-Recruit units show SpriteKit veterancy badges above the unit, and the selection panel reports rank, XP, kills, effective stats, ASW attack capability, sonar range, submarine stealth/detected state, group ASW/sonar summaries, and group veterancy distribution.
- Selecting player active sonar sensors overlays their sonar coverage rings on the battlefield; multi-selection shows multiple rings, while unfinished Sonar Buoys and enemy sensors do not show coverage.
- Tactical support powers from the bottom command bar: `SCAN` reveals a target area from an operational HQ or Radar Outpost, `REPR` restores damaged friendly assets, `AIRS` calls an air strike, and `BARR` calls naval fire support with economy costs, cooldowns, asset requirements, and map effects.
- Mission objective panel with automatic stage completion: secure oil, capture front-line flags, deploy mixed land/air/naval forces, break enemy production, then destroy the Red HQ.
- Unit selection, select-all army button, hold-position guard orders, attack-move advances, move orders, attack orders, health bars, explosions, automatic mechanic repairs, repair sparks.
- Tactical selection panel with current unit/building stats, production state, rally/queue information, ASW attack versus sonar sensor status, submarine detection state, and multi-unit formation composition.
- Under-attack alerts with throttled HUD warnings, battlefield pings, and minimap pulses when player units or structures take enemy fire.
- Domain-aware formation move orders keep land, air, and naval groups separated on valid terrain during player commands and AI assaults.
- Terrain-aware movement: land and naval units follow waypoint paths around blocked terrain while air units fly directly; land units prefer roads, move faster on roads, and slow slightly on oil fields.
- Drag selection box for player mobile units.
- Tactical minimap with terrain, friendly/enemy/neutral blips, camera box, and tap-to-jump camera control.
- Two-finger map pan, HQ focus, and select-all combat controls.
- Enemy AI that earns money, builds mixed land/air/naval forces including mobile anti-air, prioritizes AA Trucks or Fighters when known player air pressure exceeds current anti-air coverage, conservatively queues Helicopters, Fighters, Submarines, Battleships, or Carriers when Red-known player submarines exceed current ASW coverage, targets `SCAN` at Red-known submarines or patrols water/coast hotspots around Red-held flags and operational sonar assets instead of reading hidden submarine coordinates, treats Fighters as ASW attackers but not sonar sensors, skips units that currently lack an operational source or enough funds while preserving its mixed build pattern, captures oil and front-line flags with reserved runners kept out of routine attack-move waves until the target is captured or the runner becomes invalid, prioritizes recapturing player-held or player-contested flags before neutral expansion when choosing flag targets, pulls nearby non-reserved combat units to defend Red-held flags when player units are spotted contesting them, can use captured flags as forward build anchors, rebuilds lost production, detection, and defense structures including Sonar Buoys, SAM Sites, and Coastal Batteries, launches attack-move waves toward flags, oil fields, production structures, defensive structures, and HQ targets, assigns tactical targets per unit role, uses domain-aware attack approach positions for land/air/naval forces, pulls nearby defenders when its base is hit, and supports Easy/Normal/Hard difficulty from the HUD.
- Restartable skirmishes that cycle through map variants and reset the match state.
- Victory and defeat conditions based on HQ destruction.

## Controls

- Tap a player unit to select it.
- Double-tap a player mobile unit to select visible units of the same type in the current camera view.
- Drag on the battlefield to box-select mobile player units.
- Tap `G1` or `G2` to recall a saved control group of live player mobile units.
- Double-tap `G1` or `G2` to save the current player mobile-unit selection to that group; empty or structure-only selections do not overwrite an existing group.
- Control groups store unit IDs only, and dead or removed units are filtered when a group is recalled.
- Tap ground with units selected to move in formation.
- Tap a visible enemy with combat units selected to attack.
- Tap `HOLD` with mobile units selected to make them guard their current positions and return if pulled too far away.
- Tap `AMOV` with combat units selected, then tap the map to advance in formation while engaging visible enemies en route.
- Select a War Factory, Airfield, Shipyard, or Carrier, tap `RLY`, then tap the map to set its rally point for newly produced units.
- Invalid map targets for building, rally, attack-move, support powers, impossible attacks, or non-mobile selections briefly show a red/orange denied marker at the clicked location while keeping the HUD message.
- Tap the tactical minimap to move the camera.
- Use two fingers to pan the battlefield; pinch with two fingers to zoom the tactical camera in or out.
- Use `BASE` to cycle through War Factory, Airfield, Radar Outpost, Sonar Buoy, Guard Tower, SAM Site, Coastal Battery, Shipyard, and Oil Derrick placement, drag or tap the map to preview valid placement, then tap a valid tile to start constructing the selected structure.
- Use `SCAN`, `REPR`, `AIRS`, or `BARR`, then tap the map to target recon, field repair, air strike, or naval barrage support.
- `BASE`, `RLY`, `AMOV`, `SCAN`, `REPR`, `AIRS`, and `BARR` highlight while waiting for a map target.
- Use `ARMY`, any unit production button, HQ focus, or AI difficulty to leave structure placement/rally modes.
- Use `SKRM` to start a new skirmish map variant.
- Use the bottom HUD buttons to select the army, save or recall control groups, hold ground, build units, focus HQ, cycle AI difficulty, place structures, or restart the skirmish.

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

For larger goals, `agentx:` (`x:` / `X:`) starts the Agent X control loop. Agent X splits the goal into smaller Agent A -> Agent B -> Agent C rounds and decides whether to continue, return for fixes, pause, or finish after Agent C artifact review; it does not replace the A/B/C roles.

Feature changes must update this README with current behavior. Test or verification changes must update both this README and `md/test/test.md`.

## Collaboration And Cloud Validation

The default validation path is `main` direct push plus GitHub Actions. Local full Xcode builds are kept for explicit requests or extra investigation; routine agent work should rely on the CI results package described in `md/test/test.md`.
