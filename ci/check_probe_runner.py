#!/usr/bin/env python3
"""Standard-library CI regressions; never boots or queries a simulator."""
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

from simulator_probe import Runner, ProbeFailure, load_probes, png_info, select_device, validate_results


def png_bytes():
    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", 2, 1, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(b"\x00" + b"\x80\x90\xa0\xff" * 2)) + chunk(b"IEND", b""))


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


if __name__ == "__main__":
    if os.environ.get("GITHUB_ACTIONS") != "true":
        raise SystemExit("Cloud-only regression; do not run locally")
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(ProbeTests)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    Path("ci-results").mkdir(exist_ok=True)
    Path("ci-results/ci-regression-results.json").write_text(json.dumps({
        "suite": "CI probe scheduler (fake commands; no simulator)", "tests": result.testsRun,
        "failures": len(result.failures), "errors": len(result.errors), "skipped": len(result.skipped),
        "success": result.wasSuccessful(), "commitSha": os.environ.get("GITHUB_SHA"),
        "runId": os.environ.get("GITHUB_RUN_ID"), "runAttempt": os.environ.get("GITHUB_RUN_ATTEMPT"),
    }, indent=2) + "\n")
    sys.exit(0 if result.wasSuccessful() else 1)
