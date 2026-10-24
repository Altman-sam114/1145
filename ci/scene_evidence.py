"""Small cloud trace protocol; no simulator operations or shadow Swift geometry."""
import hashlib
import json
import math
from pathlib import Path
import plistlib
import re

TRACE_LIMIT = 262144
STAGES = {"terrain", "map", "control-points", "units", "hud", "fog", "fixture", "initialization"}
CHECKS = {"initialized", "geometry", "map", "units", "hud", "fog", "fixture", "contractRestored"}
ACTIONS = {"tactical": 9, "build": 6, "air": 2, "naval": 3, "support": 6}
INVALIDATORS = {"geometry-invalidated", "geometry-applied", "hud-start", "trace-incomplete"}
SNAPSHOT_POLICY = "post-capture-latest-ready-v1"


def finite(value):
    return type(value) in (int, float) and math.isfinite(value) and value >= 0


def file_evidence(directory, name, limit=TRACE_LIMIT):
    if not isinstance(name, str) or Path(name).name != name:
        raise ValueError("Trace must use a results-directory basename")
    path = directory / name
    if path.is_symlink() or not path.is_file() or path.stat().st_size > limit:
        raise ValueError("Trace is a symlink or oversized")
    data = path.read_bytes()
    if len(data) > limit:
        raise ValueError("Trace grew beyond its size limit")
    return {"path": name, "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}, data


def trace_records(summary, scene, directory, snapshots=None):
    if not re.fullmatch(r"[0-9a-f]{32}", scene.get("nonce", "")):
        raise ValueError("Missing/invalid launch nonce")
    identity = {key: summary.get(key) for key in ("commitSha", "runId", "runAttempt", "version")}
    identity.update(pid=scene.get("pid"), probeID=scene.get("probeID"), nonce=scene["nonce"],
                    deviceUDID=summary.get("selectedDevice", {}).get("udid"))
    records = []
    for channel in ("stdout", "stderr"):
        suffix = ".log" if scene.get("sealed") else ".live.log"
        if scene[channel].get("path") != f"scene-{scene['nonce']}-{channel}{suffix}":
            raise ValueError("Trace filename does not match this launch/channel")
        evidence, data = file_evidence(directory, scene[channel]["path"])
        scene[channel] = evidence
        if snapshots is not None:
            snapshots[channel] = (evidence, data)
        if channel == "stderr":
            continue
        for line in data.splitlines(keepends=True):
            if not line.startswith(b"DESERTCI "):
                continue
            if not line.endswith(b"\n"):
                return records + [{"stage": "trace-incomplete"}]
            if len(line) > 8192:
                raise ValueError("Oversized scene beacon")
            item = json.loads(line[9:])
            if (item.get("schemaVersion") != 1 or item.get("producer") != "GameScene.CIReadiness"
                    or any(not value or item.get(key) != value for key, value in identity.items())
                    or item.get("sequence") != len(records) + 1
                    or not finite(item.get("uptimeSeconds")) or not finite(item.get("elapsedSeconds"))):
                raise ValueError("Scene beacon identity/sequence/time mismatch")
            if records and (item["uptimeSeconds"] < records[-1]["uptimeSeconds"] or item["elapsedSeconds"] < records[-1]["elapsedSeconds"]):
                raise ValueError("Scene monotonic time moved backwards")
            records.append(item)
            scene["lastStage"] = item["stage"]
            if item["stage"] == "trace-limit-exceeded":
                raise ValueError("App scene trace exceeded its per-line/launch byte limit")
    return records


def latest_ready(records, definition):
    candidates = [index for index, item in enumerate(records) if item["stage"] == "ready"]
    if not candidates:
        return None
    index = candidates[-1]
    if any(item["stage"] in INVALIDATORS for item in records[index + 1:]):
        return None
    ready = records[index]
    valid_since = max((offset for offset, item in enumerate(records[:index]) if item["stage"] in INVALIDATORS), default=-1)
    frames, counts = ready.get("frames", []), ready.get("counts", {})
    fixture_checks = ready.get("fixtureChecks", {})
    expected_branch = (definition["marker"] if definition["marker"] not in ("none", "move", "attack-move", "attack-target", "combat-ui", "incoming-ui")
                       else "coast-default" if definition["focus"] == "coast" else definition["focus"])
    if (any(ready.get(key) != definition[key] for key in ("page", "marker", "focus"))
            or ready.get("fixtureBranch") != expected_branch or set(ready.get("checks", {})) != CHECKS
            or any(value is not True for value in ready["checks"].values())
            or not fixture_checks or any(value is not True for value in fixture_checks.values())
            or not STAGES <= set(ready.get("completedStages", []))
            or not STAGES <= {item["stage"][:-4] for item in records[:index] if item["stage"].endswith("-end")}
            or len(frames) != 2 or any(not finite(frame.get("time")) or type(frame.get("number")) is not int for frame in frames)
            or frames[1]["number"] <= frames[0]["number"] or frames[1]["time"] <= frames[0]["time"]
            or type(ready.get("geometryRevision")) is not int or ready["geometryRevision"] < 1
            or any(frame.get("revision") != ready["geometryRevision"] for frame in frames)
            or not all(frame in [item.get("frame") for item in records[valid_since + 1:index] if item["stage"] == "stable-frame"] for frame in frames)
            or any(type(counts.get(key)) is not int or counts[key] <= 0 for key in ("mapNodes", "entities", "playerUnits", "visiblePlayerUnits", "fogNodes", "visibleTiles"))
            or counts.get("panels") != 7 or counts.get("pages") != 5 or counts.get("actions") != ACTIONS[definition["page"]]):
        raise ValueError("Scene ready lacks production stages, fixture facts or stable frames")
    rendering = ready.get("renderConfiguration")
    if (not isinstance(rendering, dict) or set(rendering) != {"automaticCulling", "ignoresSiblingOrder", "viewClass"}
            or rendering.get("viewClass") != "GameRenderView"
            or any(rendering.get(key) is not False for key in ("automaticCulling", "ignoresSiblingOrder"))):
        raise ValueError("Scene ready render configuration missing or invalid")
    size, view, insets = ready.get("sceneSize", {}), ready.get("viewSize", {}), ready.get("insets", {})
    if (not all(finite(size.get(key)) and finite(view.get(key)) and abs(size[key] - view[key]) < 1 for key in ("width", "height"))
            or size["width"] <= size["height"] or set(insets) != {"top", "left", "bottom", "right"}
            or not all(finite(value) for value in insets.values())):
        raise ValueError("Scene ready window geometry invalid")
    projection = ready.get("projection")
    if not isinstance(projection, dict) or projection.get("policy") != "world-node-affine-v1":
        raise ValueError("Scene ready projection missing or unsupported")
    bindings = projection.get("bindings")
    if (not isinstance(bindings, dict) or set(bindings) != {"nativeCameraDisabled", "hudAttached", "worldAttached", "hostScene"}
            or any(value is not True for value in bindings.values())
            or type(projection.get("visiblePlayerUnits")) is not int or projection["visiblePlayerUnits"] <= 0):
        raise ValueError("Scene ready projection bindings or visible units invalid")
    logical, transform = ready.get("camera"), projection.get("worldTransform")
    if (not isinstance(logical, dict) or set(logical) != {"x", "y", "scale"}
            or not isinstance(transform, dict) or set(transform) != {"x", "y", "scaleX", "scaleY"}
            or any(type(value) not in (int, float) or not math.isfinite(value)
                   for value in [*logical.values(), *transform.values()]) or logical["scale"] <= 0):
        raise ValueError("Scene ready projection world transform invalid")
    inverse = 1 / logical["scale"]
    expected = {"x": -logical["x"] * inverse, "y": -logical["y"] * inverse, "scaleX": inverse, "scaleY": inverse}
    if any(not math.isfinite(value) or abs(transform[key] - value) > 0.001 for key, value in expected.items()):
        raise ValueError("Scene ready projection differs from its logical camera")
    for key in ("cameraCenter", "hudOrigin"):
        point = projection.get(key)
        if (not isinstance(point, dict) or set(point) != {"x", "y"}
                or not all(finite(point.get(axis)) for axis in ("x", "y"))
                or math.hypot(point["x"] - view["width"] / 2, point["y"] - view["height"] / 2) >= 1):
            raise ValueError("Scene ready projection is not centered in the host view")
    return ready


def seal_scene(summary, scene, directory, definition):
    """Freeze latest-ready bytes after capture; keep live logs as diagnostics."""
    observed = {}
    records = trace_records(summary, scene, directory, snapshots=observed)
    ready = latest_ready(records, definition)
    if scene.get("sealed") or ready is None or ready != scene.get("ready"):
        raise ValueError("Scene changed or lost readiness before trace snapshot")
    snapshots = {}
    for channel in ("stdout", "stderr"):
        _, data = observed[channel]
        name = f"scene-{scene['nonce']}-{channel}.log"
        (directory / name).write_bytes(data)
        snapshots[channel], _ = file_evidence(directory, name)
    scene["directFiles"] = {key: scene[key] for key in snapshots}
    scene.update(snapshots, sealed=True, snapshotPolicy=SNAPSHOT_POLICY)


def validate_scene(summary, record, directory, definition, expected_probe_id):
    scene = record.get("scene", {})
    current = dict(scene)
    records = trace_records(summary, current, directory)
    ready = latest_ready(records, definition)
    if (scene.get("status") != "success" or record.get("pid") != scene.get("pid") or ready is None
            or scene.get("probeID") != expected_probe_id or scene.get("sealed") is not True
            or scene.get("snapshotPolicy") != SNAPSHOT_POLICY or not finite(scene.get("sealedAtMonotonic"))
            or ready != scene.get("ready") or any(current[key] != scene.get(key) for key in ("stdout", "stderr"))):
        raise ValueError("Current scene readiness or trace integrity missing/stale")
    return ready


def validate_page_images(records):
    seen = set()
    for record in records[:5]:
        sha = record.get("image", {}).get("sha256")
        if sha and sha in seen:
            raise ValueError("Distinct first-five HUD pages produced an identical PNG")
        if sha:
            seen.add(sha)


def read_app_document(data_root, descriptor, nonce, bundle_id, filename):
    limits = {"hud-layout-contract.json": 1048576, "render-world.png": 8388608, "render-hud.png": 8388608}
    if filename not in limits:
        raise ValueError("Unsupported App diagnostic document")
    limit = limits[filename]
    root, source = data_root.resolve(strict=True), Path(descriptor["path"])
    resolved = source.resolve(strict=True)
    relative = resolved.relative_to(root)
    parts = relative.parts
    if (not source.is_absolute() or source.relative_to(data_root).parts != parts
            or any((data_root.joinpath(*parts[:count])).is_symlink() for count in range(1, len(parts) + 1))
            or len(parts) != 8 or parts[:3] != ("Containers", "Data", "Application")
            or not re.fullmatch(r"[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}", parts[3])
            or parts[4:] != ("Documents", "DesertCI", nonce, filename)
            or not resolved.is_file() or not 0 < resolved.stat().st_size <= limit):
        raise ValueError("App document escaped selected device/App Documents nonce directory")
    metadata = root.joinpath(*parts[:4], ".com.apple.mobile_container_manager.metadata.plist")
    if metadata.is_symlink() or not metadata.is_file() or not 0 < metadata.stat().st_size <= 65536:
        raise ValueError("Current App container metadata unavailable")
    if plistlib.loads(metadata.read_bytes()).get("MCMMetadataIdentifier") != bundle_id:
        raise ValueError("App document container belongs to a different bundle")
    data = resolved.read_bytes()
    if len(data) > limit or len(data) != descriptor.get("bytes") or hashlib.sha256(data).hexdigest() != descriptor.get("sha256"):
        raise ValueError("App document length/hash mismatch")
    return data


def read_hud_report(data_root, descriptor, nonce, bundle_id):
    return read_app_document(data_root, descriptor, nonce, bundle_id, "hud-layout-contract.json")
