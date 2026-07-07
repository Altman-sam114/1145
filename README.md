# Desert Frontline

Desert Frontline is an iOS SpriteKit RTS prototype inspired by the gameplay shape of Desert Stormfront and the provided reference screenshot. It does not reuse original game art; all map tiles, units, buildings, HUD elements, fog, and effects are generated with SpriteKit shapes.

## Current Features

- iOS SwiftUI app shell with a full-screen SpriteKit scene.
- Isometric desert map matching the reference's desert RTS layout: roads, ridges, coastline, water, oil fields, base clusters, desert villages, oases, farms, depots, wreckage, and fog of war.
- Economy loop: HQ base income, capturable oil derricks, front-line flag control points with income, scout vision, limited build coverage, and one-time capture bonuses, visible money/income HUD, and AI income scaling by difficulty.
- Production queues from War Factory, Airfield, Shipyard, and Carrier decks with selected/least-busy source routing, land unit button subtitles that show the current `WF` source or `need WF`, `HELI` / `JET` button subtitles that show the current `AF` / `CV` source or `need AF/CV`, `SHIP` / `SUB` / `CV` subtitles that show the current `SY` source or `need SY`, visible factory progress bars, factory/carrier rally points with pending source summaries, and ready pulses on the map.
- Base construction from the HUD: place War Factory, Airfield, Radar Outpost, Sonar Buoy, Guard Tower, SAM Site, Coastal Battery, Shipyard, and Oil Derricks during play with a green/red placement preview, timed construction scaffolds, and visible build progress.
- Building rules: structures require vision and nearby friendly operational structure or captured flag build coverage; Shipyards, Sonar Buoys, and Coastal Batteries require coast tiles; Oil Derricks require oil fields.
- New structures are attackable while under construction but do not produce units, earn income, provide vision, provide support assets, extend base coverage, or fire weapons until operational.
- Radar Outposts are buildable land structures that provide extended static scout vision and count as `SCAN` assets once operational.
- Sonar Buoys are low-cost, fragile coastal detector structures that provide limited static vision and wide sonar detection once operational; they do not attack, produce units, earn income, or count as `SCAN` assets.
- Guard Towers are buildable land defense structures that automatically fire on visible land, air, and structure targets once operational; they do not attack naval units or submarines and do not provide sonar.
- SAM Sites are buildable land anti-air structures that automatically fire on visible air targets once operational; they do not attack land, naval, submarine, or structure targets and do not provide sonar.
- Coastal Batteries are buildable coastal defense structures that automatically fire on visible surface naval targets once operational; they do not attack submarines and do not provide sonar.
- Land units: Humvee scout, AA Truck, Tank, Artillery, Mechanic.
- AA Trucks are War Factory-built mobile anti-air units that fire on visible air targets; they do not attack land, naval, submarine, or structure targets and do not provide sonar.
- Air units: Helicopter, Fighter.
- Naval units: Battleship, Submarine, Carrier.
- Carriers act as mobile sea-based air platforms that can build Helicopters and Fighters, show short deck-launch cues when aircraft are produced, set air rally points, surface `CV` as the `HELI` / `JET` button source when selected or least busy, report deck production, rally set/unset state, nearby HEL/JET wing readiness with `Wing x/2 OK Hn/Jn` or `Wing x/2 Need n Hn/Jn`, switch that line to compact bound-guard status such as `GW x/2 OK H1 J1 C0` or `GW x/2 Need n H1 Cm Air/Sea/Sub/Ground/Mix Tgt XXX Eng n` while the Carrier itself is holding and only count nearby HEL/JET still bound to that Carrier's guard anchor, bind up to two nearest nearby HEL/JET per Carrier on player HOLD, show short `GW Hn/Jn` deck cues and `Guard wing n Hn/Jn` top-message feedback when HOLD successfully binds guard aircraft, keep those bound aircraft on stable nearby guard stations while the Carrier remains holding, let them prioritize known attackable threats near the Carrier before falling back to ordinary HOLD target search, show nonzero `Eng n` when bound guard aircraft currently have legal Carrier-guard attack targets, show `CV GUARD` with anchor distance when selecting bound guard aircraft, show the anchor Carrier's guard-radius ring when those guard aircraft are selected, show a selected HOLD Carrier's own guard-radius ring even before it has bound guard aircraft, plus nearby escort status with `OK` or `Need n Air/Sea/Ground/Mix` hints in the single-selection panel, contribute compact `CV GW x/y OK/Need Hn/Jn Cn Eng n` summaries when multi-selecting HOLD Carrier groups, and contribute to multi-selection high-value naval escort summaries that also surface gap-type hints when under-escorted; selected player Carriers and Battleships show an escort radius ring for the same nearby-escort range.
- Carrier wing-strike visuals, naval combat, air-to-ground/naval combat, artillery range advantage, submarine stealth, sonar detection, firing reveal pings, direct-fire ASW hit shock-ring feedback for player-known or visible submarines, and brief submarine exposure when `AIRS` or `BARR` actually hits a submarine.
- Combat units gain veterancy XP and kill counts from direct-fire kills, progressing from Recruit through Hardened, Veteran, and Elite with light damage, attack cooldown, and vision bonuses.
- Non-Recruit units show SpriteKit veterancy badges above the unit, and the selection panel reports rank, XP, kills, effective stats, ASW attack capability, sonar range with known enemy submarine contact counts for selected player active sonar sensors, player submarine temporary detection or known enemy sonar contact state, group ASW/sonar summaries with deduplicated known submarine contacts for selected player sonar sensors, and group veterancy distribution.
- Selecting player active sonar sensors overlays their sonar coverage rings on the battlefield; selecting player Carriers or Battleships overlays warm escort radius rings; selecting bound Carrier guard aircraft overlays a guard-radius ring on the anchor Carrier, and selecting a player HOLD Carrier overlays its own guard-radius ring even without bound guard aircraft; multi-selection shows multiple rings, while unfinished Sonar Buoys, enemy sensors, enemy high-value naval units, unbound aircraft, non-HOLD Carriers, and non-selected units do not show these selection-derived guard visuals.
- Tactical support powers from the bottom command bar: `SCAN` reveals a target area from an operational HQ or Radar Outpost, `REPR` restores damaged friendly assets, `AIRS` calls an air strike, and `BARR` calls naval fire support with economy costs, cooldowns, asset requirements, map effects, button subtitles that show cooldown seconds, specific missing asset hints such as `need HQ/RAD`, `need HQ/MECH`, `need AF/CV`, or `need BB/CV`, a funds shortfall such as `need $350`, or the price when ready with an asset and enough money, and target panels that show `Asset ready` / `Need` support-asset status.
- Mission objective panel with automatic stage completion: secure oil, capture front-line flags, secure any two operational coastal assets with `SY` / `SON` / `CB` progress summary, deploy mixed land/air/naval forces, and break enemy production for one-time resource rewards, then destroy the Red HQ with HP intel and attack-move guidance shown only when the HQ is player-known.
- Unit selection, select-all army button, hold-position guard orders, Carrier HOLD guard-wing assignment for nearby friendly operational Helicopters/Fighters with lightweight Carrier anchor binding, short `CV GUARD` assignment cues, station keeping, and Carrier-near known threat priority, attack-move advances, move orders, attack orders, health bars, explosions, automatic mechanic repairs, mechanic repair range feedback, and repair sparks.
- Tactical selection panel with current unit/building stats, production state, rally/queue information, Carrier deck Helicopter/Fighter status, Carrier nearby HEL/JET wing readiness with `Hn` / `Jn` composition or compact bound HOLD guard-wing status with the same composition format, known guard-contact counts, nonzero contact type hints, priority-contact short codes, and nonzero guard-wing engagement counts, selected bound HEL/JET `CV GUARD` anchor-distance status plus compact multi-selection guard-aircraft summaries with `Hn` / `Jn` composition and anchor distance, anchor Carrier guard-radius visuals for selected bound aircraft or selected HOLD Carriers even without bound guard aircraft, multi-selection HOLD Carrier `CV GW x/y OK/Need Hn/Jn Cn Eng n` summaries, Carrier/Battleship nearby escort status with `OK` or `Need n` plus short Air/Sea/Ground/Mix gap hints when under-escorted, multi-selection high-value naval escort summaries with the same gap-type hints, escort radius visuals, selected-player-Mechanic repair range rings and damaged-target counts, damaged-player-mobile-unit nearest Mechanic repair-source hints, Shipyard/Sonar Buoy/Coastal Battery coastal-asset roles plus `Secure Coast` counted/pending/not-counted state, ASW attack versus sonar sensor status, player submarine temporary detection or known enemy sonar contact state, multi-selection sonar contact summaries that respect player-known fog boundaries, and multi-unit formation composition.
- Under-attack alerts with throttled HUD warnings, battlefield pings, and minimap pulses when player units or structures take enemy fire.
- Domain-aware formation move orders keep land, air, and naval groups separated on valid terrain during player commands and AI assaults.
- Terrain-aware movement: land and naval units follow waypoint paths around blocked terrain while air units fly directly; land units prefer roads, move faster on roads, and slow slightly on oil fields.
- Drag selection box for player mobile units.
- Tactical minimap with terrain, friendly/enemy/neutral blips, camera box, and tap-to-jump camera control.
- Two-finger map pan, HQ focus, and select-all combat controls.
- Enemy AI that earns money, builds mixed land/air/naval forces including mobile anti-air, prioritizes AA Trucks or Fighters when known player air pressure exceeds current anti-air coverage, conservatively queues Helicopters, Fighters, Submarines, Battleships, or Carriers when Red-known player submarines exceed current ASW coverage, targets `SCAN` at Red-known submarines or patrols water/coast hotspots around Red-held flags and operational sonar assets instead of reading hidden submarine coordinates, treats Fighters as ASW attackers but not sonar sensors, skips units that currently lack an operational source or enough funds while preserving its mixed build pattern, captures oil and front-line flags with reserved runners kept out of routine attack-move waves until the target is captured or the runner becomes invalid, prioritizes recapturing player-held or player-contested flags before neutral expansion when choosing flag targets, pulls nearby non-reserved combat units to defend Red-held flags when player units are spotted contesting them, can use captured flags as forward build anchors, rebuilds lost production, detection, and defense structures including Sonar Buoys, SAM Sites, and Coastal Batteries, lets idle Carriers bind nearby idle Helicopters/Fighters into the same guard-wing anchor behavior used by player HOLD Carriers, keeps currently bound Carrier guard Helicopters/Fighters out of ordinary routine assault wave selection so they retain their anchor escort role but can carry those bound aircraft into the same attack wave when the anchor Carrier itself is accepted into the assault, launches routine attack-move waves that first try to mix frontline, anti-air, ranged, air, and naval support toward flags, oil fields, production structures, defensive structures, coastal infrastructure, and HQ targets while keeping low-health Veteran/Elite units and unescorted Battleships or Carriers out of routine assaults until they recover or the provisional wave has enough escorts or mixed force mass, shows the latest player-detectable Red assault wave subset size and compact land/air/naval plus CV/HEL/JET composition in the HUD status line, gives known player Shipyards, Sonar Buoys, and Coastal Batteries extra target weight when Red has structure-capable naval pressure, sends low-health routine assault units back toward nearby Mechanics or the Red base anchor until they recover, biases enemy Field Repair scoring toward low-health Veteran/Elite and retreating combat units, assigns tactical targets per unit role, uses domain-aware attack approach positions for land/air/naval forces, pulls nearby defenders when its base is hit, and supports Easy/Normal/Hard difficulty from the HUD.
- Restartable skirmishes that cycle through map variants and reset the match state.
- Victory and defeat conditions based on HQ destruction.

