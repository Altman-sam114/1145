#!/usr/bin/env python3
"""Cloud-only, single-device capture runner with a shared monotonic deadline."""
from contextlib import contextmanager
import hashlib
import json
import math
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


NORMALIZATION_POLICY = "hosted-portrait-270-native-landscape-0-v1"
HUD_CHECKS = {"controls", "containers", "bands", "routing", "pending", "pageState", "roundTrip", "labels", "rebuild"}
HUD_FIXTURES = {"667x375": (667, 375), "852x393": (852, 393), "874x402": (874, 402),
                "1024x768": (1024, 768), "1366x1024": (1366, 1024)}
HUD_PAGES = {"tactical", "build", "air", "naval", "support"}


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


def validate_normalization(record):
    raw, image = record.get("rawImage"), record.get("image")
    for info in (raw, image):
        if (not isinstance(info, dict) or set(info) != {"bytes", "width", "height", "sha256"}
                or any(type(info[key]) is not int or info[key] <= 0 for key in ("bytes", "width", "height"))
                or not isinstance(info["sha256"], str) or not re.fullmatch(r"[0-9a-f]{64}", info["sha256"])):
            raise ProbeFailure("Missing/invalid raw or normalized image evidence")
    if record.get("normalizationPolicy") != NORMALIZATION_POLICY:
        raise ProbeFailure("Missing/incorrect image normalization policy")
    angle = record.get("rotationDegrees")
    if type(angle) is not int:
        raise ProbeFailure("Missing image rotation evidence")
    if raw["height"] > raw["width"]:
        if angle != 270 or (image["width"], image["height"]) != (raw["height"], raw["width"]):
            raise ProbeFailure("Portrait image must use 270-degree rotation and swapped dimensions")
    elif raw["width"] > raw["height"]:
        if angle != 0 or raw != image:
            raise ProbeFailure("Native landscape image must remain unchanged")
    else:
        raise ProbeFailure("Square screenshot cannot establish landscape normalization")


def validate_hud_contract(summary, directory):
    """Validate Swift-produced evidence/identity, never duplicate HUD geometry in Python."""
    path = directory / "hud-layout-contract.json"
    if not 0 < path.stat().st_size <= 1_048_576:
        raise ProbeFailure("HUD contract missing, empty or oversized")
    data = path.read_bytes()
    report = json.loads(data)
    evidence = summary.get("hudContract", {})
    if (evidence.get("path") != path.name or evidence.get("bytes") != len(data)
            or evidence.get("sha256") != hashlib.sha256(data).hexdigest()):
        raise ProbeFailure("HUD contract file integrity mismatch")
    if report.get("schemaVersion") != 1 or report.get("producer") != "GameScene.HUDLayout":
        raise ProbeFailure("HUD contract schema/production source mismatch")
    for key in ("commitSha", "runId", "runAttempt", "version"):
        if not summary.get(key) or report.get(key) != summary[key]:
            raise ProbeFailure(f"HUD contract stale/missing identity: {key}")
    producers = [item.get("pid") for item in summary.get("prewarm", [])
                 if item.get("status") == "success" and item.get("aliveAfterWait") is True]
    if (type(report.get("pid")) is not int or report["pid"] <= 0
            or report["pid"] not in producers or evidence.get("pid") != report["pid"]):
        raise ProbeFailure("HUD contract producer is not the successful live prewarm PID")
    if report.get("status") != "success" or report.get("stateRestored") is not True:
        raise ProbeFailure("HUD contract failed or actual scene state was not restored")

    def finite_positive(value):
        return type(value) in (int, float) and math.isfinite(value) and value > 0

    def rectangle(value):
        return (isinstance(value, dict) and set(value) == {"x", "y", "width", "height"}
                and all(type(number) in (int, float) and math.isfinite(number) for number in value.values())
                and value["width"] > 0 and value["height"] > 0)

    actual = report.get("actualSize", {})
    insets = report.get("actualInsets", {})
    if (not all(finite_positive(actual.get(key)) for key in ("width", "height"))
            or actual["width"] <= actual["height"]
            or set(insets) != {"top", "left", "bottom", "right"}
            or not all(type(value) in (int, float) and math.isfinite(value) and value >= 0 for value in insets.values())):
        raise ProbeFailure("HUD contract actual window geometry missing/invalid")
    matrix = report.get("matrix", [])
    if len(matrix) != 25:
        raise ProbeFailure("HUD contract must contain all 25 size/page combinations")
    seen = set()
    for item in matrix:
        key = (item.get("fixture"), item.get("page"))
        if key in seen or key[0] not in HUD_FIXTURES or key[1] not in HUD_PAGES:
            raise ProbeFailure("HUD contract duplicate/unknown fixture/page")
        seen.add(key)
        width, height = HUD_FIXTURES[key[0]]
        expected_insets = (insets if key[0] == "874x402" else
                           {"top": 0, "left": 59, "bottom": 21, "right": 59} if key[0] == "852x393" else
                           {"top": 0, "left": 0, "bottom": 0, "right": 0})
        if item.get("size") != {"width": width, "height": height} or item.get("insets") != expected_insets:
            raise ProbeFailure(f"HUD contract fixture metadata mismatch: {key}")
        checks = item.get("checks", {})
        if (set(checks) != HUD_CHECKS or any(value is not True for value in checks.values())
                or item.get("status") != "success" or item.get("failures") != []):
            raise ProbeFailure(f"HUD contract assertions failed/incomplete: {key}")
        panels, controls = item.get("panels", {}), item.get("controls", {})
        required_controls = {f"page:{page}" for page in HUD_PAGES} | {"zoomOut", "zoomIn", "map"}
        if (set(panels) != {"resources", "rail", "dock", "mission", "message", "selection", "minimap"}
                or not required_controls <= set(controls) or not any(key.startswith("action:") for key in controls)
                or not rectangle(item.get("safeFrame"))
                or not all(rectangle(value) for value in [*panels.values(), *controls.values()])
                or not all(finite_positive(item.get(field)) for field in ("panelArea", "viewportArea", "panelAreaFraction"))
                or item["panelAreaFraction"] >= 1):
            raise ProbeFailure(f"HUD contract frame/area evidence incomplete: {key}")
    return report


