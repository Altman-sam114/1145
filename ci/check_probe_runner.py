#!/usr/bin/env python3
"""Standard-library CI regressions; never boots or queries a simulator."""
import errno
import hashlib
import json
import os
from pathlib import Path
import plistlib
import select
import signal
import struct
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import Mock, patch
import uuid
import zlib

from simulator_probe import (HUD_CHECKS, HUD_FIXTURES, HUD_PAGES, Runner, ProbeFailure, SceneFailure,
                             BOOT_POLICY, boot_monitor_semantics, boot_reserve, boot_wait_classification, validate_boot,
                             INSTALL_CAP, INSTALL_POLICY, INSTALL_RECOVERY_CAP, cli_receipt_complete, install_reserve,
                             load_probes, png_info, select_device, validate_hud_contract, validate_installation,
                             validate_results, validate_scene_evidence)
from scene_evidence import (ACTIONS, CHECKS, STAGES, TRACE_LIMIT, file_evidence, latest_ready,
                            read_hud_report, seal_scene, trace_records, validate_page_images, validate_scene)
from run_bounded import run_bounded
from package_results import main as package_results


NORMALIZATION_EVIDENCE = []
WATCHDOG_RECEIPT_EVIDENCE = []
# Synthetic legacy formatting, not evidence of a real older Xcode interface.
LEGACY_MINIMAL_BOOT_HELP = "Monitor the boot status of a device.\nUsage: simctl bootstatus <device> [-b]\n\n  -b  Boot the device if it isn't already booted.\n"
BOOT_MONITOR_PARAGRAPH = "Monitors the specified device and prints boot status information until the device finishes booting."
BOOT_HELP = LEGACY_MINIMAL_BOOT_HELP + "\n" + BOOT_MONITOR_PARAGRAPH + "\n"
BOOT_HELP_FIXTURE = Path(__file__).with_name("fixtures") / "bootstatus-help-run39841781150.txt"
# Historical official CLI input only; never copied into production run evidence.
BOOT_HELP_SOURCE = {"runId": "39841781150", "runAttempt": 1, "artifactId": 12452729094,
                    "commitSha": "ccdff57c5505840dadaf038b6176ca4a636c9c88", "path": "boot-help.log",
                    "bytes": 442, "sha256": "1bb8a0fabb52cfad5e7cdb4e93b7f1b22bc643c8cb875d2f3fd15bf70085e5eb"}


def boot_wait_text(udid, status=2):
    tail = ("\tWaiting on Data Migration\n\t\tReason:Running plugin unit.fixture.migrator\n\t\tMigration Elapsed:03:49 seconds\n"
            if status == 2 else "\tWaiting on System App\n")
    return (f"Monitoring boot status for Synthetic iPhone ({udid}).\n"
            f"[2026-10-22 19:02:00 +0000] Status={status}, isTerminal=NO, Elapsed=04:00.\n{tail}\n")


def scene_fixture(runner, definition, probe_id, nonce=None, extra_ready=None, sealed=False):
    """Synthetic protocol records, not executed Swift, device geometry or GPU evidence."""
    for key in ("commitSha", "runId", "runAttempt", "version"):
        if not runner.summary.get(key):
            runner.summary[key] = f"unit-fixture-{key}"
    runner.summary["selectedDevice"] = runner.device
    scene = dict(nonce=nonce or uuid.uuid4().hex, probeID=probe_id, pid=os.getpid(),
                 status="running", launchedAtMonotonic=time.monotonic())
    identity = {key: runner.summary[key] for key in ("commitSha", "runId", "runAttempt", "version")}
    identity.update(schemaVersion=1, producer="GameScene.CIReadiness", pid=scene["pid"], probeID=probe_id,
                    nonce=scene["nonce"], deviceUDID=runner.device["udid"])
    records = []

    def emit(stage, **extra):
        sequence = len(records) + 1
        records.append(dict(identity, stage=stage, sequence=sequence, uptimeSeconds=100 + sequence,
                            elapsedSeconds=sequence, **extra))

    for stage in sorted(STAGES):
        emit(stage + "-end")
    frames = [dict(number=1, time=1, revision=1), dict(number=2, time=2, revision=1)]
    for frame in frames:
        emit("stable-frame", frame=frame)
    branch = (definition["marker"] if definition["marker"] not in
              ("none", "move", "attack-move", "attack-target", "combat-ui", "incoming-ui") else
              "coast-default" if definition["focus"] == "coast" else definition["focus"])
    emit("ready", checks={key: True for key in CHECKS}, fixtureChecks={"syntheticSchemaOnly": True},
         fixtureBranch=branch, completedStages=sorted(STAGES), frames=frames, geometryRevision=1,
         page=definition["page"], marker=definition["marker"], focus=definition["focus"],
         counts=dict(mapNodes=1, entities=1, playerUnits=1, visiblePlayerUnits=1, fogNodes=1,
                     visibleTiles=1, panels=7, pages=5, actions=ACTIONS[definition["page"]]),
         sceneSize=dict(width=874, height=402), viewSize=dict(width=874, height=402),
         insets=dict(top=0, left=62, right=62, bottom=21), **(extra_ready or {}))
    for channel in ("stdout", "stderr"):
        path = runner.directory / f"scene-{scene['nonce']}-{channel}.live.log"
        data = b"".join(b"DESERTCI " + json.dumps(item, sort_keys=True).encode() + b"\n" for item in records) if channel == "stdout" else b""
        path.write_bytes(data)
        scene[channel], _ = file_evidence(runner.directory, path.name)
    scene.update(status="success", ready=records[-1], lastStage="ready")
    if sealed:
        seal_scene(runner.summary, scene, runner.directory, definition)
        scene["sealedAtMonotonic"] = time.monotonic()
    return scene


def unit_cli_receipt(code=0, cap=INSTALL_CAP, timeout=False):
    """Synthetic schema fixture only; real watchdog receipts use a separate suite."""
    stopped = timeout or code >= 128
    return dict(schemaVersion=1, scope="owned-cli-process-group-only", pid=os.getpid(), pgid=os.getpid(),
                trigger="timeout" if timeout else "cancelled" if code >= 128 else "exit",
                limitSeconds=cap, reaped=True, returnCode=-15 if stopped else code, exitCode=code,
                term={"status": "sent" if stopped else "not_needed"},
                kill={"status": "already_gone" if stopped else "not_needed"},
                cleanupOutcome="success" if stopped else "not_needed", cleanupElapsedSeconds=0.5 if stopped else 0,
                elapsedSeconds=cap + 0.5 if timeout else 0.6 if stopped else 0.1)


def boot_fixture(runner, continuation=False):
    """Explicitly synthetic schema-only boot chain; no CLI or device was executed."""
    for key in ("branch", "commitSha", "runId", "runAttempt", "version"):
        if not runner.summary.get(key):
            runner.summary[key] = f"unit-fixture-{key}"
    runner.summary["selectedDevice"] = runner.device
    device, budget = runner.device, runner.summary["workBudgetSeconds"]
    evidence = dict(schemaVersion=1, policy=BOOT_POLICY, status="success", commands=[], admissions=[],
                    identity={key: runner.summary[key] for key in ("branch", "commitSha", "runId", "runAttempt", "version")},
                    selectedDevice={"udid": device["udid"], "runtimeIdentifier": device["runtime"]["identifier"],
                                    "dataPath": device["dataPath"]}, deadlineAfterSeconds=budget,
                    monitorSemantics=boot_monitor_semantics(BOOT_HELP))
    stages, elapsed = [], 0
    for role in (["help", "initial", "wait:1", "wait:2"] if continuation else ["help", "initial", "wait:1"]):
        cap = 10 if role == "help" else 60 if role == "initial" else 240
        timeout = role == "wait:1" and continuation
        code, duration = (124, cap + 0.5) if timeout else (0, 0.1)
        args = (["help", "bootstatus"] if role == "help" else ["boot", device["udid"]] if role == "initial" else
                ["bootstatus", device["udid"]])
        text = BOOT_HELP if role == "help" else boot_wait_text(device["udid"]) if timeout else ""
        log = f"boot-{role.replace(':', '-')}.log"
        (runner.directory / log).write_text(text)
        admission = dict(phase=f"boot-admission:{role}", remainingSeconds=budget - elapsed, requestedCapSeconds=cap,
                         maxCapSeconds=min(cap, budget - elapsed - 559), installReserveSeconds=557,
                         cliCleanupReserveSeconds=2, allowed=True)
        record = dict(role=role, argv=["/usr/bin/xcrun", "simctl", *args], admission=admission,
                      requestedCapSeconds=cap, effectiveCapSeconds=cap, startedAfterSeconds=elapsed,
                      endedAfterSeconds=elapsed + duration, elapsedSeconds=duration,
                      remainingStartSeconds=budget - elapsed, remainingEndSeconds=budget - elapsed - duration,
                      status="failure" if timeout else "success", exitCode=code, process=unit_cli_receipt(code, cap, timeout),
                      output={"path": log, "bytes": len(text.encode()), "sha256": hashlib.sha256(text.encode()).hexdigest()})
        if role == "initial": record["classification"] = "booted"
        if timeout:
            record.update(classification=boot_wait_classification(record, text, device["udid"]), continuationDecision="continue")
        elif role.startswith("wait:"):
            record.update(classification="ready", continuationDecision="completed" if continuation else "not_needed")
        evidence["commands"].append(record)
        evidence["admissions"].append(admission)
        stages += [dict(name=f"boot-admission:{role}", status="success", exitCode=0),
                   dict(name=f"boot-{role}", status=record["status"], exitCode=code)]
        elapsed += duration
    runner.summary["boot"] = evidence
    runner.summary["stages"] = stages + [stage for stage in runner.summary["stages"] if not stage["name"].startswith("boot")]


