#!/usr/bin/env python3
"""Standard-library CI regressions; never boots or queries a simulator."""
import hashlib
import json
import os
from pathlib import Path
import signal
import struct
import sys
import tempfile
import unittest
from unittest.mock import patch
import zlib

from simulator_probe import (HUD_CHECKS, HUD_FIXTURES, HUD_PAGES, Runner, ProbeFailure,
                             INSTALL_CAP, INSTALL_POLICY, INSTALL_RECOVERY_CAP, cli_receipt_complete, install_reserve,
                             load_probes, png_info, select_device, validate_hud_contract, validate_installation, validate_results)
from run_bounded import run_bounded
from package_results import main as package_results


NORMALIZATION_EVIDENCE = []
WATCHDOG_RECEIPT_EVIDENCE = []


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
    runner.summary["prewarm"] = [{"status": "success", "pid": pid, "aliveAfterWait": True}]
    report = {key: runner.summary[key] for key in ("commitSha", "runId", "runAttempt", "version")}
    report.update(schemaVersion=1, producer="GameScene.HUDLayout", pid=pid, status="success", stateRestored=True,
                  actualSize={"width": 874, "height": 402}, actualInsets={"top": 0, "left": 62, "bottom": 21, "right": 62}, matrix=[])
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
                controls=controls, panelArea=1, viewportArea=2, panelAreaFraction=0.5))
    write_hud_fixture(runner, report)


def write_hud_fixture(runner, report):
    data = json.dumps(report, sort_keys=True).encode()
    (runner.directory / "hud-layout-contract.json").write_bytes(data)
    runner.summary["hudContract"] = {"path": "hud-layout-contract.json", "pid": os.getpid(), "status": "success",
                                     "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def png_bytes():
    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", 2, 1, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(b"\x00" + b"\x80\x90\xa0\xff" * 2)) + chunk(b"IEND", b""))


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
        self.device = {"udid": "fake-cloud-unit-test-only"}

    def launch(self, name, definition):
        if definition["id"] == self.fail_at:
            raise ProbeFailure("injected launch timeout", 124)
        return os.getpid()

    def wait(self, name, seconds):
        self.remaining(seconds)

    def simctl(self, name, *args, **kwargs):
        if args[0] == "io":
            Path(args[-1]).write_bytes(png_bytes())

    def work(self):
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


class WatchdogReceiptTests(unittest.TestCase):
    def test_real_normal_exit_receipt(self):
        receipt = {}
        self.assertEqual(run_bounded([sys.executable, "-c", "raise SystemExit(0)"], 5, receipt=receipt), 0)
        self.assertTrue(cli_receipt_complete(receipt))
        self.assertEqual(receipt["returnCode"], 0)
        self.assertEqual(receipt["trigger"], "exit")
        WATCHDOG_RECEIPT_EVIDENCE.append(dict(case="real-normal-exit", **receipt))

    def test_real_timeout_receipt(self):
        receipt = {}
        self.assertEqual(run_bounded([sys.executable, "-c", "import time; time.sleep(30)"], 0.05, receipt=receipt), 124)
        self.assertTrue(cli_receipt_complete(receipt))
        self.assertEqual(receipt["trigger"], "timeout")
        self.assertIn(receipt["term"]["status"], ("sent", "already_gone"))
        self.assertIn(receipt["kill"]["status"], ("sent", "already_gone"))
        WATCHDOG_RECEIPT_EVIDENCE.append(dict(case="real-timeout", **receipt))


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
            (WatchdogReceiptTests, "cli-process-receipts", "real short CLI normal exit and timeout; no simulator"),
            (NormalizationTests, "screenshot-normalization", "real sips portrait rotation; no simulator")):
        print(f"Cloud regression suite: {name} ({execution})", flush=True)
        result = unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(case))
        results.append({"name": name, "execution": execution, "tests": result.testsRun,
                        "failures": len(result.failures), "errors": len(result.errors),
                        "skipped": len(result.skipped), "success": result.wasSuccessful()})
    success = all(result["success"] for result in results)
    Path("ci-results").mkdir(exist_ok=True)
    Path("ci-results/ci-regression-results.json").write_text(json.dumps({
        "suite": "CI scheduler, bounded install, CLI receipts, HUD/image evidence and real sips normalization (no simulator)",
        **{key: sum(result[key] for result in results) for key in ("tests", "failures", "errors", "skipped")},
        "suites": results, "normalizationFixtures": NORMALIZATION_EVIDENCE, "watchdogReceipts": WATCHDOG_RECEIPT_EVIDENCE,
        "success": success, "commitSha": os.environ.get("GITHUB_SHA"),
        "runId": os.environ.get("GITHUB_RUN_ID"), "runAttempt": os.environ.get("GITHUB_RUN_ATTEMPT"),
    }, indent=2) + "\n")
    sys.exit(0 if success else 1)
