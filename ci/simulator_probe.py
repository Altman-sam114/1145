#!/usr/bin/env python3
"""Cloud-only, single-device capture runner with a shared monotonic deadline."""
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import plistlib
import re
import signal
import struct
import sys
import tempfile
import time
import zlib

from run_bounded import run_bounded


class ProbeFailure(Exception):
    def __init__(self, message, code=1):
        super().__init__(message)
        self.code = code


def load_probes(path=Path(__file__).with_name("probes.json")):
    probes = json.loads(path.read_text())
    if len(probes) != 24:
        raise ProbeFailure("Expected exactly 24 formal probes")
    for key in ("id", "png"):
        if len({probe[key] for probe in probes}) != len(probes):
            raise ProbeFailure(f"Duplicate probe {key}")
    for probe in probes:
        if Path(probe["png"]).name != probe["png"] or not probe["png"].endswith(".png"):
            raise ProbeFailure("Probe PNG must be a results-directory basename")
        if probe["wait"] <= 0 or not all(probe[key] for key in ("id", "page", "marker", "focus")):
            raise ProbeFailure("Invalid probe definition")
    return probes


def png_info(path):
    """Validate screenshot CRCs and decoded scanlines, not just a PNG signature."""
    data = path.read_bytes()
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        raise ProbeFailure(f"Invalid or empty PNG: {path}")
    offset, width, height, channels = 8, 0, 0, 0
    compressed = bytearray()
    ended = False
    while offset < len(data):
        if offset + 12 > len(data):
            raise ProbeFailure(f"Truncated PNG chunk: {path}")
        length = struct.unpack_from(">I", data, offset)[0]
        kind = data[offset + 4:offset + 8]
        body = data[offset + 8:offset + 8 + length]
        if offset + length + 12 > len(data):
            raise ProbeFailure(f"Truncated PNG payload: {path}")
        crc = struct.unpack_from(">I", data, offset + 8 + length)[0]
        if zlib.crc32(kind + body) != crc:
            raise ProbeFailure(f"PNG CRC mismatch: {path}")
        if offset == 8 and kind != b"IHDR":
            raise ProbeFailure("PNG must start with IHDR")
        if kind == b"IHDR":
            if width or length != 13:
                raise ProbeFailure("Invalid PNG IHDR")
            width, height, depth, color, compression, filtering, interlace = struct.unpack(">IIBBBBB", body)
            channels = {2: 3, 6: 4}.get(color, 0)
            if not (0 < width <= 10000 and 0 < height <= 10000 and channels and depth == 8
                    and compression == filtering == interlace == 0):
                raise ProbeFailure("Screenshot must be a valid non-interlaced 8-bit RGB/RGBA PNG")
        elif kind == b"IDAT":
            compressed.extend(body)
        elif kind == b"IEND":
            ended = length == 0 and offset + 12 == len(data)
            break
        offset += length + 12
    if not ended or not compressed:
        raise ProbeFailure("PNG lacks complete image data/IEND")
    stride = width * channels + 1
    decoder = zlib.decompressobj()
    try:
        pixels = decoder.decompress(compressed, stride * height + 1)
    except zlib.error as error:
        raise ProbeFailure(f"PNG decompression failed: {error}") from error
    if (not decoder.eof or decoder.unused_data or len(pixels) != stride * height
            or any(pixels[row * stride] > 4 for row in range(height))):
        raise ProbeFailure("Invalid PNG scanlines")
    return {"bytes": len(data), "width": width, "height": height,
            "sha256": hashlib.sha256(data).hexdigest()}


def validate_results(probes, summary, directory):
    records = summary.get("probes", [])
    if len(records) != len(probes):
        raise ProbeFailure("Missing/extra probe records")
    for expected, record in zip(probes, records):
        if any(record.get(key) != value for key, value in expected.items()):
            raise ProbeFailure(f"Probe definition/order mismatch: {expected['id']}")
        if (record.get("status") != "success" or record.get("launchCount") != 1
                or not isinstance(record.get("pid"), int) or record["pid"] <= 0
                or record.get("aliveAfterLaunch") is not True
                or record.get("aliveAfterScreenshot") is not True):
            raise ProbeFailure(f"Incomplete launch/PID evidence: {expected['id']}")
        actual = png_info(directory / expected["png"])
        if actual != record.get("image") or actual["width"] <= actual["height"]:
            raise ProbeFailure(f"PNG evidence mismatch/not landscape: {expected['id']}")
    if len(list(directory.glob("simulator-*.png"))) != len(probes):
        raise ProbeFailure("Missing/extra simulator PNG files")