def installation_fixture(runner):
    runner.bundle = "unit.fixture.only"
    runner.summary["selectedDevice"] = runner.device
    runner.summary["appProduct"] = {"bundleId": runner.bundle, "path": "unit.app"}
    reserve = install_reserve(runner.probes)
    admission = dict(phase="install-admission:1", requiredSeconds=INSTALL_CAP + 2 + reserve, remainingSeconds=1080,
                     postInstallReserveSeconds=reserve, allowed=True)
    data = b"synthetic install schema fixture, not simulator evidence\n"
    (runner.directory / "install-attempt-1.log").write_bytes(data)
    attempt = dict(attempt=1, udid=runner.device["udid"], bundleId=runner.bundle, appPath="unit.app", status="success", exitCode=0,
                   requestedCapSeconds=INSTALL_CAP, effectiveCapSeconds=INSTALL_CAP, remainingStartSeconds=1080,
                   remainingEndSeconds=1079.9, elapsedSeconds=0.1, process=unit_cli_receipt(), admission=admission,
                   retryable=False, retryReason="installed", retryDecision="not_needed",
                   output={"path": "install-attempt-1.log", "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()})
    runner.summary["installation"] = dict(schemaVersion=1, policy=INSTALL_POLICY, status="success", udid=runner.device["udid"],
                                          bundleId=runner.bundle, appPath="unit.app", attempts=[attempt], admissions=[admission])


def hud_fixture(runner):
    """Schema-only synthetic unit fixture; not a second layout or simulator evidence."""
    for key in ("commitSha", "runId", "runAttempt", "version"):
        if not runner.summary.get(key):
            runner.summary[key] = f"unit-fixture-{key}"
    pid = os.getpid()
    nonce = uuid.uuid4().hex
    runner.summary["prewarm"] = [{"attempt": 1, "status": "success", "pid": pid, "aliveAfterWait": True}]
    report = {key: runner.summary[key] for key in ("commitSha", "runId", "runAttempt", "version")}
    report.update(schemaVersion=1, producer="GameScene.HUDLayout", pid=pid, nonce=nonce, probeID="prewarm:1",
                  status="success", stateRestored=True,
                  actualSize={"width": 874, "height": 402}, actualInsets={"top": 0, "left": 62, "bottom": 21, "right": 62}, matrix=[])

    def label_audit(controls, phases):
        # Count-only protocol placeholders, not Python glyph measurements or a font model.
        ids = sorted({f"hud-text:{control}:{part}" for control in controls
                      if control.startswith(("page:", "action:")) for part in ("title", "subtitle")} | {"hud-text:unit-placeholder"})
        count = len(ids)
        records = []
        for phase in phases:
            referenced = phase in {"long2", "restored", "rebuilt", "actual-restored"}
            records.append(dict(phase=phase, fitPasses=2, registryValid=True, measuredCount=count, nonemptyCount=count, visibleNonemptyCount=count,
                positiveBoundsCount=count, containedCount=count, finiteGeometryCount=count, sourcePreservedCount=count,
                idempotentCount=count, parentPreservedCount=count, appearancePreservedCount=count, fontRangeCount=count,
                referenceRequired=referenced, referenceMatchedCount=count if referenced else 0,
                baseEligibleCount=count if phase == "short" else 0, baseRecoveredCount=count if phase == "short" else 0,
                failureCount=0, status="success"))
        return dict(schemaVersion=1, coordinateSpace="label-parent-local", registeredCount=count, labelIDs=ids, phases=records,
                    failureCount=0, omittedFailureCount=0, details=[], status="success")

    for fixture, (width, height) in HUD_FIXTURES.items():
        insets = (report["actualInsets"] if fixture == "874x402" else
                  {"top": 0, "left": 59, "bottom": 21, "right": 59} if fixture == "852x393" else
                  {"top": 0, "left": 0, "bottom": 0, "right": 0})
        for page in sorted(HUD_PAGES):
            # Deliberate placeholders: Python validates schema, not these fake rectangles.
            rectangle = {"x": 0, "y": 0, "width": 1, "height": 1}
            controls = {f"page:{tab}": rectangle for tab in HUD_PAGES}
            controls.update({key: rectangle for key in ("zoomOut", "zoomIn", "map", "action:unit-placeholder")})
            report["matrix"].append(dict(fixture=fixture, page=page, size={"width": width, "height": height}, insets=insets,
                checks={key: True for key in HUD_CHECKS}, failures=[], status="success", safeFrame=rectangle,
                panels={key: rectangle for key in ("resources", "rail", "dock", "mission", "message", "selection", "minimap")},
                controls=controls, panelArea=1, viewportArea=2, panelAreaFraction=0.5,
                labelAudit=label_audit(controls, ["normal", "long1", "short", "long2", "restored", "rebuilt"])))
    report["actualLabelAudit"] = label_audit(report["matrix"][0]["controls"], ["actual-normal", "actual-restored"])
    write_hud_fixture(runner, report)
    descriptor = dict(runner.summary["hudContract"], path=f"/synthetic/Documents/DesertCI/{nonce}/hud-layout-contract.json")
    runner.summary["prewarm"][0]["scene"] = scene_fixture(runner, runner.probes[0], "prewarm:1", nonce=nonce,
                                                        extra_ready={"hudReport": descriptor}, sealed=True)


def write_hud_fixture(runner, report):
    data = json.dumps(report, sort_keys=True).encode()
    (runner.directory / "hud-layout-contract.json").write_bytes(data)
    runner.summary["hudContract"] = {"path": "hud-layout-contract.json", "pid": os.getpid(), "status": "success",
                                     "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}
    for warm in runner.summary.get("prewarm", []):
        descriptor = warm.get("scene", {}).get("ready", {}).get("hudReport")
        if descriptor is not None:
            # Let each HUD negative exercise its own assertion, not a stale fixture hash.
            descriptor.update(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def png_bytes(color=128):
    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", 2, 1, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(b"\x00" + bytes((color, 144, 160, 255)) * 2)) + chunk(b"IEND", b""))


def rgb_fixture(width, height):
    colors = [(255, 0, 0), (0, 255, 0), (255, 0, 255), (0, 255, 255), (0, 0, 255), (255, 255, 0)]
    pixels = b"".join(bytes(color) for color in colors)
    scanlines = b"".join(b"\x00" + pixels[row * width * 3:(row + 1) * width * 3] for row in range(height))

    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))

    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(scanlines)) + chunk(b"IEND", b""))


def fixture_pixels(path):
    """Decode only the tiny RGB/RGBA regression fixture, including sips PNG filters."""
    info = png_info(path)
    if info["width"] * info["height"] > 64:
        raise ValueError("Not a tiny normalization fixture")
    data = path.read_bytes()
    channels = {2: 3, 6: 4}[data[25]]
    offset, compressed = 8, bytearray()
    while offset < len(data):
        length = struct.unpack_from(">I", data, offset)[0]
        if data[offset + 4:offset + 8] == b"IDAT":
            compressed.extend(data[offset + 8:offset + 8 + length])
        offset += length + 12
    scanlines = zlib.decompress(compressed)
    stride = info["width"] * channels
    previous, rows = bytearray(stride), []
    for y in range(info["height"]):
        start = y * (stride + 1)
        filtering = scanlines[start]
        row = bytearray(scanlines[start + 1:start + stride + 1])
        for x in range(stride):
            left = row[x - channels] if x >= channels else 0
            up = previous[x]
            upper_left = previous[x - channels] if x >= channels else 0
            if filtering == 1:
                predictor = left
            elif filtering == 2:
                predictor = up
            elif filtering == 3:
                predictor = (left + up) // 2
            elif filtering == 4:
                estimate = left + up - upper_left
                predictor = min((left, up, upper_left), key=lambda value: abs(value - estimate))
            else:
                predictor = 0
            row[x] = (row[x] + predictor) & 255
        rows.append([tuple(row[x:x + 3]) for x in range(0, stride, channels)])
        previous = row
    return rows


class FakeRunner(Runner):
    fail_at = None

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.device = {"udid": "fake-cloud-unit-test-only", "runtime": {"identifier": "synthetic.runtime.only"},
                       "dataPath": "/synthetic/device/data"}

    def launch(self, name, definition):
        self.current_definition = definition
        self.last_scene = scene_fixture(self, definition, name.removesuffix(":launch"))
        if definition["id"] == self.fail_at:
            raise ProbeFailure("injected launch timeout", 124)
        return os.getpid()

    def wait(self, name, seconds):
        self.remaining(seconds)

    def wait_scene(self, record, definition, minimum, window=30):
        self.remaining(minimum)
        ready = latest_ready(trace_records(self.summary, record["scene"], self.directory), definition)
        if ready is None:
            raise SceneFailure("Synthetic scene is not ready")
        record["scene"].update(status="success", ready=ready)

    def simctl(self, name, *args, **kwargs):
        if args[0] == "io":
            color = list(ACTIONS).index(self.current_definition["page"]) + 120
            Path(args[-1]).write_bytes(png_bytes(color))

    def work(self):
        boot_fixture(self)
        installation_fixture(self)
        hud_fixture(self)
        for index, definition in enumerate(self.probes):
            self.capture(definition, index)
        validate_results(self.probes, self.summary, self.directory)
        self.summary["integrityOutcome"] = "success"


class ProbeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.directory = Path(self.temp.name)
        self.probes = load_probes()
        self.signals = {sig: signal.getsignal(sig) for sig in (signal.SIGTERM, signal.SIGINT)}

    def tearDown(self):
        for sig, handler in self.signals.items():
            signal.signal(sig, handler)
        self.temp.cleanup()

    def complete(self):
        runner = FakeRunner(self.directory)
        runner.work()
        return runner

    def test_24_normal_results(self):
        runner = self.complete()
        validate_results(self.probes, runner.summary, self.directory)
        self.assertEqual(runner.summary["counts"]["completed"], 24)

    def test_missing_result(self):
        runner = self.complete()
        runner.summary["probes"].pop()
        with self.assertRaises(ProbeFailure):
            validate_results(self.probes, runner.summary, self.directory)

    def test_duplicate_id(self):
        self.probes[1]["id"] = self.probes[0]["id"]
        path = self.directory / "probes.json"
        path.write_text(json.dumps(self.probes))
        with self.assertRaises(ProbeFailure):
            load_probes(path)

    def test_duplicate_path(self):
        self.probes[1]["png"] = self.probes[0]["png"]
        path = self.directory / "probes.json"
        path.write_text(json.dumps(self.probes))
        with self.assertRaises(ProbeFailure):
            load_probes(path)

    def test_empty_png(self):
        path = self.directory / "empty.png"
        path.write_bytes(b"")
        with self.assertRaises(ProbeFailure):
            png_info(path)

    def test_bad_png_crc(self):
        path = self.directory / "bad.png"
        data = bytearray(png_bytes())
        data[-1] ^= 1
        path.write_bytes(data)
        with self.assertRaises(ProbeFailure):
            png_info(path)

    def test_truncated_png_data(self):
        path = self.directory / "bad.png"
        path.write_bytes(png_bytes()[:40])
        with self.assertRaises(ProbeFailure):
            png_info(path)

    def test_missing_png(self):
        runner = self.complete()
        (self.directory / self.probes[-1]["png"]).rename(self.directory / "missing.png")
        with self.assertRaises(FileNotFoundError):
            validate_results(self.probes, runner.summary, self.directory)

    def test_dead_pid(self):
        runner = FakeRunner(self.directory)
        with patch("simulator_probe.alive", return_value=False), self.assertRaises(ProbeFailure):
            runner.capture(self.probes[0], 0)
        self.assertEqual(runner.summary["probes"][0]["status"], "failure")

    def test_command_timeout(self):
        runner = Runner(self.directory)
        with self.assertRaises(ProbeFailure) as error:
            runner.command("timeout-fixture", [sys.executable, "-c", "import time; time.sleep(30)"], cap=0.1)
        self.assertEqual(error.exception.code, 124)

    def test_shared_deadline_propagation(self):
        runner = Runner(self.directory, budget=2.2)
        with patch("simulator_probe.run_bounded", return_value=0) as command:
            runner.command("deadline-fixture", ["fake"], cap=120)
        self.assertGreater(command.call_args.args[1], 0)
        self.assertLessEqual(command.call_args.args[1], 0.2)

    def test_budget_exhausted_no_command(self):
        runner = Runner(self.directory, budget=0)
        with patch("simulator_probe.run_bounded") as command, self.assertRaises(ProbeFailure):
            runner.command("exhausted", ["must-not-run"])
        command.assert_not_called()

    def test_failure_summary_survives(self):
        runner = FakeRunner(self.directory)
        runner.fail_at = self.probes[1]["id"]
        self.assertEqual(runner.execute(), 124)
        summary = json.loads((self.directory / "simulator-probe-summary.json").read_text())
        self.assertEqual(summary["status"], "failure")
        self.assertEqual(summary["counts"], {"expected": 24, "completed": 1, "failed": 1, "notRun": 22, "running": 0})
        self.assertEqual(summary["lastCompletedProbe"], self.probes[0]["id"])
        self.assertLess(summary["cleanupElapsedSeconds"], 90)

    def test_deadline_failure_summary_survives(self):
        runner = FakeRunner(self.directory, budget=0)
        self.assertEqual(runner.execute(), 124)
        summary = json.loads((self.directory / "simulator-probe-summary.json").read_text())
        self.assertEqual(summary["counts"]["failed"], 1)
        self.assertEqual(summary["counts"]["notRun"], 23)

    def test_runtime_selection_is_deterministic(self):
        runtimes = {"runtimes": [
            {"identifier": "com.apple.CoreSimulator.SimRuntime.iOS-26-2", "version": "26.2", "isAvailable": True},
            {"identifier": "com.apple.CoreSimulator.SimRuntime.iOS-27-0", "version": "27.0", "isAvailable": True},
        ]}
        devices = {"devices": {
            runtimes["runtimes"][0]["identifier"]: [{"name": "iPhone Z", "udid": "z", "isAvailable": True},
                                                    {"name": "iPhone A", "udid": "a", "isAvailable": True}],
            runtimes["runtimes"][1]["identifier"]: [{"name": "iPhone A", "udid": "future", "isAvailable": True}],
        }}
        selected = select_device(runtimes, devices, "17.0", "26.5")
        self.assertEqual(selected["udid"], "a")
        with self.assertRaises(ProbeFailure):
            select_device(runtimes, devices, "26.5", "26.5")

    def test_tampered_image_evidence(self):
        runner = self.complete()
        runner.summary["probes"][0]["image"]["sha256"] = "wrong"
        with self.assertRaises(ProbeFailure):
            validate_results(self.probes, runner.summary, self.directory)

    def test_missing_raw_image_evidence(self):
        runner = self.complete()
        del runner.summary["probes"][0]["rawImage"]
        with self.assertRaises(ProbeFailure):
            validate_results(self.probes, runner.summary, self.directory)

    def test_missing_rotation_evidence(self):
        runner = self.complete()
        del runner.summary["probes"][0]["rotationDegrees"]
        with self.assertRaises(ProbeFailure):
            validate_results(self.probes, runner.summary, self.directory)

    def test_wrong_rotation_evidence(self):
        runner = self.complete()
        runner.summary["probes"][0]["rotationDegrees"] = 90
        with self.assertRaises(ProbeFailure):
            validate_results(self.probes, runner.summary, self.directory)

    def test_wrong_normalization_policy(self):
        runner = self.complete()
        runner.summary["probes"][0]["normalizationPolicy"] = "unknown"
        with self.assertRaises(ProbeFailure):
            validate_results(self.probes, runner.summary, self.directory)

    def test_raw_dimensions_mismatch(self):
        runner = self.complete()
        record = runner.summary["probes"][0]
        record["rawImage"].update(width=1, height=3)
        record["rotationDegrees"] = 270
        with self.assertRaises(ProbeFailure):
            validate_results(self.probes, runner.summary, self.directory)

    def test_native_landscape_raw_changed(self):
        runner = self.complete()
        runner.summary["probes"][0]["rawImage"]["bytes"] += 1
        with self.assertRaises(ProbeFailure):
            validate_results(self.probes, runner.summary, self.directory)

    def test_raw_hash_invalid(self):
        runner = self.complete()
        runner.summary["probes"][0]["rawImage"]["sha256"] = "wrong"
        with self.assertRaises(ProbeFailure):
            validate_results(self.probes, runner.summary, self.directory)

    def mutate_hud(self, mutate):
        runner = self.complete()
        report = json.loads((self.directory / "hud-layout-contract.json").read_text())
        mutate(report)
        write_hud_fixture(runner, report)
        with self.assertRaises(ProbeFailure):
            validate_hud_contract(runner.summary, self.directory)

    def test_hud_stale_identity(self):
        self.mutate_hud(lambda report: report.update(runAttempt="old-attempt"))

    def test_hud_wrong_producer(self):
        self.mutate_hud(lambda report: report.update(producer="python-shadow-layout"))

    def test_hud_wrong_pid(self):
        self.mutate_hud(lambda report: report.update(pid=os.getpid() + 10000))

    def test_hud_state_not_restored(self):
        self.mutate_hud(lambda report: report.update(stateRestored=False))

    def test_hud_missing_case(self):
        self.mutate_hud(lambda report: report["matrix"].pop())

    def test_hud_duplicate_case(self):
        self.mutate_hud(lambda report: report["matrix"].__setitem__(-1, report["matrix"][0]))

    def test_hud_failed_assertion_despite_pass_status(self):
        self.mutate_hud(lambda report: report["matrix"][0]["checks"].update(routing=False))

    def test_hud_missing_assertion(self):
        self.mutate_hud(lambda report: report["matrix"][0]["checks"].pop("pending"))

    def test_hud_missing_report(self):
        runner = self.complete()
        (self.directory / "hud-layout-contract.json").rename(self.directory / "missing-contract.json")
        with self.assertRaises(FileNotFoundError):
            validate_results(self.probes, runner.summary, self.directory)

    def test_hud_tampered_file_hash(self):
        runner = self.complete()
        runner.summary["hudContract"]["sha256"] = "0" * 64
        with self.assertRaises(ProbeFailure):
            validate_results(self.probes, runner.summary, self.directory)

    def test_hud_collection_not_validated(self):
        runner = self.complete()
        runner.summary["hudContract"]["status"] = "collected"
        with self.assertRaises(ProbeFailure):
            validate_results(self.probes, runner.summary, self.directory)

    def assert_hud_audit_rejected(self, mutation):
        runner = self.complete()
        report = json.loads((self.directory / "hud-layout-contract.json").read_text())
        mutation(report)
        self.assertEqual(report["status"], "success")
        self.assertIs(report["stateRestored"], True)
        self.assertTrue(all(all(row["checks"].values()) and row["failures"] == [] for row in report["matrix"]))
        write_hud_fixture(runner, report)
        warm = runner.summary["prewarm"][0]
        descriptor = dict(runner.summary["hudContract"], path=warm["scene"]["ready"]["hudReport"]["path"])
        warm["scene"] = scene_fixture(runner, runner.probes[0], "prewarm:1", nonce=warm["scene"]["nonce"],
                                      extra_ready={"hudReport": descriptor}, sealed=True)
        with self.assertRaisesRegex(ProbeFailure, "HUD label audit"):
            validate_hud_contract(runner.summary, self.directory)
        with self.assertRaisesRegex(ProbeFailure, "HUD label audit"):
            validate_results(runner.probes, runner.summary, self.directory)
        runner.summary.update(status="success", integrityOutcome="success")
        runner.save()
        environment = {key: runner.summary[field] for key, field in (
            ("CI_VERSION", "version"), ("GITHUB_REF_NAME", "branch"), ("GITHUB_SHA", "commitSha"),
            ("GITHUB_RUN_ID", "runId"), ("GITHUB_RUN_ATTEMPT", "runAttempt"))}
        environment.update(WORKFLOW_NAME="synthetic HUD audit fixture", GITHUB_OUTPUT=str(self.directory / "outputs"),
                           STATIC_OUTCOME="success", PROJECT_LINT_OUTCOME="success", BUILD_OUTCOME="success",
                           SIMULATOR_LAUNCH_OUTCOME="success")
        with patch.dict(os.environ, environment), patch("package_results.Path", side_effect=lambda path:
                self.directory if path == "ci-results" else Path(path)):
            package_results()
        manifest = json.loads((self.directory / "ci-artifact-manifest.json").read_text())
        self.assertEqual(manifest["hudLayoutContractOutcome"], "failure")
        self.assertEqual(manifest["probeIntegrityOutcome"], "failure")
        for key in ("simulatorBootOutcome", "simulatorInstallOutcome", "sceneReadinessOutcome"):
            self.assertEqual(manifest[key], "success")

    def test_hud_label_audit_missing_or_malformed_is_rejected(self):
        mutations = {
            "missing-matrix-audit": lambda report: report["matrix"][0].pop("labelAudit"),
            "missing-actual-audit": lambda report: report.pop("actualLabelAudit"),
            "bad-audit-type": lambda report: report["matrix"][0].update(labelAudit=[]),
            "bad-schema-type": lambda report: report["matrix"][0]["labelAudit"].update(schemaVersion=True),
            "wrong-coordinate-space": lambda report: report["matrix"][0]["labelAudit"].update(coordinateSpace="scene"),
            "missing-phase": lambda report: report["matrix"][0]["labelAudit"]["phases"].pop(),
            "duplicate-phase": lambda report: report["matrix"][0]["labelAudit"]["phases"][1].update(phase="normal"),
            "duplicate-id": lambda report: report["matrix"][0]["labelAudit"]["labelIDs"].__setitem__(1, report["matrix"][0]["labelAudit"]["labelIDs"][0]),
            "missing-action-label": lambda report: report["matrix"][0]["labelAudit"]["labelIDs"].__setitem__(0, "hud-text:omitted-action-placeholder"),
            "bad-count": lambda report: report["matrix"][0]["labelAudit"]["phases"][0].update(measuredCount=-1),
            "missing-count": lambda report: report["matrix"][0]["labelAudit"]["phases"][0].pop("sourcePreservedCount"),
            "bool-count": lambda report: report["matrix"][0]["labelAudit"]["phases"][0].update(idempotentCount=True),
            "registry-mismatch": lambda report: report["matrix"][0]["labelAudit"].update(registeredCount=64),
            "oversized-registry": lambda report: report["matrix"][0]["labelAudit"].update(labelIDs=[f"hud-text:{index}" for index in range(65)], registeredCount=65),
        }
        for name, mutate in mutations.items():
            with self.subTest(mutation=name):
                self.assert_hud_audit_rejected(mutate)

    def test_hud_label_audit_failed_or_incomplete_cannot_hide_behind_success(self):
        mutations = {
            "failed-audit": lambda report: report["matrix"][0]["labelAudit"].update(status="failure"),
            "omitted-failures": lambda report: report["matrix"][0]["labelAudit"].update(failureCount=9, omittedFailureCount=9),
            "unreported-details": lambda report: report["matrix"][0]["labelAudit"].update(details=[{"id": "synthetic-failure"}]),
            "failed-phase": lambda report: report["matrix"][0]["labelAudit"]["phases"][0].update(status="failure"),
            "invalid-registry": lambda report: report["actualLabelAudit"]["phases"][1].update(registryValid=False),
            "incomplete-measurements": lambda report: report["matrix"][0]["labelAudit"]["phases"][0].update(measuredCount=0),
            "source-rewritten": lambda report: report["matrix"][0]["labelAudit"]["phases"][1].update(sourcePreservedCount=0),
            "non-idempotent": lambda report: report["matrix"][0]["labelAudit"]["phases"][1].update(idempotentCount=0),
            "zero-bbox": lambda report: report["matrix"][0]["labelAudit"]["phases"][1].update(positiveBoundsCount=0),
            "hidden-source": lambda report: report["matrix"][0]["labelAudit"]["phases"][1].update(appearancePreservedCount=0),
            "parent-drift": lambda report: report["matrix"][0]["labelAudit"]["phases"][1].update(parentPreservedCount=0),
            "lost-long-source": lambda report: report["matrix"][0]["labelAudit"]["phases"][3].update(referenceMatchedCount=0),
            "no-base-eligible": lambda report: report["matrix"][0]["labelAudit"]["phases"][2].update(baseEligibleCount=0, baseRecoveredCount=0),
            "stuck-small-font": lambda report: report["matrix"][0]["labelAudit"]["phases"][2].update(baseRecoveredCount=0),
            "rebuild-drift": lambda report: report["matrix"][0]["labelAudit"]["phases"][5].update(referenceMatchedCount=0),
            "actual-restore-drift": lambda report: report["actualLabelAudit"]["phases"][1].update(referenceMatchedCount=0),
            "actual-nonfinite-geometry": lambda report: report["actualLabelAudit"]["phases"][0].update(finiteGeometryCount=0),
            "actual-zero-bbox": lambda report: report["actualLabelAudit"]["phases"][0].update(positiveBoundsCount=0),
            "actual-bounds-failure": lambda report: report["actualLabelAudit"]["phases"][0].update(containedCount=0),
            "actual-font-range-failure": lambda report: report["actualLabelAudit"]["phases"][0].update(fontRangeCount=0),
        }
        for name, mutate in mutations.items():
            with self.subTest(mutation=name):
                self.assert_hud_audit_rejected(mutate)


class InstallRunner(Runner):
    """Fake clock/commands exercise only the production install policy, never a device."""
    def __init__(self, directory, clock, outcomes, budget=1080):
        super().__init__(directory, budget)
        self.clock, self.outcomes, self.calls = clock, list(outcomes), []
        self.device, self.bundle = {"udid": "install-unit-device-only"}, "unit.fixture.only"
        self.summary.update(selectedDevice=self.device, appProduct={"bundleId": self.bundle, "path": "unit.app"})

    def simctl(self, name, *args, cap=60, receipt=None, log=None):
        self.calls.append((args, cap))
        outcome = self.outcomes.pop(0)
        code = outcome.get("code", 0)
        duration = outcome.get("duration", 0.6 if code >= 128 else 0.1)
        self.clock[0] += duration
        receipt.update(unit_cli_receipt(code, cap, timeout=outcome.get("timeout", False)))
        receipt["elapsedSeconds"] = duration
        receipt.update(outcome.get("receipt", {}))
        text = outcome.get("diagnostic", "")
        (self.directory / log).write_text(text)
        if code:
            raise ProbeFailure("injected install/readiness outcome", code, diagnostic=text)
        return text


class InstallationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory, self.clock = Path(self.temp.name), [0]
        self.timer = patch("simulator_probe.time.monotonic", side_effect=lambda: self.clock[0])
        self.timer.start()
        self.addCleanup(self.timer.stop)

    def runner(self, outcomes, budget=1080):
        return InstallRunner(self.directory, self.clock, outcomes, budget)

    def timeout(self, **extra):
        return dict(code=124, timeout=True, duration=180.6, **extra)

    def assert_failed(self, runner):
        with self.assertRaises(ProbeFailure):
            runner.install_app(Path("unit.app"))
        saved = json.loads((self.directory / "simulator-probe-summary.json").read_text())
        self.assertNotEqual(saved["installation"]["status"], "success")
        with self.assertRaises(ProbeFailure):
            validate_installation(saved, runner.probes, self.directory)
        return saved["installation"]

    def test_slow_first_install_success(self):
        runner = self.runner([{"duration": 120}])
        runner.install_app(Path("unit.app"))
        validate_installation(runner.summary, runner.probes, self.directory)
        self.assertEqual(len(runner.calls), 1)
        self.assertEqual(runner.calls[0][1], 180)

    def test_timeout_then_one_same_device_retry(self):
        runner = self.runner([self.timeout(), {}, {}])
        runner.install_app(Path("unit.app"))
        validate_installation(runner.summary, runner.probes, self.directory)
        self.assertEqual([call[0][0] for call in runner.calls], ["install", "bootstatus", "install"])
        self.assertTrue(all(call[0][1] == runner.device["udid"] for call in runner.calls))
        self.assertEqual([call[1] for call in runner.calls], [180, 60, 180])

    def test_explicit_transient_retry(self):
        runner = self.runner([{"code": 7, "diagnostic": "Device is busy"}, {}, {}])
        runner.install_app(Path("unit.app"))
        validate_installation(runner.summary, runner.probes, self.directory)
        self.assertEqual(runner.summary["installation"]["attempts"][0]["retryReason"], "transient_busy")

    def test_permanent_and_unknown_do_not_retry(self):
        for diagnostic in ("Invalid bundle; device is busy", "Failed to install"):
            with self.subTest(diagnostic=diagnostic):
                runner = self.runner([{"code": 7, "diagnostic": diagnostic}])
                self.assert_failed(runner)
                self.assertEqual(len(runner.calls), 1)

    def test_second_failure_ends(self):
        runner = self.runner([self.timeout(), {}, self.timeout()])
        evidence = self.assert_failed(runner)
        self.assertEqual(len(runner.calls), 3)
        self.assertEqual(len(evidence["attempts"]), 2)
        self.assertEqual(evidence["attempts"][-1]["retryDecision"], "attempt_limit")

    def test_initial_budget_insufficient_no_command(self):
        runner = self.runner([], budget=556)
        evidence = self.assert_failed(runner)
        self.assertEqual(runner.calls, [])
        self.assertEqual(evidence["attempts"], [])
        self.assertEqual(evidence["admissions"][0]["requiredSeconds"], 557)

    def test_retry_budget_insufficient_no_recovery(self):
        for budget, outcomes, commands, required in ((700, [self.timeout()], 1, 617),
                (798, [self.timeout(), {"duration": 60.5}], 2, 557)):
            with self.subTest(budget=budget):
                runner = self.runner(outcomes, budget=budget)
                evidence = self.assert_failed(runner)
                self.assertEqual(len(runner.calls), commands)
                self.assertEqual(len(evidence["attempts"]), 1)
                self.assertEqual(evidence["attempts"][0]["retryDecision"], "budget_insufficient")
                self.assertEqual(evidence["admissions"][-1]["requiredSeconds"], required)

    def test_readiness_failure_stops_retry(self):
        runner = self.runner([self.timeout(), {"code": 7}])
        evidence = self.assert_failed(runner)
        self.assertEqual(len(runner.calls), 2)
        self.assertEqual(evidence["attempts"][0]["retryDecision"], "recovery_failed")

    def test_cancelled_does_not_retry_and_saves_receipt(self):
        runner = self.runner([{"code": 143}])
        evidence = self.assert_failed(runner)
        self.assertEqual(len(runner.calls), 1)
        self.assertEqual(evidence["status"], "cancelled")
        self.assertEqual(evidence["attempts"][0]["process"]["trigger"], "cancelled")

    def test_cleanup_error_or_unreaped_does_not_retry(self):
        for receipt in ({"reaped": False}, {"term": {"status": "error", "error": "permission denied"}},
                        {"kill": {"status": "error", "error": "permission denied"}}):
            with self.subTest(receipt=receipt):
                runner = self.runner([self.timeout(receipt=receipt)])
                evidence = self.assert_failed(runner)
                self.assertEqual(len(runner.calls), 1)
                self.assertEqual(evidence["attempts"][0]["retryReason"], "cli_cleanup_unconfirmed")

    def test_command_cap_uses_shared_deadline(self):
        runner = self.runner([], budget=100)
        receipt = {}
        def bounded(command, seconds, **kwargs):
            kwargs["receipt"].update(unit_cli_receipt(cap=seconds))
            return 0
        with patch("simulator_probe.run_bounded", side_effect=bounded) as command:
            runner.command("cap-fixture", ["fake"], cap=180, receipt=receipt)
        self.assertEqual(command.call_args.args[1], 98)
        self.assertEqual(receipt["limitSeconds"], 98)

    def test_install_gate_cannot_be_overridden_by_hud_or_pngs(self):
        for mutation in ("missing", "failed", "cross-device", "unreaped", "output-tampered", "bad-elapsed",
                         "wrong-limit", "missing-normal-exit", "bad-admission-phase"):
            with self.subTest(mutation=mutation):
                runner = FakeRunner(self.directory)
                runner.work()
                installation = runner.summary["installation"]
                if mutation == "missing": del runner.summary["installation"]
                elif mutation == "failed": installation["status"] = "failure"
                elif mutation == "cross-device": installation["attempts"][0]["udid"] = "another-device"
                elif mutation == "unreaped": installation["attempts"][0]["process"]["reaped"] = False
                elif mutation == "bad-elapsed": installation["attempts"][0]["process"]["elapsedSeconds"] = -1
                elif mutation == "wrong-limit": installation["attempts"][0]["process"]["limitSeconds"] = 181
                elif mutation == "missing-normal-exit": del installation["attempts"][0]["process"]["returnCode"]
                elif mutation == "bad-admission-phase": installation["attempts"][0]["admission"]["phase"] = "stale"
                else: (self.directory / "install-attempt-1.log").write_text("tampered")
                with self.assertRaises(ProbeFailure):
                    validate_results(runner.probes, runner.summary, self.directory)
                runner.summary.update(status="success", integrityOutcome="success")
                runner.save()
                environment = {key: runner.summary[field] for key, field in (
                    ("CI_VERSION", "version"), ("GITHUB_REF_NAME", "branch"), ("GITHUB_SHA", "commitSha"),
                    ("GITHUB_RUN_ID", "runId"), ("GITHUB_RUN_ATTEMPT", "runAttempt"))}
                environment.update(WORKFLOW_NAME="synthetic unit fixture", GITHUB_OUTPUT=str(self.directory / "outputs"),
                                   STATIC_OUTCOME="success", PROJECT_LINT_OUTCOME="success", BUILD_OUTCOME="success",
                                   SIMULATOR_LAUNCH_OUTCOME="success")
                with patch.dict(os.environ, environment), patch("package_results.Path", side_effect=lambda path:
                        self.directory if path == "ci-results" else Path(path)):
                    package_results()
                manifest = json.loads((self.directory / "ci-artifact-manifest.json").read_text())
                self.assertEqual(manifest["simulatorInstallOutcome"], "failure")
                self.assertEqual(manifest["probeIntegrityOutcome"], "failure")


class BootRunner(Runner):
    """Production boot/command code with a fake monotonic clock and owned-CLI receipts."""
    def __init__(self, directory, clock, outcomes, budget=1080):
        super().__init__(directory, budget)
        self.clock, self.outcomes, self.calls = clock, list(outcomes), []
        self.device = {"udid": "boot-unit-device-only", "runtime": {"identifier": "synthetic.runtime.only"},
                       "dataPath": "/synthetic/boot-device/data"}
        self.summary["selectedDevice"] = self.device
        for key in ("branch", "commitSha", "runId", "runAttempt", "version"):
            self.summary[key] = f"unit-fixture-{key}"

    def bounded(self, command, seconds, *, stdout, receipt, **kwargs):
        self.calls.append((command, seconds))
        outcome = self.outcomes.pop(0)
        code, timeout = outcome.get("code", 0), outcome.get("timeout", False)
        duration = outcome.get("duration", seconds + 0.5 if timeout else 0.6 if outcome.get("cancelled") else 0.1)
        self.clock[0] += duration
        process = unit_cli_receipt(code if timeout or outcome.get("cancelled") else 0, seconds, timeout)
        process.update(exitCode=code, returnCode=process["returnCode"] if timeout or outcome.get("cancelled") else code,
                       elapsedSeconds=duration)
        receipt.update(process)
        receipt.update(outcome.get("receipt", {}))
        stdout.write(outcome.get("text", "").encode())
        if outcome.get("exception"):
            raise outcome["exception"]
        return code


class BootTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory, self.clock = Path(self.temp.name), [0]
        self.timer = patch("simulator_probe.time.monotonic", side_effect=lambda: self.clock[0])
        self.timer.start()
        self.addCleanup(self.timer.stop)

    def runner(self, outcomes=None, budget=1080):
        return BootRunner(self.directory, self.clock, outcomes if outcomes is not None else [{"text": BOOT_HELP}, {}, {}], budget)

    def boot(self, runner):
        with patch("simulator_probe.run_bounded", side_effect=runner.bounded):
            runner.boot_device()

    def continued(self, status=2, budget=1080, second=None):
        runner = self.runner([], budget)
        runner.outcomes = [{"text": BOOT_HELP}, {},
                           {"code": 124, "timeout": True, "text": boot_wait_text(runner.device["udid"], status)},
                           second if second is not None else {}]
        return runner

    def assert_failed(self, runner):
        with self.assertRaises(ProbeFailure):
            self.boot(runner)
        saved = json.loads((self.directory / "simulator-probe-summary.json").read_text())
        self.assertNotEqual(saved["boot"]["status"], "success")
        with self.assertRaises(ProbeFailure):
            validate_boot(saved, runner.probes, self.directory)
        return saved["boot"]

    def package(self, runner):
        runner.save()
        environment = {key: runner.summary[field] for key, field in (
            ("CI_VERSION", "version"), ("GITHUB_REF_NAME", "branch"), ("GITHUB_SHA", "commitSha"),
            ("GITHUB_RUN_ID", "runId"), ("GITHUB_RUN_ATTEMPT", "runAttempt"))}
        environment.update(WORKFLOW_NAME="synthetic boot fixture", GITHUB_OUTPUT=str(self.directory / "outputs"),
                           STATIC_OUTCOME="success", PROJECT_LINT_OUTCOME="success", BUILD_OUTCOME="success",
                           SIMULATOR_LAUNCH_OUTCOME="success")
        with patch.dict(os.environ, environment), patch("package_results.Path", side_effect=lambda path:
                self.directory if path == "ci-results" else Path(path)):
            package_results()
        return json.loads((self.directory / "ci-artifact-manifest.json").read_text())

    def test_boot_help_supported_semantics_not_whole_string(self):
        for help_text in (BOOT_HELP, "Additional version banner\n" + BOOT_HELP + "Other documentation\n",
                          BOOT_HELP.replace("Boot the device if it isn't already booted.", "If the device is not booted, boot it.")):
            with self.subTest(help_text=help_text):
                runner = self.runner([{"text": help_text}, {}, {}])
                self.boot(runner)
                validate_boot(runner.summary, runner.probes, self.directory)
                self.assertTrue(runner.summary["boot"]["monitorSemantics"]["monitorOnlyWithoutOption"])

    def test_boot_help_unknown_or_failed_stops_before_initial_boot(self):
        for outcome in ({"text": "bootstatus [-b]"}, {"text": BOOT_HELP.replace("Boot the device", "Maybe boot the device")},
                        {"text": BOOT_HELP + "Without -b it still boots the device.\n"},
                        {"text": BOOT_HELP, "code": 7}, {"text": BOOT_HELP, "receipt": {"reaped": False}}):
            with self.subTest(outcome=outcome):
                runner = self.runner([outcome])
                self.assert_failed(runner)
                self.assertEqual(len(runner.calls), 1)

    def official_help(self):
        data = BOOT_HELP_FIXTURE.read_bytes()
        self.assertEqual(len(data), BOOT_HELP_SOURCE["bytes"])
        self.assertEqual(hashlib.sha256(data).hexdigest(), BOOT_HELP_SOURCE["sha256"])
        return data.decode("utf-8")

    def test_boot_help_official_raw_and_synthetic_whitespace_variants(self):
        official = self.official_help()
        # Only the first entry is unchanged official input; all variants are synthetic.
        variants = (official, official.replace("\n", "\r\n"),
                    official.replace("\t", "  ").replace("specified device and prints", "specified device\n    and\tprints"),
                    official.replace("Checks device boot status.\n", ""),
                    official.replace("Checks device boot status.", "A different title."),
                    official.replace("[-bcd]", "[-b] [-c] [-d]").replace("-b       Boot", "-b\n    Boot"))
        for text in variants:
            with self.subTest(text=text):
                runner = self.runner([{"text": text}, {}, {}])
                self.boot(runner)
                validate_boot(runner.summary, runner.probes, self.directory)
                semantics = runner.summary["boot"]["monitorSemantics"]
                self.assertEqual(semantics["monitorDescription"], BOOT_MONITOR_PARAGRAPH)
                self.assertEqual(semantics["autoBootOption"], "-b")
                self.assertEqual(runner.calls[-1][0][2:], ["bootstatus", runner.device["udid"]])

    def test_boot_help_missing_default_or_conditional_semantics_stops(self):
        official = self.official_help()
        option = "Boot the device if it isn't already booted."
        variants = (LEGACY_MINIMAL_BOOT_HELP, official.replace(BOOT_MONITOR_PARAGRAPH, ""),
                    official.replace("\t-b       " + option + "\n", ""),
                    official.replace(option, "Maybe boot the device if it isn't already booted."),
                    official.replace(option, "Boot the device when needed."),
                    official.replace(BOOT_MONITOR_PARAGRAPH, "Continuously monitor boot status through multiple cycles."),
                    official.replace(BOOT_MONITOR_PARAGRAPH, "Never " + BOOT_MONITOR_PARAGRAPH))
        for text in variants:
            with self.subTest(text=text):
                runner = self.runner([{"text": text}])
                self.assert_failed(runner)
                self.assertEqual(len(runner.calls), 1)
                manifest = self.package(runner)
                self.assertEqual(manifest["simulatorBootOutcome"], "failure")
                self.assertEqual(manifest["probeIntegrityOutcome"], "failure")

    def test_boot_help_contradictions_and_conflicting_option_definitions_stop(self):
        official = self.official_help()
        for extra in ("By default the device is automatically booted.", "The device boots automatically.",
                      "Without -b it still boots the device.", "Always boot the device before monitoring.",
                      "Boot the device unconditionally by default.", "The device auto-boots.",
                      "-b Never boot the device.", "-b Maybe boot the device.",
                      "-b Boot the device if it isn't already booted.", "Unsupported interface.", "Error: failed to query help."):
            with self.subTest(extra=extra):
                runner = self.runner([{"text": official + extra + "\n"}])
                self.assert_failed(runner)
                self.assertEqual(len(runner.calls), 1)

    def test_boot_help_metadata_rechecks_current_output_not_historical_fixture(self):
        # This entire HUD/24-PNG chain is synthetic schema evidence, never App output.
        runner = FakeRunner(self.directory)
        runner.work()
        command = runner.summary["boot"]["commands"][0]
        path = self.directory / command["output"]["path"]
        official = self.official_help()
        for text, expected in ((official, "success"), (official.replace(BOOT_MONITOR_PARAGRAPH, ""), "failure")):
            with self.subTest(expected=expected):
                data = text.encode()
                path.write_bytes(data)
                command["output"].update(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
                if expected == "success":
                    runner.summary["boot"]["monitorSemantics"] = boot_monitor_semantics(text)
                    validate_results(runner.probes, runner.summary, self.directory)
                else:
                    with self.assertRaises(ProbeFailure):
                        validate_results(runner.probes, runner.summary, self.directory)
                runner.summary.update(status="success", integrityOutcome="success")
                manifest = self.package(runner)
                self.assertEqual(manifest["simulatorBootOutcome"], expected)
                self.assertEqual(manifest["probeIntegrityOutcome"], expected)
                self.assertEqual(manifest["sceneReadinessOutcome"], "success")
                self.assertEqual(manifest["hudLayoutContractOutcome"], "success")

    def test_post_reap_absence_receipt_narrow_gate_and_metadata(self):
        # The entire boot/HUD/24-PNG chain here is synthetic schema evidence.
        runner = FakeRunner(self.directory)
        runner.work()
        boot_fixture(runner, continuation=True)
        command = runner.summary["boot"]["commands"][2]
        process = command["process"]
        process.update(cleanupOutcome="group_absent_after_reap",
                       kill=dict(status="error", errno=errno.EPERM, error="synthetic KILL EPERM"),
                       postReapGroupCheck=dict(pgid=process["pgid"], signal=0, phase="after-leader-reap",
                           status="absent", errno=errno.ESRCH, diagnostic="synthetic ESRCH, not OS output"))
        validate_results(runner.probes, runner.summary, self.directory)
        self.assertEqual(self.package(runner)["simulatorBootOutcome"], "success")
        valid = json.dumps(process)
        for mutation in ("missing", "query-none", "query-present", "query-eperm", "query-unknown", "wrong-pgid",
                         "wrong-phase", "nonzero-query", "boolean-signal", "boolean-errno", "query-error",
                         "wrong-return", "unreaped", "term-not-sent", "kill-not-eperm", "kill-no-diagnostic",
                         "claimed-legacy-success", "cleanup-error", "reap-error"):
            with self.subTest(mutation=mutation):
                record = json.loads(valid)
                query = record["postReapGroupCheck"]
                if mutation == "missing": del record["postReapGroupCheck"]
                elif mutation == "query-none": record["postReapGroupCheck"] = None
                elif mutation == "query-present": query["status"] = "exists"
                elif mutation == "query-eperm": query["errno"] = errno.EPERM
                elif mutation == "query-unknown": del query["errno"]
                elif mutation == "wrong-pgid": query["pgid"] += 1
                elif mutation == "wrong-phase": query["phase"] = "before-reap"
                elif mutation == "nonzero-query": query["signal"] = signal.SIGKILL
                elif mutation == "boolean-signal": query["signal"] = False
                elif mutation == "boolean-errno": record["kill"]["errno"] = True
                elif mutation == "query-error": query["error"] = "additional failure"
                elif mutation == "wrong-return": record["returnCode"] = -signal.SIGKILL
                elif mutation == "unreaped": record["reaped"] = False
                elif mutation == "term-not-sent": record["term"]["status"] = "already_gone"
                elif mutation == "kill-not-eperm": record["kill"]["errno"] = errno.EACCES
                elif mutation == "kill-no-diagnostic": del record["kill"]["error"]
                elif mutation == "claimed-legacy-success": record["cleanupOutcome"] = "success"
                elif mutation == "cleanup-error": record["cleanupError"] = "identity unanchored"
                elif mutation == "reap-error": record["reapError"] = "ECHILD"
                command["process"] = record
                self.assertFalse(cli_receipt_complete(record))
                with self.assertRaises(ProbeFailure):
                    validate_results(runner.probes, runner.summary, self.directory)
                runner.summary.update(status="success", integrityOutcome="success")
                manifest = self.package(runner)
                self.assertEqual(manifest["simulatorBootOutcome"], "failure")
                self.assertEqual(manifest["probeIntegrityOutcome"], "failure")
                self.assertEqual(manifest["hudLayoutContractOutcome"], "success")
                self.assertEqual(manifest["sceneReadinessOutcome"], "success")

    def test_boot_first_success_has_one_boot_and_monitor_without_auto_boot(self):
        runner = self.runner()
        deadline = runner.deadline
        self.boot(runner)
        validate_boot(runner.summary, runner.probes, self.directory)
        self.assertEqual([call[0][2:] for call in runner.calls], [["help", "bootstatus"], ["boot", runner.device["udid"]],
                                                               ["bootstatus", runner.device["udid"]]])
        self.assertEqual([call[1] for call in runner.calls], [10, 60, 240])
        self.assertEqual(runner.deadline, deadline)

    def test_boot_exact_already_booted_normal_high_exit_is_not_signal(self):
        diagnostic = ("An error was encountered processing the command (domain=com.apple.CoreSimulator.SimError, code=405):\n"
                      "Unable to boot device in current state: Booted\n")
        runner = self.runner([{"text": BOOT_HELP}, {"code": 405, "text": diagnostic}, {}])
        self.boot(runner)
        validate_boot(runner.summary, runner.probes, self.directory)
        self.assertEqual(runner.summary["boot"]["commands"][1]["classification"], "already_booted")

    def test_boot_unknown_permanent_or_timeout_initial_failure_does_not_monitor(self):
        for outcome in ({"code": 7, "text": "booted? maybe"}, {"code": 7, "text": "No such device"},
                        {"code": 7, "text": "Unable to boot device in current state: Shutdown"},
                        {"code": 7, "text": "Permission denied\nUnable to boot device in current state: Booted"},
                        {"code": 124, "timeout": True}, {"code": 0, "receipt": {"reaped": False}}):
            with self.subTest(outcome=outcome):
                runner = self.runner([{"text": BOOT_HELP}, outcome])
                self.assert_failed(runner)
                self.assertEqual(len(runner.calls), 2)

    def test_boot_migration_or_system_app_timeout_continues_same_device_once(self):
        for status in (2, 4):
            with self.subTest(status=status):
                runner = self.continued(status)
                self.boot(runner)
                validate_boot(runner.summary, runner.probes, self.directory)
                self.assertEqual([call[0][2] for call in runner.calls], ["help", "boot", "bootstatus", "bootstatus"])
                waits = [call[0] for call in runner.calls if call[0][2] == "bootstatus"]
                self.assertEqual(waits, [["/usr/bin/xcrun", "simctl", "bootstatus", runner.device["udid"]]] * 2)
                self.assertEqual(runner.summary["boot"]["commands"][2]["continuationDecision"], "continue")

    def test_boot_exit124_or_incomplete_cleanup_never_continues(self):
        outcomes = [{"code": 124}, {"code": 124, "timeout": True, "receipt": {"reaped": False}},
                    {"code": 124, "timeout": True, "receipt": {"term": {"status": "error", "error": "EPERM"}}},
                    {"code": 124, "timeout": True, "receipt": {"kill": {"status": "error", "error": "EPERM"}}},
                    {"code": 124, "timeout": True, "receipt": {"cleanupOutcome": "failure"}},
                    {"code": 0, "receipt": {"returnCode": -9}}]
        for outcome in outcomes:
            with self.subTest(outcome=outcome):
                runner = self.continued()
                runner.outcomes[2] = dict(outcome, text=boot_wait_text(runner.device["udid"]))
                self.assert_failed(runner)
                self.assertEqual(len(runner.calls), 3)

    def test_boot_cancel_or_exception_saves_receipt_and_stops_immediately(self):
        for position in range(4):
            with self.subTest(position=position):
                runner = self.continued()
                runner.outcomes[position] = {"code": 143, "cancelled": True}
                evidence = self.assert_failed(runner)
                self.assertEqual(len(runner.calls), position + 1)
                self.assertEqual(evidence["status"], "cancelled")
                self.assertEqual(evidence["commands"][-1]["process"]["trigger"], "cancelled")
        runner = self.runner([{"code": 130, "cancelled": True, "exception": KeyboardInterrupt()}])
        with patch("simulator_probe.run_bounded", side_effect=runner.bounded), self.assertRaises(KeyboardInterrupt):
            runner.boot_device()
        self.assertEqual(json.loads((self.directory / "simulator-probe-summary.json").read_text())["boot"]["status"], "cancelled")

    def test_boot_unknown_partial_terminal_or_error_last_status_stops(self):
        runner = self.continued()
        known = boot_wait_text(runner.device["udid"])
        for text in ("", known.rstrip(), known + "Unknown trailing output\n", known + "[partial] Status=4, isTerminal=\n",
                     known.replace("Status=2", "Status=3"), known.replace("isTerminal=NO", "isTerminal=YES"),
                     known + "Fatal error: invalid runtime\n", known.replace("Waiting on Data Migration", "Waiting on System App"),
                     known.replace(runner.device["udid"], "another-device"),
                     known + "[2026-10-22 19:03:00 +0000] Status=3, isTerminal=NO, Elapsed=04:10.\nUnknown wait\n"):
            with self.subTest(text=text):
                runner = self.continued()
                runner.outcomes[2]["text"] = text
                self.assert_failed(runner)
                self.assertEqual(len(runner.calls), 3)

    def test_boot_continuation_rejects_legacy_state_policy_and_forged_observations(self):
        # No fresh-state observation exists in this synthetic current-policy chain.
        for mutation in ("old-policy", "legacy-five-role", "new-policy-state-role", "state-list-argv",
                         "root-state", "command-state", "udid", "runtimeIdentifier", "dataPath"):
            with self.subTest(mutation=mutation):
                runner = FakeRunner(self.directory)
                runner.work()
                boot_fixture(runner, continuation=True)
                evidence = runner.summary["boot"]
                validate_boot(runner.summary, runner.probes, self.directory)
                self.assertEqual(evidence["policy"], "same-device-monitor-continuation-v2")
                self.assertEqual([record["role"] for record in evidence["commands"]], ["help", "initial", "wait:1", "wait:2"])
                self.assertNotIn("selectedState", evidence)
                self.assertFalse(any("selectedState" in record for record in evidence["commands"]))
                self.assertFalse((self.directory / "boot-state.log").exists())
                if mutation in ("old-policy", "legacy-five-role"):
                    evidence["policy"] = "same-device-boot-continuation-v1"
                if mutation in ("legacy-five-role", "new-policy-state-role"):
                    state = dict(evidence["commands"][-1], role="state", argv=["/usr/bin/xcrun", "simctl", "list", "devices", "--json"])
                    evidence["commands"].insert(3, state)
                elif mutation == "state-list-argv":
                    evidence["commands"][-1]["argv"] = ["/usr/bin/xcrun", "simctl", "list", "devices", "--json"]
                elif mutation == "root-state": evidence["selectedState"] = {"syntheticForbiddenObservation": True}
                elif mutation == "command-state": evidence["commands"][-1]["selectedState"] = {"syntheticForbiddenObservation": True}
                elif mutation in ("udid", "runtimeIdentifier", "dataPath"): evidence["selectedDevice"][mutation] = "changed"
                with self.assertRaises(ProbeFailure):
                    validate_boot(runner.summary, runner.probes, self.directory)
                with self.assertRaises(ProbeFailure):
                    validate_results(runner.probes, runner.summary, self.directory)
                runner.summary.update(status="success", integrityOutcome="success")
                manifest = self.package(runner)
                self.assertEqual(manifest["simulatorBootOutcome"], "failure")
                self.assertEqual(manifest["probeIntegrityOutcome"], "failure")
                self.assertEqual(manifest["sceneReadinessOutcome"], "success")
                self.assertEqual(manifest["hudLayoutContractOutcome"], "success")

    def test_boot_second_monitor_requires_real_normal_exit0_not_state_or_text(self):
        runner = self.continued()
        self.boot(runner)
        validate_boot(runner.summary, runner.probes, self.directory)
        self.assertEqual([record["role"] for record in runner.summary["boot"]["commands"]], ["help", "initial", "wait:1", "wait:2"])
        self.assertFalse(any("selectedState" in record for record in runner.summary["boot"]["commands"]))
        self.assertFalse((self.directory / "boot-state.log").exists())
        for outcome in ({"code": 124}, {"code": 143, "cancelled": True},
                        {"code": 143, "cancelled": True, "receipt": {"trigger": "exception"}},
                        {"code": 137, "receipt": {"returnCode": -9}}, {"receipt": {"reaped": False}}):
            with self.subTest(outcome=outcome):
                # Completion text cannot substitute for a normal exit0 receipt.
                runner = self.continued(second=dict(outcome, text="Synthetic completion text; not an exit receipt.\n"))
                self.assert_failed(runner)
                self.assertEqual(len(runner.calls), 4)
                self.assertEqual(self.package(runner)["simulatorBootOutcome"], "failure")

    def test_boot_second_failure_has_no_third_wait_or_restart(self):
        for second in ({"code": 124, "timeout": True}, {"code": 7}, {"receipt": {"reaped": False}}):
            with self.subTest(second=second):
                runner = self.continued(second=second)
                second["text"] = boot_wait_text(runner.device["udid"])
                evidence = self.assert_failed(runner)
                self.assertEqual(len(runner.calls), 4)
                self.assertEqual(evidence["commands"][-1]["continuationDecision"], "attempt_limit")
                self.assertEqual([call[0][2] for call in runner.calls].count("boot"), 1)
                self.assertFalse(any(call[0][2] in ("shutdown", "reboot") for call in runner.calls))

    def test_boot_post_wait_elapsed_recomputes_dynamic_cap_without_reset(self):
        runner = self.continued(budget=900)
        deadline = runner.deadline
        command = runner._boot_command

        def elapsed_after_wait(role, *arguments):
            record = command(role, *arguments)
            if role == "wait:1":
                self.clock[0] += 8  # Synthetic dispatch/save overhead, not another RPC.
            return record

        with patch.object(runner, "_boot_command", side_effect=elapsed_after_wait):
            self.boot(runner)
        validate_boot(runner.summary, runner.probes, self.directory)
        first, final = runner.summary["boot"]["commands"][2:]
        self.assertEqual(len(runner.calls), 4)
        self.assertEqual(final["requestedCapSeconds"], 240)
        self.assertLess(final["effectiveCapSeconds"], 240)
        self.assertAlmostEqual(final["effectiveCapSeconds"], min(240, final["remainingStartSeconds"] - 557 - 2))
        self.assertAlmostEqual(final["startedAfterSeconds"] - first["endedAfterSeconds"], 8)
        self.assertAlmostEqual(final["remainingStartSeconds"], first["remainingEndSeconds"] - 8)
        self.assertEqual(runner.deadline, deadline)

    def test_boot_initial_or_later_budget_insufficient_does_not_dispatch(self):
        for budget, duration, calls in ((558, None, 0), (559.05, 0.1, 1)):
            with self.subTest(budget=budget):
                runner = self.runner(budget=budget)
                if duration is not None: runner.outcomes[0]["duration"] = duration
                evidence = self.assert_failed(runner)
                self.assertEqual(len(runner.calls), calls)
                self.assertFalse(evidence["admissions"][-1]["allowed"])
                self.assertIn("budget_insufficient", evidence["stopReason"])

    def test_boot_post_wait_overhead_exhausts_reserve_before_second_dispatch(self):
        runner = self.continued(budget=800)
        deadline = runner.deadline
        command = runner._boot_command

        def elapsed_after_wait(role, *arguments):
            record = command(role, *arguments)
            if role == "wait:1":
                self.clock[0] += 1  # Exhaust the remaining reserve before the next admission.
            return record

        with patch.object(runner, "_boot_command", side_effect=elapsed_after_wait):
            evidence = self.assert_failed(runner)
        self.assertEqual(len(runner.calls), 3)
        self.assertEqual(len(evidence["commands"]), 3)
        self.assertTrue(evidence["commands"][-1]["classification"]["eligible"])
        self.assertEqual(evidence["commands"][-1]["continuationDecision"], "continue")
        self.assertEqual(evidence["admissions"][-1]["phase"], "boot-admission:wait:2")
        self.assertFalse(evidence["admissions"][-1]["allowed"])
        self.assertIn("budget_insufficient", evidence["stopReason"])
        self.assertEqual(runner.deadline, deadline)

    def test_boot_command_reserves_install_and_cleanup_exactly_once(self):
        runner = self.runner([{}], budget=600)
        receipt = {}
        with patch("simulator_probe.run_bounded", side_effect=runner.bounded):
            runner.command("reserved-command-fixture", ["fake"], cap=240, reserve=boot_reserve(runner.probes), receipt=receipt)
        self.assertEqual(runner.calls[0][1], 41)
        self.assertEqual(receipt["limitSeconds"], 41)

    def test_boot_success_still_requires_original_install_admission(self):
        runner = self.runner()
        self.boot(runner)
        self.clock[0] = runner.deadline - 556.9
        runner.summary["installation"] = {"admissions": []}
        with self.assertRaises(ProbeFailure):
            runner._install_admission("install-admission:1")
        self.assertEqual(runner.summary["installation"]["admissions"][0]["requiredSeconds"], 557)
        self.assertEqual(len(runner.calls), 3)

    def test_boot_metadata_independent_of_missing_install_scene_and_hud(self):
        runner = self.runner()
        self.boot(runner)
        manifest = self.package(runner)
        self.assertEqual(manifest["simulatorBootOutcome"], "success")
        self.assertEqual(manifest["simulatorInstallOutcome"], "failure")
        self.assertEqual(manifest["sceneReadinessOutcome"], "failure")
        self.assertEqual(manifest["hudLayoutContractOutcome"], "failure")
        self.assertEqual(manifest["probeIntegrityOutcome"], "failure")

    def test_boot_gate_rejects_invalid_chain_even_with_complete_hud_and_24_pngs(self):
        for mutation in ("missing", "failed", "identity", "device", "auto-boot", "auto-cycle", "auto-detail", "order", "extra", "help", "receipt",
                         "output", "limit", "reserve", "clock", "signal", "old-policy", "state-rpc", "forged-state", "wait2-device", "decision"):
            with self.subTest(mutation=mutation):
                runner = FakeRunner(self.directory)
                runner.work()
                boot_fixture(runner, continuation=True)
                validate_results(runner.probes, runner.summary, self.directory)
                evidence = runner.summary["boot"]
                first, final = evidence["commands"][2:4]
                if mutation == "missing": del runner.summary["boot"]
                elif mutation == "failed": evidence["status"] = "failure"
                elif mutation == "identity": evidence["identity"]["commitSha"] = "stale"
                elif mutation == "device": evidence["selectedDevice"]["udid"] = "another-device"
                elif mutation == "auto-boot": evidence["commands"][-1]["argv"].append("-b")
                elif mutation == "auto-cycle": evidence["commands"][-1]["argv"].append("-c")
                elif mutation == "auto-detail": evidence["commands"][-1]["argv"].append("-d")
                elif mutation == "order": evidence["commands"][2:4] = [final, first]
                elif mutation == "extra": evidence["commands"].append(dict(first))
                elif mutation == "help": evidence["monitorSemantics"]["monitorOnlyWithoutOption"] = False
                elif mutation == "receipt": first["process"]["reaped"] = False
                elif mutation == "output": (self.directory / first["output"]["path"]).write_text("tampered")
                elif mutation == "limit": first["effectiveCapSeconds"] = 241
                elif mutation == "reserve": first["admission"]["installReserveSeconds"] = 556
                elif mutation == "clock": first["remainingStartSeconds"] += 10
                elif mutation == "signal": evidence["commands"][-1]["process"]["returnCode"] = -9
                elif mutation == "old-policy": evidence["policy"] = "same-device-boot-continuation-v1"
                elif mutation == "state-rpc": evidence["commands"].insert(3, dict(final, role="state", argv=["/usr/bin/xcrun", "simctl", "list", "devices", "--json"]))
                elif mutation == "forged-state": final["selectedState"] = {"syntheticForbiddenObservation": True}
                elif mutation == "wait2-device": final["argv"][-1] = "another-device"
                elif mutation == "decision": first["continuationDecision"] = "restart"
                with self.assertRaises(ProbeFailure):
                    validate_results(runner.probes, runner.summary, self.directory)
                runner.summary.update(status="success", integrityOutcome="success")
                manifest = self.package(runner)
                self.assertEqual(manifest["simulatorBootOutcome"], "failure")
                self.assertEqual(manifest["probeIntegrityOutcome"], "failure")
                self.assertEqual(manifest["hudLayoutContractOutcome"], "success")
                self.assertEqual(manifest["sceneReadinessOutcome"], "success")


class WatchdogReceiptTests(unittest.TestCase):
    def term_case(self, child=False, injected_eperm=False, cancel_query=False):
        """Real ready-bound processes/syscalls; optional KILL fault is explicitly injected."""
        native_killpg = os.killpg
        with tempfile.TemporaryDirectory() as directory:
            ready, sentinel = Path(directory) / "ready.json", Path(directory) / "survived"
            ready_tmp = str(ready) + ".tmp"
            program = ("import json,os,signal,time; from pathlib import Path\nsignal.signal(signal.SIGTERM, signal.SIG_DFL)\n"
                       + ("child=os.fork()\nif child == 0:\n"
                          " signal.signal(signal.SIGTERM, signal.SIG_IGN)\n"
                          f" Path({ready_tmp!r}).write_text(json.dumps(dict(pid=os.getpid(),pgid=os.getpgrp(),leader=os.getppid())))\n"
                          f" os.replace({ready_tmp!r}, {str(ready)!r})\n"
                          f" time.sleep(5); Path({str(sentinel)!r}).touch(); os._exit(42)\n"
                          "time.sleep(30)\n" if child else
                          f"Path({ready_tmp!r}).write_text(json.dumps(dict(pid=os.getpid(),pgid=os.getpgrp(),leader=os.getpid())))\n"
                          f"os.replace({ready_tmp!r}, {str(ready)!r})\n"
                          "time.sleep(30)\n"))
            process = subprocess.Popen([sys.executable, "-c", program], start_new_session=True, stdout=subprocess.PIPE)
            receipt, calls = {}, []

            def signal_group(pgid, sig):
                calls.append(dict(pgid=pgid, signal=int(sig), leaderReturnCodeBefore=process.returncode))
                if sig == signal.SIGKILL and injected_eperm:
                    raise PermissionError(errno.EPERM, "Explicit injected KILL failure, not native EPERM")
                if sig == 0 and cancel_query:
                    raise SystemExit(143)
                return native_killpg(pgid, sig)

            try:
                deadline = time.monotonic() + 3
                while not ready.exists() and time.monotonic() < deadline:
                    time.sleep(0.01)
                self.assertTrue(ready.exists(), "Real fixture did not become ready")
                observed = json.loads(ready.read_text())
                self.assertEqual(observed["pgid"], process.pid)
                self.assertEqual(observed["leader"], process.pid)
                if child:
                    self.assertNotEqual(observed["pid"], process.pid)
                # Bind the already-owned real Popen after readiness so the short timeout starts here.
                with patch("run_bounded.subprocess.Popen", return_value=process), patch("run_bounded.os.killpg", side_effect=signal_group):
                    if cancel_query:
                        with self.assertRaises(SystemExit) as raised:
                            run_bounded(["ready-bound-real-fixture"], 0.2, receipt=receipt)
                        result = raised.exception.code
                    else:
                        result = run_bounded(["ready-bound-real-fixture"], 0.2, receipt=receipt)
                self.assertTrue(select.select([process.stdout], [], [], 1)[0], "A fixture writer survived group cleanup")
                self.assertEqual(os.read(process.stdout.fileno(), 1), b"", "Fixture stdout did not reach EOF")
                self.assertFalse(sentinel.exists())
                self.assertTrue(all(call["leaderReturnCodeBefore"] is None for call in calls if call["signal"] != 0))
                execution = "real ready-bound Popen, signals, wait and any signal0; no injection"
                if injected_eperm:
                    execution = ("real ready-bound Popen/TERM/wait; injected KILL error and query cancellation" if cancel_query else
                                 "real ready-bound Popen/TERM/wait/signal0; injected KILL error, not native EPERM")
                WATCHDOG_RECEIPT_EVIDENCE.append(dict(case="real-term-child" if child else "real-term-leader",
                    execution=execution,
                    cancelledQuery=cancel_query, ready=observed, groupSignals=calls, stdoutEOF=True, **receipt))
                return receipt, calls, result
            finally:
                # Never signal a numeric group after this fixture has reaped its leader.
                if process.returncode is None:
                    try:
                        native_killpg(process.pid, signal.SIGKILL)
                    except OSError:
                        pass
                    process.wait(timeout=1)
                process.stdout.close()

    def test_real_term_normal_leader_receipt(self):
        receipt, calls, result = self.term_case()
        self.assertEqual(result, 124)
        self.assertTrue(cli_receipt_complete(receipt))
        self.assertEqual(receipt["returnCode"], -signal.SIGTERM)
        self.assertEqual([call["signal"] for call in calls[:2]], [signal.SIGTERM, signal.SIGKILL])

    def test_real_term_leader_exit_still_kills_same_group_ignored_child(self):
        receipt, calls, result = self.term_case(child=True)
        self.assertEqual(result, 124)
        self.assertTrue(cli_receipt_complete(receipt))
        self.assertEqual(receipt["returnCode"], -signal.SIGTERM)
        self.assertEqual(receipt["kill"]["status"], "sent")
        self.assertEqual([call["signal"] for call in calls], [signal.SIGTERM, signal.SIGKILL])

    def test_real_group_query_with_explicitly_injected_kill_eperm(self):
        receipt, calls, result = self.term_case(injected_eperm=True)
        self.assertEqual(result, 124)
        self.assertTrue(cli_receipt_complete(receipt))
        self.assertEqual(receipt["cleanupOutcome"], "group_absent_after_reap")
        self.assertEqual(receipt["kill"]["status"], "error")
        self.assertEqual(receipt["kill"]["errno"], errno.EPERM)
        self.assertEqual(receipt["postReapGroupCheck"]["errno"], errno.ESRCH)
        self.assertEqual([call["signal"] for call in calls], [signal.SIGTERM, signal.SIGKILL, 0])
        self.assertEqual(calls[-1]["leaderReturnCodeBefore"], -signal.SIGTERM)

    def test_query_cancellation_never_reenters_nonzero_signals(self):
        receipt, calls, result = self.term_case(injected_eperm=True, cancel_query=True)
        self.assertEqual(result, 143)
        self.assertEqual(receipt["trigger"], "cancelled")
        self.assertEqual(receipt["cleanupOutcome"], "failure")
        self.assertIn("reentry", receipt["cleanupError"])
        self.assertFalse(cli_receipt_complete(receipt))
        self.assertEqual([call["signal"] for call in calls], [signal.SIGTERM, signal.SIGKILL, 0])

    def test_synthetic_query_errors_remain_failure_and_preserve_signal_order(self):
        # Fake process and syscalls: deterministic negative branches, not OS evidence.
        for error in (None, PermissionError(errno.EPERM, "injected"), InterruptedError(errno.EINTR, "injected"),
                      OSError(errno.EINVAL, "injected"), RuntimeError("injected query exception")):
            with self.subTest(error=error):
                process, clock, calls, receipt = Mock(pid=424242, returncode=None), [0.0], [], {}
                def wait(timeout):
                    if not calls:
                        clock[0] = 1
                        raise subprocess.TimeoutExpired("synthetic", timeout)
                    process.returncode = -signal.SIGTERM
                    return process.returncode
                def signal_group(pgid, sig):
                    calls.append((pgid, sig, process.returncode))
                    if sig == signal.SIGKILL:
                        raise PermissionError(errno.EPERM, "injected KILL error")
                    if sig == 0 and error is not None:
                        raise error
                process.wait.side_effect = wait
                with patch("run_bounded.subprocess.Popen", return_value=process), \
                     patch("run_bounded.time.monotonic", side_effect=lambda: clock[0]), \
                     patch("run_bounded.time.sleep", side_effect=lambda value: clock.__setitem__(0, clock[0] + value)), \
                     patch("run_bounded.os.killpg", side_effect=signal_group):
                    self.assertEqual(run_bounded(["synthetic"], 1, receipt=receipt), 124)
                self.assertEqual([call[1] for call in calls], [signal.SIGTERM, signal.SIGKILL, 0])
                self.assertIsNone(calls[1][2])
                self.assertEqual(calls[2][2], -signal.SIGTERM)
                self.assertEqual(receipt["kill"]["errno"], errno.EPERM)
                self.assertEqual(receipt["cleanupOutcome"], "failure")
                self.assertFalse(cli_receipt_complete(receipt))

    def test_first_cleanup_after_real_wait_output_error_never_signals_old_group(self):
        receipt, native_print = {}, print
        def log(*args, **kwargs):
            if args and str(args[0]).startswith("[watchdog] finished"):
                raise OSError("Injected output error after the real normal wait reaped")
            native_print(*args, **kwargs)
        with patch("run_bounded.print", side_effect=log, create=True), patch("run_bounded.os.killpg") as signals, \
             patch("run_bounded.subprocess.Popen.poll", side_effect=AssertionError("No polling allowed")) as poll:
            with self.assertRaisesRegex(OSError, "after the real normal wait"):
                run_bounded([sys.executable, "-c", "raise SystemExit(0)"], 5, receipt=receipt)
        signals.assert_not_called()
        poll.assert_not_called()
        self.assertEqual(receipt["returnCode"], 0)
        self.assertTrue(receipt["reaped"])
        self.assertIn("unanchored", receipt["cleanupError"])
        self.assertEqual(receipt["cleanupOutcome"], "failure")
        self.assertFalse(cli_receipt_complete(receipt))
        WATCHDOG_RECEIPT_EVIDENCE.append(dict(case="real-normal-wait-injected-output-error", **receipt))

    def test_synthetic_ineligible_cleanup_never_queries(self):
        for kind in ("term-error", "kill-other-error", "wrong-return", "unreaped"):
            with self.subTest(kind=kind):
                process, clock, calls, receipt = Mock(pid=424242, returncode=None), [0.0], [], {}
                def wait(timeout):
                    if not calls:
                        clock[0] = 1
                        raise subprocess.TimeoutExpired("synthetic", timeout)
                    if kind == "unreaped":
                        raise ChildProcessError(errno.ECHILD, "injected unknown wait status")
                    process.returncode = -signal.SIGKILL if kind == "wrong-return" else -signal.SIGTERM
                    return process.returncode
                def signal_group(pgid, sig):
                    calls.append(sig)
                    if sig == signal.SIGTERM and kind == "term-error":
                        raise PermissionError(errno.EACCES, "injected TERM error")
                    if sig == signal.SIGKILL:
                        raise PermissionError(errno.EACCES if kind == "kill-other-error" else errno.EPERM, "injected KILL error")
                process.wait.side_effect = wait
                with patch("run_bounded.subprocess.Popen", return_value=process), \
                     patch("run_bounded.time.monotonic", side_effect=lambda: clock[0]), \
                     patch("run_bounded.time.sleep", side_effect=lambda value: clock.__setitem__(0, clock[0] + value)), \
                     patch("run_bounded.os.killpg", side_effect=signal_group):
                    self.assertEqual(run_bounded(["synthetic"], 1, receipt=receipt), 124)
                self.assertEqual(calls, [signal.SIGTERM, signal.SIGKILL])
                self.assertNotIn("postReapGroupCheck", receipt)
                self.assertFalse(cli_receipt_complete(receipt))

    def test_real_normal_exit_receipt(self):
        receipt = {}
        self.assertEqual(run_bounded([sys.executable, "-c", "raise SystemExit(0)"], 5, receipt=receipt), 0)
        self.assertTrue(cli_receipt_complete(receipt))
        self.assertEqual(receipt["returnCode"], 0)
        self.assertEqual(receipt["trigger"], "exit")
        WATCHDOG_RECEIPT_EVIDENCE.append(dict(case="real-normal-exit", **receipt))

    def test_real_timeout_receipt(self):
        receipt = {}
        child = "import signal,time; signal.signal(signal.SIGTERM, signal.SIG_IGN); print('armed', flush=True); time.sleep(30)"
        with tempfile.TemporaryFile() as output:
            self.assertEqual(run_bounded([sys.executable, "-c", child], 2, stdout=output, receipt=receipt), 124)
            output.seek(0)
            armed = output.read().decode().strip()
        self.assertEqual(armed, "armed")
        self.assertTrue(cli_receipt_complete(receipt))
        self.assertEqual(receipt["trigger"], "timeout")
        self.assertEqual(receipt["term"]["status"], "sent")
        self.assertEqual(receipt["kill"]["status"], "sent")
        self.assertEqual(receipt["returnCode"], -signal.SIGKILL)
        self.assertTrue(receipt["reaped"])
        WATCHDOG_RECEIPT_EVIDENCE.append(dict(case="real-timeout-term-ignored", armed=armed, **receipt))


class SceneEvidenceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.runner = FakeRunner(self.directory)
        self.definition = self.runner.probes[0]
        for sig in (signal.SIGTERM, signal.SIGINT):
            self.addCleanup(signal.signal, sig, signal.getsignal(sig))

    def scene(self, sealed=False):
        scene = scene_fixture(self.runner, self.definition, "probe:tactical", sealed=sealed)
        return {"pid": scene["pid"], "status": "success", "scene": scene}

    def records(self, scene):
        return trace_records(self.runner.summary, scene, self.directory)

    def rewrite(self, scene, records):
        for index, item in enumerate(records):
            item.update(sequence=index + 1, uptimeSeconds=101 + index, elapsedSeconds=index + 1)
        data = b"".join(b"DESERTCI " + json.dumps(item, sort_keys=True).encode() + b"\n" for item in records)
        path = self.directory / scene["stdout"]["path"]
        path.write_bytes(data)
        scene["stdout"], _ = file_evidence(self.directory, path.name)

    def package(self, runner):
        runner.save()
        environment = {key: runner.summary[field] for key, field in (
            ("CI_VERSION", "version"), ("GITHUB_REF_NAME", "branch"), ("GITHUB_SHA", "commitSha"),
            ("GITHUB_RUN_ID", "runId"), ("GITHUB_RUN_ATTEMPT", "runAttempt"))}
        environment.update(WORKFLOW_NAME="synthetic scene fixture", GITHUB_OUTPUT=str(self.directory / "outputs"),
                           STATIC_OUTCOME="success", PROJECT_LINT_OUTCOME="success", BUILD_OUTCOME="success",
                           SIMULATOR_LAUNCH_OUTCOME="success")
        with patch.dict(os.environ, environment), patch("package_results.Path", side_effect=lambda path:
                self.directory if path == "ci-results" else Path(path)):
            package_results()
        return json.loads((self.directory / "ci-artifact-manifest.json").read_text())

    def test_scene_identity_fields_reject_stale_or_cross_launch(self):
        for key in ("commitSha", "runId", "runAttempt", "version", "pid", "probeID", "nonce", "deviceUDID"):
            with self.subTest(field=key):
                scene = self.scene()["scene"]
                records = self.records(scene)
                records[0][key] = "stale-or-another-launch"
                self.rewrite(scene, records)
                with self.assertRaisesRegex(ValueError, "identity"):
                    self.records(scene)

    def test_scene_only_one_frame_is_not_ready(self):
        scene = self.scene()["scene"]
        records = self.records(scene)
        records[-1]["frames"] = records[-1]["frames"][:1]
        with self.assertRaisesRegex(ValueError, "stable frames"):
            latest_ready(records, self.definition)

    def test_scene_missing_stage_or_production_fact_rejects_ready(self):
        for mutation in ("initialization", "fixture", "hud", "stage", "branch"):
            with self.subTest(mutation=mutation):
                scene = self.scene()["scene"]
                records = self.records(scene)
                if mutation == "stage":
                    records = [item for item in records if item["stage"] != "fixture-end"]
                elif mutation == "branch":
                    records[-1]["fixtureBranch"] = "unexecuted-branch"
                elif mutation == "fixture":
                    records[-1]["fixtureChecks"]["syntheticSchemaOnly"] = False
                else:
                    records[-1]["checks"]["initialized" if mutation == "initialization" else mutation] = False
                with self.assertRaisesRegex(ValueError, "production stages"):
                    latest_ready(records, self.definition)

    def test_scene_later_geometry_invalidates_ready_and_old_frames(self):
        scene = self.scene()["scene"]
        records = self.records(scene)
        old_ready = records[-1]
        records.append(dict(old_ready, stage="geometry-invalidated"))
        self.assertIsNone(latest_ready(records, self.definition))
        records.append(dict(old_ready))
        with self.assertRaisesRegex(ValueError, "stable frames"):
            latest_ready(records, self.definition)
        self.rewrite(scene, records)
        with self.assertRaises(ValueError):
            seal_scene(self.runner.summary, scene, self.directory, self.definition)

    def test_scene_corrupt_oversize_partial_or_wrong_file_rejected(self):
        for mutation in ("json", "file-limit", "line-limit", "partial", "basename", "app-limit"):
            with self.subTest(mutation=mutation):
                scene = self.scene()["scene"]
                path = self.directory / scene["stdout"]["path"]
                if mutation == "partial":
                    path.write_bytes(path.read_bytes().rstrip(b"\n"))
                    self.assertIsNone(latest_ready(self.records(scene), self.definition))
                    continue
                if mutation == "json": path.write_bytes(b"DESERTCI {bad-json}\n")
                elif mutation == "file-limit": path.write_bytes(b"x" * (TRACE_LIMIT + 1))
                elif mutation == "line-limit": path.write_bytes(b"DESERTCI " + b"x" * 8192 + b"\n")
                elif mutation == "basename": scene["stdout"]["path"] = "another-launch.log"
                else:
                    records = self.records(scene)
                    records.append(dict(records[-1], stage="trace-limit-exceeded"))
                    self.rewrite(scene, records)
                with self.assertRaises((ValueError, FileNotFoundError)):
                    self.records(scene)

    def test_scene_snapshot_survives_later_stderr_but_not_tampering(self):
        record = self.scene(sealed=True)
        scene = record["scene"]
        live = self.directory / scene["directFiles"]["stderr"]["path"]
        live.write_bytes(b"benign termination diagnostic after the snapshot\n")
        validate_scene(self.runner.summary, record, self.directory, self.definition, "probe:tactical")
        (self.directory / scene["stderr"]["path"]).write_bytes(b"tampered snapshot\n")
        with self.assertRaisesRegex(ValueError, "trace integrity"):
            validate_scene(self.runner.summary, record, self.directory, self.definition, "probe:tactical")

    def test_scene_snapshot_refuses_postcapture_new_ready(self):
        scene = self.scene()["scene"]
        records = self.records(scene)
        records.append(dict(records[-1], stage="geometry-invalidated"))
        new_frames = [dict(number=3, time=3, revision=2), dict(number=4, time=4, revision=2)]
        records.extend(dict(records[0], stage="stable-frame", frame=frame) for frame in new_frames)
        records.append(dict(scene["ready"], geometryRevision=2, frames=new_frames))
        self.rewrite(scene, records)
        self.assertIsNotNone(latest_ready(self.records(scene), self.definition))
        with self.assertRaisesRegex(ValueError, "changed"):
            seal_scene(self.runner.summary, scene, self.directory, self.definition)

    def test_scene_report_current_bundle_nonce_path_and_hash(self):
        for mutation in ("valid", "bundle", "nonce", "hash", "outside", "symlink", "oversize"):
            with self.subTest(mutation=mutation), tempfile.TemporaryDirectory() as directory:
                root = Path(directory) / "unit-device" / "data"
                container = root / "Containers/Data/Application" / str(uuid.uuid4())
                nonce, bundle = uuid.uuid4().hex, "unit.fixture.only"
                source = container / "Documents/DesertCI" / nonce / "hud-layout-contract.json"
                source.parent.mkdir(parents=True)
                data = b'{"syntheticSchemaOnly":true}'
                source.write_bytes(data)
                metadata = container / ".com.apple.mobile_container_manager.metadata.plist"
                metadata.write_bytes(plistlib.dumps({"MCMMetadataIdentifier": bundle}))
                descriptor = dict(path=str(source), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
                if mutation == "valid":
                    self.assertEqual(read_hud_report(root, descriptor, nonce, bundle), data)
                    continue
                if mutation == "bundle": bundle = "another.bundle"
                elif mutation == "nonce": nonce = uuid.uuid4().hex
                elif mutation == "hash": descriptor["sha256"] = "0" * 64
                elif mutation == "outside": root = Path(directory) / "other-device"
                elif mutation == "oversize": source.write_bytes(b"x" * 1048577)
                else:
                    target = source.with_suffix(".real")
                    source.rename(target)
                    source.symlink_to(target)
                with self.assertRaises((ValueError, FileNotFoundError)):
                    read_hud_report(root, descriptor, nonce, bundle)

    def test_scene_short_records_wrong_probe_and_nonce_reuse_metadata_red(self):
        for mutation in ("short", "probe", "nonce"):
            with self.subTest(mutation=mutation):
                self.runner.work()
                if mutation == "short": self.runner.summary["probes"].pop()
                elif mutation == "nonce":
                    self.runner.summary["probes"][1]["scene"]["nonce"] = self.runner.summary["probes"][0]["scene"]["nonce"]
                else:
                    scene = self.runner.summary["probes"][0]["scene"]
                    records = self.records(scene)
                    for item in records: item["probeID"] = "probe:wrong"
                    scene["probeID"] = "probe:wrong"
                    scene["ready"] = records[-1]
                    self.rewrite(scene, records)
                with self.assertRaises(ProbeFailure):
                    validate_scene_evidence(self.runner.probes, self.runner.summary, self.directory)
                self.runner.summary.update(status="success", integrityOutcome="success")
                manifest = self.package(self.runner)
                self.assertEqual(manifest["sceneReadinessOutcome"], "failure")
                self.assertEqual(manifest["probeIntegrityOutcome"], "failure")
                self.runner = FakeRunner(self.directory)

    def test_scene_first_five_distinct_pages_pass_the_narrow_hash_gate(self):
        self.runner.work()
        validate_page_images(self.runner.summary["probes"])
        self.assertEqual(len({item["image"]["sha256"] for item in self.runner.summary["probes"][:5]}), 5)
        self.runner.summary.update(status="success", integrityOutcome="success")
        manifest = self.package(self.runner)
        self.assertEqual(manifest["sceneReadinessOutcome"], "success")
        self.assertEqual(manifest["probeIntegrityOutcome"], "success")

    def test_scene_duplicate_page_early_stops_preserving_png_and_trace(self):
        original = self.runner.simctl
        def repeated_page(name, *args, **kwargs):
            original(name, *args, **kwargs)
            if args[0] == "io": Path(args[-1]).write_bytes(png_bytes(120))
        self.runner.simctl = repeated_page
        self.assertEqual(self.runner.execute(), 1)
        records = self.runner.summary["probes"]
        self.assertEqual([item["status"] for item in records[:2]], ["success", "failure"])
        self.assertTrue(all(item["status"] == "not_run" for item in records[2:]))
        self.assertTrue((self.directory / records[1]["png"]).is_file())
        self.assertTrue((self.directory / records[1]["scene"]["stdout"]["path"]).is_file())
        self.assertIn("identical PNG", records[1]["error"])
        self.assertEqual(self.package(self.runner)["sceneReadinessOutcome"], "failure")

    def test_scene_readiness_failure_stops_before_screenshot_and_keeps_trace(self):
        def not_ready(*args, **kwargs):
            raise SceneFailure("injected missing initialization/frame readiness")
        self.runner.wait_scene = not_ready
        self.assertEqual(self.runner.execute(), 1)
        records = self.runner.summary["probes"]
        self.assertEqual(records[0]["status"], "failure")
        self.assertTrue(all(item["status"] == "not_run" for item in records[1:]))
        self.assertFalse((self.directory / records[0]["png"]).exists())
        self.assertTrue((self.directory / records[0]["scene"]["stdout"]["path"]).is_file())

    def test_scene_readiness_window_never_resets_shared_deadline(self):
        clock = [0.0]
        with patch("simulator_probe.time.monotonic", side_effect=lambda: clock[0]):
            runner = Runner(self.directory, budget=20)
            runner.device = self.runner.device
            scene = scene_fixture(runner, self.definition, "probe:tactical")
            records = trace_records(runner.summary, scene, self.directory)
            self.rewrite(scene, [item for item in records if item["stage"] not in ("stable-frame", "ready")])
            record = dict(pid=scene["pid"], scene=scene)
            def minimum_wait(name, seconds):
                runner.remaining(seconds)
                clock[0] += seconds
            runner.wait = minimum_wait
            with patch("simulator_probe.time.sleep", side_effect=lambda seconds: clock.__setitem__(0, clock[0] + seconds)):
                with self.assertRaisesRegex(SceneFailure, "readiness deadline"):
                    runner.wait_scene(record, self.definition, 4, window=7)
            self.assertEqual(clock[0], 7)
            self.assertEqual(runner.deadline, 20)
            self.assertEqual(scene["status"], "failure")
            self.assertEqual(scene["lastStage"], "units-end")


class NormalizationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.directory = Path(self.temp.name)
        self.runner = Runner(self.directory)

    def tearDown(self):
        self.temp.cleanup()

    def test_portrait_real_sips_270_corner_positions(self):
        path = self.directory / "portrait-fixture.png"
        path.write_bytes(rgb_fixture(2, 3))
        raw = png_info(path)
        record = {}
        self.runner.normalize_screenshot("fixture:portrait", path, record)
        # Independent expectation: clockwise 270 maps A B / C D / E F to B D F / A C E.
        expected = [[(0, 255, 0), (0, 255, 255), (255, 255, 0)],
                    [(255, 0, 0), (255, 0, 255), (0, 0, 255)]]
        actual = fixture_pixels(path)
        self.assertEqual(actual, expected)
        self.assertEqual(record["rawImage"], raw)
        self.assertEqual(record["rotationDegrees"], 270)
        self.assertEqual((record["image"]["width"], record["image"]["height"]), (3, 2))
        NORMALIZATION_EVIDENCE.append(dict(case="portrait-real-sips", **record,
                                           expectedPixels=expected, actualPixels=actual))

    def test_native_landscape_is_unchanged(self):
        path = self.directory / "landscape-fixture.png"
        path.write_bytes(rgb_fixture(3, 2))
        raw, pixels = png_info(path), fixture_pixels(path)
        record = {}
        with patch.object(self.runner, "command") as command:
            self.runner.normalize_screenshot("fixture:landscape", path, record)
        command.assert_not_called()
        self.assertEqual(record["rotationDegrees"], 0)
        self.assertEqual(record["rawImage"], raw)
        self.assertEqual(record["image"], raw)
        self.assertEqual(fixture_pixels(path), pixels)
        NORMALIZATION_EVIDENCE.append(dict(case="native-landscape-no-command", **record))

    def test_square_is_rejected(self):
        path = self.directory / "square-fixture.png"
        path.write_bytes(rgb_fixture(1, 1))
        with self.assertRaises(ProbeFailure):
            self.runner.normalize_screenshot("fixture:square", path, {})


if __name__ == "__main__":
    if os.environ.get("GITHUB_ACTIONS") != "true":
        raise SystemExit("Cloud-only regression; do not run locally")
    results = []
    for case, name, execution in (
            (ProbeTests, "scheduler-and-evidence", "fake simulator commands; real short timeout command"),
            (InstallationTests, "bounded-install-policy", "fake clock and simulator commands; production install policy/gate"),
            (BootTests, "same-device-boot-continuation", "fake clock/CLI receipts; production boot/command/deadline and metadata gates; no simulator"),
            (WatchdogReceiptTests, "cli-process-receipts", "real short CLI normal exit and timeout; no simulator"),
            (SceneEvidenceTests, "scene-readiness-protocol", "synthetic protocol/path/hash fixtures and fake clock; no Swift layout or simulator"),
            (NormalizationTests, "screenshot-normalization", "real sips portrait rotation; no simulator")):
        print(f"Cloud regression suite: {name} ({execution})", flush=True)
        result = unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(case))
        results.append({"name": name, "execution": execution, "tests": result.testsRun,
                        "failures": len(result.failures), "errors": len(result.errors),
                        "skipped": len(result.skipped), "success": result.wasSuccessful()})
    success = all(result["success"] for result in results)
    Path("ci-results").mkdir(exist_ok=True)
    Path("ci-results/ci-regression-results.json").write_text(json.dumps({
        "suite": "CI scheduler, same-device boot, bounded install, CLI receipts, HUD/image evidence and real sips normalization (no simulator)",
        **{key: sum(result[key] for result in results) for key in ("tests", "failures", "errors", "skipped")},
        "suites": results, "normalizationFixtures": NORMALIZATION_EVIDENCE, "watchdogReceipts": WATCHDOG_RECEIPT_EVIDENCE,
        "success": success, "commitSha": os.environ.get("GITHUB_SHA"),
        "runId": os.environ.get("GITHUB_RUN_ID"), "runAttempt": os.environ.get("GITHUB_RUN_ATTEMPT"),
    }, indent=2) + "\n")
    sys.exit(0 if success else 1)