## Controls

- Tap a player unit to select it.
- Double-tap a player mobile unit to select visible units of the same type in the current camera view.
- Drag on the battlefield to box-select mobile player units.
- Tap `G1` or `G2` to recall a saved control group of live player mobile units.
- Double-tap `G1` or `G2` to save the current player mobile-unit selection to that group; empty or structure-only selections do not overwrite an existing group.
- Control groups store unit IDs only, and dead or removed units are filtered when a group is recalled.
- Tap ground with units selected to move in formation; if the order releases bound Carrier guard aircraft, the success message reports how many left `CV GUARD` with `Hn` / `Jn` composition.
- Tap a visible enemy with combat units selected to attack; if assigned aircraft leave a Carrier guard wing for that attack, the success message reports the release count with `Hn` / `Jn` composition.
- Tap `HOLD` with mobile units selected to make them guard their current positions and return if pulled too far away; when a selected Carrier holds, up to two nearest nearby friendly operational Helicopters/Fighters are also assigned to hold as its guard wing with top-message and short deck-cue `Hn` / `Jn` composition feedback, bound to that Carrier for the compact `GW` HUD count, kept on stable nearby guard stations, reported as `CV GUARD` with anchor distance and an anchor Carrier guard-radius ring when those aircraft are selected, with the HOLD Carrier also showing its own guard-radius ring even before any aircraft are bound, and biased toward known attackable threats near that Carrier while it remains holding until they receive a new move, attack-move, attack, or ordinary hold order. Successful ordinary hold orders also report how many previously bound aircraft left `CV GUARD` with `Hn` / `Jn` composition when they are not immediately rebound to a Carrier.
- Tap the bottom HUD `AMOV` button with combat units selected, then tap the map to advance in formation while engaging visible enemies en route; if the attack-move releases bound Carrier guard aircraft, the success message reports how many left `CV GUARD` with `Hn` / `Jn` composition. During the final Red HQ objective, a known Red HQ gets a short target cue plus HP and approximate nearest-distance details in the selection panel when `AMOV` is armed.
- Select a War Factory, Airfield, Shipyard, or Carrier, tap `RLY`, then tap the map to set its rally point for newly produced units; while `RLY` is armed, the selection panel shows rally source counts, land/air/naval source types, set/unset totals, and `Tap map to set rally`.
- Invalid map targets for building, rally, attack-move, support powers, impossible attacks, or non-mobile selections briefly show a red/orange denied marker at the clicked location while keeping the HUD message.
- Tap the tactical minimap to move the camera.
- Use two fingers to pan the battlefield; pinch with two fingers to zoom the tactical camera in or out.
- Use `BASE` to cycle through War Factory, Airfield, Radar Outpost, Sonar Buoy, Guard Tower, SAM Site, Coastal Battery, Shipyard, and Oil Derrick placement, drag or tap the map to preview valid placement, then tap a valid tile to start constructing the selected structure.
- `HMV`, `AA`, `TANK`, `ART`, and `MECH` subtitles show whether the next land unit will come from a `WF`; without an operational War Factory they show `need WF`.
- `HELI` and `JET` subtitles show whether the next aircraft will come from an `AF` or `CV`; without an operational air source they show `need AF/CV`.
- `SHIP`, `SUB`, and `CV` subtitles show whether the next naval unit will come from a `SY`; without an operational Shipyard they show `need SY`.
- Use `SCAN`, `REPR`, `AIRS`, or `BARR`, then tap the map to target recon, field repair, air strike, or naval barrage support; their button subtitles show cooldown seconds first, then missing-asset hints, then funds shortfall, then price, and their target panels show `Asset ready` or `Need` for the required support asset.
- `BASE`, `RLY`, `AMOV`, `SCAN`, `REPR`, `AIRS`, and `BARR` highlight while waiting for a map target.
- Use `ARMY`, any unit production button, HQ focus, or AI difficulty to leave structure placement/rally modes.
- Use `SKRM` to start a new skirmish map variant.
- Use the bottom HUD buttons to select the army, save or recall control groups, hold ground, attack-move, build units, focus HQ, cycle AI difficulty, place structures, or restart the skirmish.

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