def version_tuple(value):
    parts = tuple(int(part) for part in value.split("."))
    return (parts + (0, 0, 0))[:3]


def select_device(runtimes, devices, minimum, sdk):
    eligible = []
    for runtime in runtimes.get("runtimes", []):
        identifier = runtime.get("identifier", "")
        if not runtime.get("isAvailable") or not identifier.startswith("com.apple.CoreSimulator.SimRuntime.iOS-"):
            continue
        version = version_tuple(runtime["version"])
        if not version_tuple(minimum) <= version <= version_tuple(sdk):
            continue
        for device in devices.get("devices", {}).get(identifier, []):
            if device.get("isAvailable") and device.get("name", "").startswith("iPhone"):
                eligible.append((version, device, runtime))
    if not eligible:
        raise ProbeFailure(f"No installed available iPhone runtime in deployment {minimum} ... SDK {sdk}")
    eligible.sort(key=lambda item: (tuple(-part for part in item[0]), item[1]["name"], item[1]["udid"]))
    _, device, runtime = eligible[0]
    return {"udid": device["udid"], "name": device["name"], "runtime": runtime,
            "deploymentTarget": minimum, "simulatorSDK": sdk,
            "reason": "No proven stable-runtime preference; latest installed available iOS <= SDK and >= deployment target, then iPhone name/UDID ascending"}


def alive(pid):
    try:
        os.kill(pid, 0)
        return True
    except (ProcessLookupError, PermissionError):
        return False