def validate_results(probes, summary, directory):
    validate_hud_contract(summary, directory)
    if summary.get("hudContract", {}).get("status") != "success":
        raise ProbeFailure("HUD contract collection/validation did not complete")
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
        validate_normalization(record)
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
            "schemaVersion": 2, "version": os.environ.get("CI_VERSION", "unknown"),
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
                   SIMCTL_CHILD_DESERT_CI_CAMERA_FOCUS=definition["focus"],
                   SIMCTL_CHILD_DESERT_CI_HUD_CONTRACT="1" if name.startswith("prewarm:") else "0",
                   SIMCTL_CHILD_DESERT_CI_COMMIT_SHA=self.summary["commitSha"],
                   SIMCTL_CHILD_DESERT_CI_RUN_ID=self.summary["runId"],
                   SIMCTL_CHILD_DESERT_CI_RUN_ATTEMPT=self.summary["runAttempt"],
                   SIMCTL_CHILD_DESERT_CI_VERSION=self.summary["version"])
        output = self.simctl(name, "launch", "--terminate-running-process", self.device["udid"], self.bundle,
                             cap=120, env=env)
        matches = re.findall(rf"^{re.escape(self.bundle)}:\s*(\d+)\s*$", output, re.MULTILINE)
        if len(matches) != 1 or not alive(int(matches[0])):
            raise ProbeFailure(f"{name} did not return one live app PID")
        return int(matches[0])

    def collect_hud_contract(self, pid):
        output = self.simctl("hud-contract-container", "get_app_container", self.device["udid"], self.bundle, "data", cap=15)
        with self.stage("hud-contract-read-and-validate"):
            self.remaining()
            paths = [line.strip() for line in output.splitlines() if line.strip().startswith("/")]
            if len(paths) != 1:
                raise ProbeFailure("Expected exactly one app data container path")
            container = paths[0]
            source = Path(container) / "Documents" / "hud-layout-contract.json"
            if not Path(container).is_absolute() or not 0 < source.stat().st_size <= 1_048_576:
                raise ProbeFailure("HUD contract not produced by prewarm or too large")
            data = source.read_bytes()
            (self.directory / "hud-layout-contract.json").write_bytes(data)
            self.summary["hudContract"] = {"path": "hud-layout-contract.json", "pid": pid,
                                           "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest(), "status": "collected"}
            try:
                report = validate_hud_contract(self.summary, self.directory)
                self.summary["hudContract"].update(status="success", cases=len(report["matrix"]), actualSize=report["actualSize"],
                                                    actualInsets=report["actualInsets"])
                self.remaining()
            except BaseException as error:
                self.summary["hudContract"].update(status="failure", error=str(error))
                raise
            finally:
                self.save()

    def normalize_screenshot(self, name, path, record):
        with self.stage(f"{name}:png-check"):
            record["rawImage"] = png_info(path)
            record["normalizationPolicy"] = NORMALIZATION_POLICY
            width, height = record["rawImage"]["width"], record["rawImage"]["height"]
            if width == height:
                raise ProbeFailure("Square screenshot cannot establish landscape normalization")
            record["rotationDegrees"] = 270 if height > width else 0
        if record["rotationDegrees"]:
            # This policy follows reviewed hosted captures; C still checks actual UI direction.
            self.command(f"{name}:landscape", ["/usr/bin/sips", "--rotate", "270", str(path)], cap=30)
        with self.stage(f"{name}:normalized-image-check"):
            record["image"] = png_info(path)
            validate_normalization(record)
            self.remaining()

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
            self.normalize_screenshot(f"probe:{definition['id']}", path, record)
            with self.stage(f"probe:{definition['id']}:pid-image-check"):
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
        try:
            self.collect_hud_contract(record["pid"])
        except Exception as error:
            if getattr(error, "code", 1) >= 128:
                raise
            self.summary.setdefault("hudContract", {}).update(status="failure", error=str(error))
            print(f"[hud-contract] FAILURE retained for final gate: {error}", flush=True)
            self.save()
            self.remaining()
            # Keep the original captures useful for review even when the contract is red.
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