class Runner:
    def __init__(self, directory=Path("ci-results"), budget=1080):
        self.directory = directory
        self.directory.mkdir(parents=True, exist_ok=True)
        self.started = time.monotonic()
        self.deadline = self.started + budget
        self.probes = load_probes()
        self.device = None
        self.bundle = None
        self.summary = {
            "schemaVersion": 1, "version": os.environ.get("CI_VERSION", "unknown"),
            "commitSha": os.environ.get("GITHUB_SHA", ""), "runId": os.environ.get("GITHUB_RUN_ID", ""),
            "runAttempt": os.environ.get("GITHUB_RUN_ATTEMPT", ""), "branch": os.environ.get("GITHUB_REF_NAME", ""),
            "workBudgetSeconds": budget, "cleanupBudgetSeconds": 90, "stepHardLimitSeconds": 1260,
            "status": "running", "currentStage": "initializing", "lastCompletedProbe": None,
            "stages": [], "prewarm": [], "probes": [dict(p, status="not_run") for p in self.probes],
        }
        self.save()

    def save(self):
        statuses = [probe["status"] for probe in self.summary["probes"]]
        self.summary["counts"] = {"expected": len(self.probes), "completed": statuses.count("success"),
                                  "failed": statuses.count("failure"), "notRun": statuses.count("not_run"),
                                  "running": statuses.count("running")}
        self.summary["elapsedSeconds"] = round(time.monotonic() - self.started, 3)
        path = self.directory / "simulator-probe-summary.json"
        temporary = path.with_suffix(".json.tmp")
        temporary.write_text(json.dumps(self.summary, indent=2) + "\n")
        temporary.replace(path)

    def remaining(self, minimum=0):
        remaining = self.deadline - time.monotonic()
        if remaining <= minimum:
            raise ProbeFailure(f"Shared deadline exhausted/insufficient: remaining={max(remaining, 0):.1f}s, required>{minimum:g}s", 124)
        return remaining

    @contextmanager
    def stage(self, name):
        started = time.monotonic()
        record = {"name": name, "status": "running", "startedAfterSeconds": round(started - self.started, 3)}
        self.summary["currentStage"] = name
        self.summary["stages"].append(record)
        print(f"[stage] START {name}; remaining={max(self.deadline-started, 0):.1f}s", flush=True)
        self.save()
        try:
            yield
            record.update(status="success", exitCode=0)
        except BaseException as error:
            record.update(status="failure", exitCode=getattr(error, "code", 1), error=str(error))
            raise
        finally:
            record["elapsedSeconds"] = round(time.monotonic() - started, 3)
            print(f"[stage] END {name}; status={record['status']}; elapsed={record['elapsedSeconds']}s", flush=True)
            self.save()

    def command(self, name, command, cap=60, env=None, log=None):
        with self.stage(name):
            # Reserve group TERM/KILL/reap time inside the shared stage budget.
            seconds = min(cap, self.remaining(2) - 2)
            with tempfile.TemporaryFile() as output:
                try:
                    code = run_bounded(command, seconds, stdout=output, env=env)
                finally:
                    output.seek(0)
                    text = output.read().decode("utf-8", errors="replace")
                    if log:
                        (self.directory / log).write_text(text)
                    print(text, end="" if text.endswith("\n") else "\n", flush=True)
            if code:
                raise ProbeFailure(f"{name} exited {code}", code)
            return text

    def simctl(self, name, *arguments, cap=60, **kwargs):
        return self.command(name, ["/usr/bin/xcrun", "simctl", *arguments], cap=cap, **kwargs)

    def wait(self, name, seconds):
        with self.stage(name):
            self.remaining(seconds)
            end = time.monotonic() + seconds
            while time.monotonic() < end:
                time.sleep(min(30, end - time.monotonic()))
                self.remaining()
                print(f"[heartbeat] {name}; wait remaining={max(end-time.monotonic(), 0):.1f}s", flush=True)

    def launch(self, name, definition):
        env = dict(os.environ)
        env.update(SIMCTL_CHILD_DESERT_CI_CAPTURE_MODE="1",
                   SIMCTL_CHILD_DESERT_CI_HUD_PAGE=definition["page"],
                   SIMCTL_CHILD_DESERT_CI_COMMAND_MARKER=definition["marker"],
                   SIMCTL_CHILD_DESERT_CI_CAMERA_FOCUS=definition["focus"])
        output = self.simctl(name, "launch", "--terminate-running-process", self.device["udid"], self.bundle,
                             cap=120, env=env)
        matches = re.findall(rf"^{re.escape(self.bundle)}:\s*(\d+)\s*$", output, re.MULTILINE)
        if len(matches) != 1 or not alive(int(matches[0])):
            raise ProbeFailure(f"{name} did not return one live app PID")
        return int(matches[0])

    def capture(self, definition, index):
        record = self.summary["probes"][index]
        started = time.monotonic()
        record.update(status="running", launchCount=0)
        print(f"[probe] {index+1}/24 {definition['id']}", flush=True)
        self.save()
        try:
            record["launchCount"] = 1
            record["pid"] = self.launch(f"probe:{definition['id']}:launch", definition)
            record["aliveAfterLaunch"] = True
            self.save()
            self.wait(f"probe:{definition['id']}:render", definition["wait"])
            path = self.directory / definition["png"]
            self.simctl(f"probe:{definition['id']}:screenshot", "io", self.device["udid"], "screenshot", str(path), cap=180)
            with self.stage(f"probe:{definition['id']}:png-check"):
                image = png_info(path)
            if image["height"] > image["width"]:
                self.command(f"probe:{definition['id']}:landscape", ["/usr/bin/sips", "--rotate", "90", str(path)], cap=30)
            with self.stage(f"probe:{definition['id']}:pid-image-check"):
                record["image"] = png_info(path)
                record["aliveAfterScreenshot"] = alive(record["pid"])
                if not record["aliveAfterScreenshot"] or record["image"]["width"] <= record["image"]["height"]:
                    raise ProbeFailure("App exited after capture or PNG is not landscape")
                self.remaining()
            record["status"] = "success"
            self.summary["lastCompletedProbe"] = definition["id"]
            print(f"[probe] {index+1}/24 {definition['id']} SUCCESS pid={record['pid']} screenshot={definition['png']}", flush=True)
        except BaseException as error:
            record.update(status="failure", error=str(error))
            raise
        finally:
            record["elapsedSeconds"] = round(time.monotonic() - started, 3)
            self.save()

    def work(self):
        self.command("xcode-version", ["/usr/bin/xcodebuild", "-version"])
        self.command("simulator-sdk-build", ["/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild",
                     "-project", "DesertFrontline.xcodeproj", "-scheme", "DesertFrontline", "-configuration", "Debug",
                     "-sdk", "iphonesimulator", "-destination", "generic/platform=iOS Simulator",
                     "-derivedDataPath", ".derivedData-sim", "CODE_SIGNING_ALLOWED=NO", "build"],
                     cap=420, log="simulator-build.log")
        app = Path(".derivedData-sim/Build/Products/Debug-iphonesimulator/DesertFrontline.app")
        with self.stage("app-product"):
            with (app / "Info.plist").open("rb") as source:
                info = plistlib.load(source)
            self.bundle = info["CFBundleIdentifier"]
        sdk = self.command("simulator-sdk-version", ["/usr/bin/xcrun", "--sdk", "iphonesimulator", "--show-sdk-version"]).strip()
        runtimes = json.loads(self.simctl("installed-runtimes", "list", "runtimes", "--json", log="simulator-runtimes.json"))
        devices = json.loads(self.simctl("available-devices", "list", "devices", "available", "--json"))
        with self.stage("device-selection"):
            self.device = select_device(runtimes, devices, info["MinimumOSVersion"], sdk)
            self.summary["selectedDevice"] = self.device
            print(json.dumps(self.device, indent=2), flush=True)
        udid = self.device["udid"]
        for attempt in range(1, 3):
            if attempt > 1:
                self.remaining(240 + 120 + 95 + sum(p["wait"] for p in self.probes))
            try:
                self.simctl(f"boot:{attempt}", "boot", udid)
            except ProbeFailure as error:
                if error.code >= 128:
                    raise
                # Already-booted devices report nonzero; bootstatus is authoritative.
                print(f"[boot] boot command: {error}; checking bootstatus", flush=True)
            try:
                self.simctl(f"bootstatus:{attempt}", "bootstatus", udid, "-b", cap=240)
                break
            except ProbeFailure as error:
                if attempt == 2 or error.code >= 128:
                    raise
                self.simctl("boot-retry-shutdown", "shutdown", udid)
        self.simctl("install", "install", udid, str(app))
        for attempt in range(1, 4):
            if attempt > 1:
                self.remaining(120 + 95 + sum(p["wait"] for p in self.probes))
            record = {"attempt": attempt, "status": "running"}
            self.summary["prewarm"].append(record)
            try:
                pid = self.launch(f"prewarm:{attempt}:launch", self.probes[0])
                record.update(pid=pid, aliveAfterLaunch=True)
                self.wait(f"prewarm:{attempt}:notifications", 90)
                record["aliveAfterWait"] = alive(pid)
                if not record["aliveAfterWait"]:
                    raise ProbeFailure("Prewarm PID exited before notification wait ended")
                record["status"] = "success"
                self.save()
                break
            except ProbeFailure as error:
                record.update(status="failure", error=str(error))
                self.save()
                if attempt == 3 or error.code >= 128:
                    raise
                self.wait("prewarm-retry-wait", 20)
        self.simctl("prewarm-terminate", "terminate", udid, self.bundle)
        self.wait("prewarm-settle", 5)
        for index, probe in enumerate(self.probes):
            self.capture(probe, index)
        with self.stage("integrity-gate"):
            validate_results(self.probes, self.summary, self.directory)
            self.remaining()
            self.summary["integrityOutcome"] = "success"

    def finish(self):
        self.summary["workElapsedSeconds"] = round(time.monotonic() - self.started, 3)
        cleanup_started = time.monotonic()
        self.deadline = cleanup_started + 90
        if self.device:
            tasks = [
                ("diagnostic-app-log", ["spawn", self.device["udid"], "log", "show", "--last", "10m", "--style", "compact",
                                        "--predicate", 'process == "DesertFrontline"'], 25, "simulator-app.log"),
                ("diagnostic-device-state", ["list", "devices", "--json"], 20, "simulator-boot-state.json"),
                ("cleanup-device", ["shutdown", self.device["udid"]], 20, None),
            ]
            for name, args, cap, log in tasks:
                try:
                    self.simctl(name, *args, cap=cap, log=log)
                except Exception as error:
                    self.summary.setdefault("cleanupWarnings", []).append(str(error))
                    print(f"[cleanup] {error}", flush=True)
        else:
            (self.directory / "simulator-app.log").write_text("No simulator selected; app never launched.\n")
        self.summary["cleanupElapsedSeconds"] = round(time.monotonic() - cleanup_started, 3)
        self.summary["currentStage"] = "finished"
        self.save()

    def execute(self):
        code = 0
        try:
            self.work()
            self.summary.update(status="success", exitCode=0)
        except BaseException as error:
            code = getattr(error, "code", 1)
            self.summary.update(status="failure", failureStage=self.summary["currentStage"], error=str(error), exitCode=code)
            print(f"[failure] {self.summary['failureStage']}: {error}", flush=True)
            for record in self.summary["prewarm"]:
                if record["status"] == "running":
                    record.update(status="failure", error=str(error))
        finally:
            self.save()
            # Repeated cancellation must not interrupt owned-group cleanup/atomic evidence.
            signal.signal(signal.SIGTERM, signal.SIG_IGN)
            signal.signal(signal.SIGINT, signal.SIG_IGN)
            self.finish()
        return code


def main():
    if os.environ.get("GITHUB_ACTIONS") != "true":
        raise SystemExit("Cloud-only simulator probe; do not run locally")

    def cancelled(signum, frame):
        raise ProbeFailure(f"Cancelled by signal {signum}", 128 + signum)

    signal.signal(signal.SIGTERM, cancelled)
    signal.signal(signal.SIGINT, cancelled)
    return Runner().execute()


if __name__ == "__main__":
    sys.exit(main())
