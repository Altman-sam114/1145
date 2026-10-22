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
import uuid
import zlib

from run_bounded import run_bounded
from scene_evidence import (file_evidence, latest_ready, read_hud_report, seal_scene, trace_records,
                            validate_page_images, validate_scene)


NORMALIZATION_POLICY = "hosted-portrait-270-native-landscape-0-v1"
HUD_CHECKS = {"controls", "containers", "bands", "routing", "pending", "pageState", "roundTrip", "labels", "rebuild"}
HUD_FIXTURES = {"667x375": (667, 375), "852x393": (852, 393), "874x402": (874, 402),
                "1024x768": (1024, 768), "1366x1024": (1366, 1024)}
HUD_PAGES = {"tactical", "build", "air", "naval", "support"}
INSTALL_CAP = 180
INSTALL_RECOVERY_CAP = 60
INSTALL_COMMAND_RESERVE = 180
INSTALL_PREWARM_RESERVE = 95
INSTALL_CLEANUP_RESERVE = 2
INSTALL_POLICY = "same-device-install-180-once-v1"
BOOT_POLICY = "same-device-boot-continuation-v1"
BOOT_OUTPUT_LIMIT = 1024 * 1024


class ProbeFailure(Exception):
    def __init__(self, message, code=1, diagnostic=""):
        super().__init__(message)
        self.code = code
        self.diagnostic = diagnostic


class SceneFailure(ProbeFailure):
    pass


def validate_scene_evidence(probes, summary, directory):
    try:
        warm = [record for record in summary.get("prewarm", []) if record.get("status") == "success"]
        if len(warm) != 1:
            raise ValueError("One successful prewarm scene required")
        records = summary.get("probes", [])
        if len(probes) != 24 or len(records) != 24:
            raise ValueError("Scene readiness requires exactly the original 24 probe records")
        launches = summary.get("prewarm", []) + records
        nonces = [record.get("scene", {}).get("nonce") for record in launches]
        if any(not nonce for nonce in nonces) or len(set(nonces)) != len(nonces):
            raise ValueError("Every launch must have a distinct nonce")
        validate_scene(summary, warm[0], directory, probes[0], f"prewarm:{warm[0]['attempt']}")
        for definition, record in zip(probes, records):
            validate_scene(summary, record, directory, definition, f"probe:{definition['id']}")
        validate_page_images(records)
    except (ValueError, KeyError, OSError, TypeError) as error:
        raise SceneFailure(str(error)) from error


def cli_receipt_complete(receipt):
    def number(value):
        return type(value) in (int, float) and math.isfinite(value) and value >= 0

    if (receipt.get("schemaVersion") != 1 or receipt.get("scope") != "owned-cli-process-group-only"
            or type(receipt.get("pid")) is not int or receipt["pid"] <= 0 or receipt.get("pgid") != receipt["pid"]
            or receipt.get("reaped") is not True or type(receipt.get("returnCode")) is not int
            or type(receipt.get("exitCode")) is not int
            or not number(receipt.get("limitSeconds")) or receipt["limitSeconds"] <= 0
            or not number(receipt.get("elapsedSeconds")) or not number(receipt.get("cleanupElapsedSeconds"))
            or receipt["cleanupElapsedSeconds"] > receipt["elapsedSeconds"]):
        return False
    if receipt.get("trigger") == "exit":
        code = receipt["returnCode"]
        return (receipt.get("exitCode") == (code if code >= 0 else 128 - code)
                and receipt.get("cleanupOutcome") == "not_needed" and receipt["cleanupElapsedSeconds"] == 0
                and all(receipt.get(key, {}).get("status") == "not_needed" for key in ("term", "kill")))
    return (receipt.get("trigger") in ("timeout", "cancelled", "exception")
            and (receipt["trigger"] != "timeout" or receipt["exitCode"] == 124)
            and receipt.get("cleanupOutcome") == "success"
            and all(receipt.get(key, {}).get("status") in ("sent", "already_gone") for key in ("term", "kill")))


def install_retry_reason(code, diagnostic, receipt):
    if type(code) is not int:
        return False, "invalid_exit_code"
    if code >= 128:
        return False, "cancelled_or_signal"
    if not cli_receipt_complete(receipt) or receipt.get("exitCode") != code:
        return False, "cli_cleanup_unconfirmed"
    text = diagnostic.lower()
    if any(token in text for token in ("no such file", "invalid bundle", "not a valid bundle", "signature",
                                       "unsupported architecture", "invalid argument", "failed to verify")):
        return False, "permanent_diagnostic"
    if code == 124 and receipt.get("trigger") == "timeout":
        return True, "watchdog_timeout"
    for token, reason in (("device or resource busy", "transient_busy"), ("device is busy", "transient_busy"),
                          ("resource temporarily unavailable", "transient_unavailable"),
                          ("connection interrupted", "transient_connection")):
        if token in text:
            return True, reason
    return False, "permanent_or_unknown"


def install_reserve(probes):
    return INSTALL_PREWARM_RESERVE + sum(probe["wait"] for probe in probes) + INSTALL_COMMAND_RESERVE


def boot_reserve(probes):
    return INSTALL_CAP + INSTALL_CLEANUP_RESERVE + install_reserve(probes)


def boot_monitor_semantics(text):
    # Accept documented option semantics, not a version-specific copy of the whole help.
    normalized = " ".join(text.split())
    monitor = re.search(r"Monitor the boot status of a device\.", normalized)
    option = re.search(r"(?:^|\s)-b\s+(Boot the device if it (?:isn't|is not) (?:already )?booted\.|"
                       r"If the device (?:isn't|is not) (?:already )?booted, boot it\.)", normalized)
    if (not monitor or not option or not re.search(r"Usage: simctl bootstatus <device> \[-b\]", normalized)
            or re.search(r"\b(error|failed|unsupported)\b|(?:by default|without -b)[^.]*\bboot(?:s|ing)? the device", normalized, re.I)):
        raise ProbeFailure("bootstatus help does not explicitly support monitoring without auto-boot")
    return {"monitorOnlyWithoutOption": True, "autoBootOption": "-b",
            "monitorDescription": monitor.group(0), "optionDescription": option.group(1)}


def boot_normal_exit(record, code=None):
    process = record.get("process", {})
    actual = record.get("exitCode")
    return (type(actual) is int and actual >= 0 and (code is None or actual == code)
            and cli_receipt_complete(process) and process.get("trigger") == "exit"
            and process.get("returnCode") == actual and process.get("exitCode") == actual)


def boot_initial_reason(record, text):
    if not boot_normal_exit(record):
        return "cli_exit_or_cleanup_unconfirmed"
    if record["exitCode"] == 0:
        return "booted"
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    allowed_header = "An error was encountered processing the command (domain=com.apple.CoreSimulator.SimError, code=405):"
    if lines in (["Unable to boot device in current state: Booted"],
                 [allowed_header, "Unable to boot device in current state: Booted"]):
        return "already_booted"
    return "permanent_or_unknown_boot_error"


def boot_wait_classification(record, text, udid):
    result = {"eligible": False, "reason": "not_watchdog_timeout"}
    process = record.get("process", {})
    if (not cli_receipt_complete(process) or process.get("exitCode") != record.get("exitCode")):
        return dict(result, reason="cli_cleanup_unconfirmed")
    if record.get("exitCode") != 124 or process.get("trigger") != "timeout":
        return result
    if re.search(r"\b(error|failed|failure|fatal|exception|invalid|unavailable)\b|permission denied|unable to", text, re.I):
        return dict(result, reason="permanent_or_unknown_diagnostic")
    if (not text.endswith("\n") or "\ufffd" in text or "\x00" in text
            or len(re.findall(rf"(?m)^Monitoring boot status for [^\r\n]+ \({re.escape(udid)}\)\.$", text)) != 1):
        return dict(result, reason="unknown_or_incomplete_boot_output")
    statuses = list(re.finditer(r"(?m)^\[[^\]\r\n]+\] Status=(\d+), isTerminal=(YES|NO), Elapsed=([\d:]+)\.\s*$", text))
    if not statuses or len(statuses) != text.count("Status="):
        return dict(result, reason="unknown_or_incomplete_boot_status")
    last = statuses[-1]
    result.update(lastStatus=int(last.group(1)), isTerminal=last.group(2) == "YES", elapsed=last.group(3))
    tail = [line.strip() for line in text[last.end():].splitlines() if line.strip()]
    if result["isTerminal"]:
        return dict(result, reason="terminal_without_successful_exit")
    if result["lastStatus"] == 2 and len(tail) == 3 and tail[0] == "Waiting on Data Migration":
        migration = re.fullmatch(r"Migration Elapsed:([\d:]+) seconds", tail[2])
        if tail[1].startswith("Reason:") and tail[1][len("Reason:"):].strip() and migration:
            return dict(result, eligible=True, reason="data_migration_wait", waitReason=tail[1][len("Reason:"):],
                        migrationElapsed=migration.group(1))
    if result["lastStatus"] == 4 and tail == ["Waiting on System App"]:
        return dict(result, eligible=True, reason="system_app_wait", waitReason=tail[0])
    return dict(result, reason="unknown_or_incomplete_last_wait")


def boot_selected_state(text, device):
    runtime = device["runtime"]["identifier"]
    payload = json.loads(text)
    devices = payload.get("devices") if isinstance(payload, dict) else None
    entries = devices.get(runtime) if isinstance(devices, dict) else None
    if not isinstance(entries, list) or any(not isinstance(entry, dict) for entry in entries):
        raise ProbeFailure("Fresh device JSON has no valid selected-runtime device list")
    matches = [entry for entry in entries if entry.get("udid") == device["udid"]]
    if (len(matches) != 1 or matches[0].get("isAvailable") is not True or matches[0].get("state") != "Booted"
            or matches[0].get("dataPath") != device.get("dataPath") or not device.get("dataPath")):
        raise ProbeFailure("Fresh selected-device state is missing, ambiguous, changed or not Booted")
    return {"runtimeIdentifier": runtime, **{key: matches[0][key] for key in ("udid", "dataPath", "state", "isAvailable")}}


def boot_output(record, directory):
    evidence = record.get("output", {})
    path = evidence.get("path")
    if (not isinstance(path, str) or Path(path).name != path or type(evidence.get("bytes")) is not int
            or evidence["bytes"] < 0 or not re.fullmatch(r"[0-9a-f]{64}", evidence.get("sha256", ""))):
        raise ProbeFailure("Boot command output basename missing/invalid")
    source = directory / path
    if source.is_symlink() or not source.is_file() or source.stat().st_size > BOOT_OUTPUT_LIMIT:
        raise ProbeFailure("Boot command output missing, symlink or oversized")
    data = source.read_bytes()
    if len(data) != evidence.get("bytes") or hashlib.sha256(data).hexdigest() != evidence.get("sha256"):
        raise ProbeFailure("Boot command output evidence mismatch")
    return data.decode("utf-8", errors="strict")


def validate_boot(summary, probes, directory):
    evidence = summary.get("boot", {})
    device = summary.get("selectedDevice", {})
    identity = {key: summary.get(key) for key in ("branch", "commitSha", "runId", "runAttempt", "version")}
    reserve = boot_reserve(probes)
    selected = {"udid": device.get("udid"), "runtimeIdentifier": device.get("runtime", {}).get("identifier"),
                "dataPath": device.get("dataPath")}
    if (evidence.get("schemaVersion") != 1 or evidence.get("policy") != BOOT_POLICY or evidence.get("status") != "success"
            or not all(identity.values()) or evidence.get("identity") != identity or not all(selected.values())
            or evidence.get("selectedDevice") != selected or evidence.get("deadlineAfterSeconds") != summary.get("workBudgetSeconds")):
        raise ProbeFailure("Successful current-run same-device boot evidence missing/invalid")
    commands = evidence.get("commands", [])
    roles = [record.get("role") for record in commands]
    if roles not in (["help", "initial", "wait:1"], ["help", "initial", "wait:1", "state", "wait:2"]):
        raise ProbeFailure("Boot command order/count is invalid")
    if evidence.get("admissions") != [record.get("admission") for record in commands]:
        raise ProbeFailure("Boot admission chronology mismatch")
    boot_stages = [stage for stage in summary.get("stages", []) if stage.get("name", "").startswith("boot")]
    expected_stages = [name for role in roles for name in (f"boot-admission:{role}", f"boot-{role}")]
    if [stage.get("name") for stage in boot_stages] != expected_stages:
        raise ProbeFailure("Unexpected boot/shutdown stage or missing boot stage evidence")

    def number(value):
        return type(value) in (int, float) and math.isfinite(value) and value >= 0

    previous = None
    texts = {}
    for index, record in enumerate(commands):
        role = record["role"]
        cap = 10 if role in ("help", "state") else 60 if role == "initial" else 240
        args = (["help", "bootstatus"] if role == "help" else ["boot", device["udid"]] if role == "initial" else
                ["list", "devices", "--json"] if role == "state" else ["bootstatus", device["udid"]])
        admission = record.get("admission", {})
        process = record.get("process", {})
        if (record.get("argv") != ["/usr/bin/xcrun", "simctl", *args]
                or record.get("requestedCapSeconds") != cap or admission.get("requestedCapSeconds") != cap
                or admission.get("phase") != f"boot-admission:{role}" or admission.get("allowed") is not True
                or admission.get("installReserveSeconds") != reserve or admission.get("cliCleanupReserveSeconds") != 2
                or not number(admission.get("remainingSeconds")) or not number(admission.get("maxCapSeconds"))
                or admission["maxCapSeconds"] <= 0
                or abs(admission["maxCapSeconds"] - min(cap, admission["remainingSeconds"] - reserve - 2)) > 0.01
                or not all(number(record.get(key)) for key in ("startedAfterSeconds", "endedAfterSeconds", "elapsedSeconds",
                           "remainingStartSeconds", "remainingEndSeconds", "effectiveCapSeconds"))
                or record["remainingStartSeconds"] > admission["remainingSeconds"] + 0.01
                or record["remainingEndSeconds"] < reserve or record["effectiveCapSeconds"] <= 0
                or record["effectiveCapSeconds"] > min(cap, record["remainingStartSeconds"] - reserve - 2) + 0.01
                or record["effectiveCapSeconds"] != process.get("limitSeconds") or not cli_receipt_complete(process)
                or process.get("exitCode") != record.get("exitCode")
                or record.get("status") != ("success" if record.get("exitCode") == 0 else "failure")
                or abs(record["endedAfterSeconds"] - record["startedAfterSeconds"] - record["elapsedSeconds"]) > 0.01
                or abs(record["remainingStartSeconds"] - record["remainingEndSeconds"] - record["elapsedSeconds"]) > 0.01
                or abs(record["remainingStartSeconds"] + record["startedAfterSeconds"] - evidence["deadlineAfterSeconds"]) > 0.01
                or abs(record["remainingEndSeconds"] + record["endedAfterSeconds"] - evidence["deadlineAfterSeconds"]) > 0.01
                or process["elapsedSeconds"] > record["elapsedSeconds"] + 0.01
                or (previous is not None and (record["startedAfterSeconds"] < previous["endedAfterSeconds"]
                    or admission["remainingSeconds"] > previous["remainingEndSeconds"] + 0.01))):
            raise ProbeFailure(f"Boot command/receipt/deadline evidence inconsistent: {role}")
        if (boot_stages[index * 2].get("status") != "success" or boot_stages[index * 2 + 1].get("status") != record["status"]
                or boot_stages[index * 2 + 1].get("exitCode") != record["exitCode"]
                or record.get("output", {}).get("path") != f"boot-{role.replace(':', '-')}.log"):
            raise ProbeFailure(f"Boot stage/output identity mismatch: {role}")
        texts[role] = boot_output(record, directory)
        previous = record
    if not boot_normal_exit(commands[0], 0) or evidence.get("monitorSemantics") != boot_monitor_semantics(texts["help"]):
        raise ProbeFailure("Boot monitor-only help evidence invalid")
    reason = boot_initial_reason(commands[1], texts["initial"])
    if reason not in ("booted", "already_booted") or commands[1].get("classification") != reason:
        raise ProbeFailure("Initial boot was not successful or exactly already Booted")
    if not boot_normal_exit(commands[-1], 0) or commands[-1].get("classification") != "ready":
        raise ProbeFailure("Final bootstatus did not normally exit0")
    if len(commands) == 5:
        first, state = commands[2:4]
        classification = boot_wait_classification(first, texts["wait:1"], device["udid"])
        if (not classification["eligible"] or first.get("classification") != classification
                or first.get("continuationDecision") != "continue" or not boot_normal_exit(state, 0)
                or state.get("selectedState") != boot_selected_state(texts["state"], device)
                or commands[-1].get("continuationDecision") != "completed"):
            raise ProbeFailure("Boot continuation timeout/fresh-state chain invalid")
    elif commands[-1].get("continuationDecision") != "not_needed":
        raise ProbeFailure("Unexpected boot continuation decision on first success")
    return evidence


def validate_installation(summary, probes, directory=None):
    evidence = summary.get("installation", {})
    product = summary.get("appProduct", {})
    udid = summary.get("selectedDevice", {}).get("udid")
    attempts = evidence.get("attempts", [])
    reserve = install_reserve(probes)
    required = INSTALL_CAP + INSTALL_CLEANUP_RESERVE + reserve

    def number(value):
        return type(value) in (int, float) and math.isfinite(value) and value >= 0

    def admission(record, minimum, phase):
        return (record.get("allowed") is True and record.get("requiredSeconds") == minimum
                and record.get("phase") == phase
                and record.get("postInstallReserveSeconds") == reserve
                and number(record.get("remainingSeconds")) and record["remainingSeconds"] >= minimum)

    def command(record, cap):
        process = record.get("process", {})
        output = record.get("output", {})
        if (record.get("udid") != udid or record.get("requestedCapSeconds") != cap
                or not number(record.get("effectiveCapSeconds")) or not 0 < record["effectiveCapSeconds"] <= cap
                or process.get("limitSeconds") != record["effectiveCapSeconds"]
                or not cli_receipt_complete(process) or process.get("exitCode") != record.get("exitCode")
                or not all(number(record.get(key)) for key in ("elapsedSeconds", "remainingStartSeconds", "remainingEndSeconds"))
                or record["remainingEndSeconds"] > record["remainingStartSeconds"]
                or record["remainingEndSeconds"] < reserve
                or record["effectiveCapSeconds"] > record["remainingStartSeconds"] - INSTALL_CLEANUP_RESERVE + 0.01
                or abs(record["remainingStartSeconds"] - record["remainingEndSeconds"] - record["elapsedSeconds"]) > 0.01
                or process["elapsedSeconds"] > record["elapsedSeconds"] + 0.01
                or record["remainingStartSeconds"] > record.get("admission", {}).get("remainingSeconds", -1)
                or not isinstance(output.get("path"), str) or Path(output["path"]).name != output["path"]
                or type(output.get("bytes")) is not int or output["bytes"] < 0
                or not re.fullmatch(r"[0-9a-f]{64}", output.get("sha256", ""))):
            raise ProbeFailure("Install command/CLI receipt is incomplete or inconsistent")
        if directory is not None:
            data = (directory / output["path"]).read_bytes()
            if len(data) != output["bytes"] or hashlib.sha256(data).hexdigest() != output["sha256"]:
                raise ProbeFailure("Install command output evidence mismatch")

    if (evidence.get("schemaVersion") != 1 or evidence.get("policy") != INSTALL_POLICY
            or evidence.get("status") != "success" or not udid or evidence.get("udid") != udid
            or not product.get("bundleId") or not product.get("path")
            or evidence.get("bundleId") != product["bundleId"] or evidence.get("appPath") != product["path"]
            or not 1 <= len(attempts) <= 2):
        raise ProbeFailure("Successful same-device installation evidence missing/invalid")
    for index, attempt in enumerate(attempts):
        command(attempt, INSTALL_CAP)
        if (attempt.get("attempt") != index + 1 or attempt.get("bundleId") != product["bundleId"]
                or attempt.get("appPath") != product["path"]
                or not admission(attempt.get("admission", {}), required, f"install-admission:{index + 1}")
                or attempt["output"]["path"] != f"install-attempt-{index + 1}.log"):
            raise ProbeFailure("Install attempt identity/order/admission mismatch")
        if index == len(attempts) - 1:
            if (attempt.get("status") != "success" or attempt.get("exitCode") != 0
                    or attempt["process"].get("trigger") != "exit" or attempt["process"].get("returnCode") != 0
                    or attempt.get("retryable") is not False or attempt.get("retryReason") != "installed"):
                raise ProbeFailure("Final install attempt did not successfully exit")
        else:
            retryable, reason = install_retry_reason(attempt.get("exitCode", 1), attempt.get("diagnostic", ""), attempt["process"])
            if (attempt.get("status") != "failure" or not retryable or attempt.get("retryable") is not True
                    or attempt.get("retryReason") != reason or attempt.get("retryDecision") != "retry"):
                raise ProbeFailure("Install retry was not eligible")
    recovery = evidence.get("recovery")
    if len(attempts) == 2:
        if (not recovery or recovery.get("status") != "success" or recovery.get("exitCode") != 0
                or recovery.get("process", {}).get("trigger") != "exit"
                or recovery.get("process", {}).get("returnCode") != 0
                or not admission(recovery.get("admission", {}), required + INSTALL_RECOVERY_CAP, "install-recovery-admission")):
            raise ProbeFailure("Bounded same-device install recovery missing")
        command(recovery, INSTALL_RECOVERY_CAP)
        if recovery["output"]["path"] != "install-recovery.log":
            raise ProbeFailure("Install recovery output path mismatch")
    elif recovery is not None:
        raise ProbeFailure("Unexpected install recovery without a retry")
    admissions = [attempts[0]["admission"]]
    if recovery is not None:
        admissions += [recovery["admission"], attempts[1]["admission"]]
    if evidence.get("admissions") != admissions:
        raise ProbeFailure("Install admission chronology mismatch")
    commands = [attempts[0], recovery, attempts[1]] if recovery is not None else attempts
    if any(current["admission"]["remainingSeconds"] > previous["remainingEndSeconds"]
           for previous, current in zip(commands, commands[1:])):
        raise ProbeFailure("Install shared deadline advanced backwards")
    return evidence


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
    producer = next(item for item in summary["prewarm"] if item.get("pid") == report["pid"])
    if any(not producer.get("scene", {}).get(key) or report.get(key) != producer["scene"][key] for key in ("nonce", "probeID")):
        raise ProbeFailure("HUD contract nonce/probe does not match the live prewarm")
    descriptor = producer.get("scene", {}).get("ready", {}).get("hudReport", {})
    if any(descriptor.get(key) != evidence.get(key) for key in ("bytes", "sha256")):
        raise ProbeFailure("HUD artifact differs from the direct prewarm report descriptor")
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
    validate_boot(summary, probes, directory)
    validate_installation(summary, probes, directory)
    validate_scene_evidence(probes, summary, directory)
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
    return {"udid": device["udid"], "name": device["name"], "runtime": runtime, "dataPath": device.get("dataPath"),
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

    def command(self, name, command, cap=60, env=None, log=None, receipt=None, reserve=0, raw_log=False):
        with self.stage(name):
            # Reserve group TERM/KILL/reap time inside the shared stage budget.
            seconds = min(cap, self.remaining(reserve + 2) - reserve - 2)
            with tempfile.TemporaryFile() as output:
                try:
                    arguments = {"stdout": output, "env": env}
                    if receipt is not None:
                        arguments["receipt"] = receipt
                    code = run_bounded(command, seconds, **arguments)
                finally:
                    output.seek(0)
                    data = output.read()
                    text = data.decode("utf-8", errors="replace")
                    if log:
                        if raw_log:
                            (self.directory / log).write_bytes(data)
                        else:
                            (self.directory / log).write_text(text)
                    print(text, end="" if text.endswith("\n") else "\n", flush=True)
            if code:
                raise ProbeFailure(f"{name} exited {code}", code, diagnostic=text)
            return text

    def simctl(self, name, *arguments, cap=60, **kwargs):
        return self.command(name, ["/usr/bin/xcrun", "simctl", *arguments], cap=cap, **kwargs)

    def _boot_command(self, role, arguments, cap):
        evidence = self.summary["boot"]
        reserve = boot_reserve(self.probes)
        phase = f"boot-admission:{role}"
        with self.stage(phase):
            remaining = self.deadline - time.monotonic()
            maximum = min(cap, remaining - reserve - 2)
            admission = dict(phase=phase, remainingSeconds=round(remaining, 6), requestedCapSeconds=cap,
                             maxCapSeconds=round(max(maximum, 0), 6), installReserveSeconds=reserve,
                             cliCleanupReserveSeconds=2, allowed=maximum > 0)
            evidence["admissions"].append(admission)
            if not admission["allowed"]:
                raise ProbeFailure(f"boot budget_insufficient at {role}: remaining={remaining:.3f}s reserve={reserve}+2s", 124)
        started = time.monotonic()
        record = dict(role=role, argv=["/usr/bin/xcrun", "simctl", *arguments], status="running", admission=admission,
                      requestedCapSeconds=cap, startedAfterSeconds=round(started - self.started, 6),
                      remainingStartSeconds=round(self.deadline - started, 6), process={})
        evidence["commands"].append(record)
        log = f"boot-{role.replace(':', '-')}.log"
        try:
            self.simctl(f"boot-{role}", *arguments, cap=cap, log=log, receipt=record["process"], reserve=reserve, raw_log=True)
            record.update(status="success", exitCode=0)
        except BaseException as error:
            process = record["process"]
            code = getattr(error, "code", 130 if isinstance(error, KeyboardInterrupt) else 1)
            return_code = process.get("returnCode")
            cancelled = (isinstance(error, KeyboardInterrupt) or process.get("trigger") in ("cancelled", "exception")
                         or (process.get("trigger") == "exit" and type(return_code) is int and return_code < 0)
                         or (process.get("trigger") != "exit" and type(code) is int and code >= 128))
            record.update(status="cancelled" if cancelled else "failure", error=str(error),
                          exitCode=code)
            if cancelled or not isinstance(error, ProbeFailure):
                raise
        finally:
            ended = time.monotonic()
            record.update(endedAfterSeconds=round(ended - self.started, 6), elapsedSeconds=round(ended - started, 6),
                          remainingEndSeconds=round(self.deadline - ended, 6),
                          effectiveCapSeconds=record["process"].get("limitSeconds"))
            path = self.directory / log
            if path.exists():
                data = path.read_bytes()
                record["output"] = {"path": log, "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}
            print(f"[boot] {role} status={record['status']} exit={record.get('exitCode')} elapsed={record['elapsedSeconds']}s "
                  f"cap={record['effectiveCapSeconds']}s remaining={record['remainingEndSeconds']}s", flush=True)
            self.save()
        return record

    def boot_device(self):
        device = self.device
        evidence = dict(schemaVersion=1, policy=BOOT_POLICY, status="running", commands=[], admissions=[],
                        identity={key: self.summary[key] for key in ("branch", "commitSha", "runId", "runAttempt", "version")},
                        selectedDevice={"udid": device["udid"], "runtimeIdentifier": device["runtime"]["identifier"],
                                        "dataPath": device["dataPath"]},
                        deadlineAfterSeconds=self.deadline - self.started)
        self.summary["boot"] = evidence
        try:
            help_record = self._boot_command("help", ["help", "bootstatus"], 10)
            if not boot_normal_exit(help_record, 0):
                raise ProbeFailure("bootstatus help did not normally exit0 with a complete CLI receipt")
            evidence["monitorSemantics"] = boot_monitor_semantics(boot_output(help_record, self.directory))
            initial = self._boot_command("initial", ["boot", device["udid"]], 60)
            initial["classification"] = boot_initial_reason(initial, boot_output(initial, self.directory))
            if initial["classification"] not in ("booted", "already_booted"):
                raise ProbeFailure(f"Initial boot rejected: {initial['classification']}", initial.get("exitCode") or 1)
            for number in (1, 2):
                record = self._boot_command(f"wait:{number}", ["bootstatus", device["udid"]], 240)
                if boot_normal_exit(record, 0):
                    record.update(classification="ready", continuationDecision="not_needed" if number == 1 else "completed")
                    evidence["status"] = "success"
                    return
                classification = boot_wait_classification(record, boot_output(record, self.directory), device["udid"])
                record.update(classification=classification, continuationDecision="attempt_limit" if number == 2 else "not_eligible")
                if number == 2 or not classification["eligible"]:
                    raise ProbeFailure(f"bootstatus {number} rejected: {classification['reason']}", record.get("exitCode") or 1)
                record["continuationDecision"] = "checking_state"
                state = self._boot_command("state", ["list", "devices", "--json"], 10)
                if not boot_normal_exit(state, 0):
                    record["continuationDecision"] = "state_failed"
                    raise ProbeFailure("Fresh selected-device state command failed", state.get("exitCode") or 1)
                try:
                    state["selectedState"] = boot_selected_state(boot_output(state, self.directory), device)
                except (ValueError, KeyError, TypeError, ProbeFailure) as error:
                    record["continuationDecision"] = "state_failed"
                    raise ProbeFailure(f"Fresh selected-device state rejected: {error}") from error
                record["continuationDecision"] = "continue"
        except BaseException as error:
            code = getattr(error, "code", 130 if isinstance(error, KeyboardInterrupt) else 1)
            cancelled = (isinstance(error, KeyboardInterrupt)
                         or any(record.get("status") == "cancelled" for record in evidence["commands"])
                         or (type(code) is int and code >= 128 and (not evidence["commands"]
                             or not boot_normal_exit(evidence["commands"][-1], code))))
            evidence.update(status="cancelled" if cancelled else "failure", stopReason=str(error),
                            lastStage=self.summary["currentStage"])
            raise
        finally:
            evidence["lastStage"] = self.summary["currentStage"]
            self.save()

    def _install_admission(self, phase, recovery=False):
        with self.stage(phase):
            reserve = install_reserve(self.probes)
            required = INSTALL_CAP + INSTALL_CLEANUP_RESERVE + reserve + (INSTALL_RECOVERY_CAP if recovery else 0)
            remaining = self.deadline - time.monotonic()
            record = {"phase": phase, "requiredSeconds": required, "remainingSeconds": round(remaining, 6),
                      "postInstallReserveSeconds": reserve, "allowed": remaining >= required}
            self.summary["installation"]["admissions"].append(record)
            print(f"[install] admission {phase}; required={required}s remaining={remaining:.3f}s allowed={record['allowed']}", flush=True)
            if not record["allowed"]:
                raise ProbeFailure(f"install budget_insufficient at {phase}: required={required}s remaining={remaining:.3f}s", 124)
            return record

    def _install_command(self, record, name, arguments, cap, log):
        started = time.monotonic()
        record.update(status="running", udid=self.device["udid"], requestedCapSeconds=cap,
                      remainingStartSeconds=round(self.deadline - started, 6), process={})
        try:
            self.simctl(name, *arguments, cap=cap, log=log, receipt=record["process"])
            if (not cli_receipt_complete(record["process"]) or record["process"].get("exitCode") != 0
                    or record["process"].get("trigger") != "exit" or record["process"].get("returnCode") != 0):
                raise ProbeFailure(f"{name} returned without a complete normal exit0 CLI receipt")
            record.update(status="success", exitCode=0)
        except BaseException as error:
            code = getattr(error, "code", 130 if isinstance(error, KeyboardInterrupt) else 1)
            record.update(status="cancelled" if isinstance(code, int) and code >= 128 else "failure",
                          exitCode=code, error=str(error), diagnostic=getattr(error, "diagnostic", ""))
            raise
        finally:
            record.update(elapsedSeconds=round(time.monotonic() - started, 6),
                          remainingEndSeconds=round(self.deadline - time.monotonic(), 6),
                          effectiveCapSeconds=record["process"].get("limitSeconds"))
            path = self.directory / log
            if path.exists():
                data = path.read_bytes()
                record["output"] = {"path": log, "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}
            print(f"[install] {name} status={record['status']} exit={record.get('exitCode')} elapsed={record['elapsedSeconds']}s "
                  f"cap={record['effectiveCapSeconds']}s remaining={record['remainingEndSeconds']}s", flush=True)
            self.save()

    def install_app(self, app):
        evidence = {"schemaVersion": 1, "policy": INSTALL_POLICY, "status": "running", "udid": self.device["udid"],
                    "bundleId": self.bundle, "appPath": str(app), "attempts": [], "admissions": []}
        self.summary["installation"] = evidence
        try:
            for number in (1, 2):
                try:
                    admission = self._install_admission(f"install-admission:{number}")
                except ProbeFailure:
                    if evidence["attempts"]:
                        evidence["attempts"][-1]["retryDecision"] = "budget_insufficient"
                    raise
                record = {"attempt": number, "bundleId": self.bundle, "appPath": str(app), "admission": admission}
                evidence["attempts"].append(record)
                try:
                    self._install_command(record, f"install:{number}", ["install", self.device["udid"], str(app)],
                                          INSTALL_CAP, f"install-attempt-{number}.log")
                except BaseException as error:
                    code = record.get("exitCode", 1)
                    retryable, reason = install_retry_reason(code, record.get("diagnostic", ""), record["process"])
                    record.update(retryable=retryable, retryReason=reason, retryDecision="not_retryable")
                    if code >= 128 or not retryable:
                        raise
                    if number == 2:
                        record["retryDecision"] = "attempt_limit"
                        raise
                    try:
                        recovery_admission = self._install_admission("install-recovery-admission", recovery=True)
                    except ProbeFailure:
                        record["retryDecision"] = "budget_insufficient"
                        raise
                    recovery = {"admission": recovery_admission}
                    evidence["recovery"] = recovery
                    record["retryDecision"] = "recovering"
                    try:
                        self._install_command(recovery, "install-retry-ready", ["bootstatus", self.device["udid"], "-b"],
                                              INSTALL_RECOVERY_CAP, "install-recovery.log")
                    except BaseException:
                        record["retryDecision"] = "recovery_failed"
                        raise
                    record["retryDecision"] = "retry"
                    continue
                record.update(retryable=False, retryReason="installed", retryDecision="not_needed")
                self.remaining(install_reserve(self.probes))
                evidence["status"] = "success"
                return
        except BaseException as error:
            code = getattr(error, "code", 130 if isinstance(error, KeyboardInterrupt) else 1)
            evidence.update(status="cancelled" if isinstance(code, int) and code >= 128 else "failure", stopReason=str(error))
            raise
        finally:
            self.save()

    def wait(self, name, seconds):
        with self.stage(name):
            self.remaining(seconds)
            end = time.monotonic() + seconds
            while time.monotonic() < end:
                time.sleep(min(30, end - time.monotonic()))
                self.remaining()
                print(f"[heartbeat] {name}; wait remaining={max(end-time.monotonic(), 0):.1f}s", flush=True)

    def launch(self, name, definition):
        nonce = uuid.uuid4().hex
        probe_id = name.removesuffix(":launch")
        self.last_scene = {"nonce": nonce, "probeID": probe_id, "status": "running"}
        for channel in ("stdout", "stderr"):
            path = self.directory / f"scene-{nonce}-{channel}.live.log"
            path.write_bytes(b"")
            self.last_scene[channel] = {"path": path.name}
        env = dict(os.environ)
        env.update(SIMCTL_CHILD_DESERT_CI_CAPTURE_MODE="1",
                   SIMCTL_CHILD_DESERT_CI_HUD_PAGE=definition["page"],
                   SIMCTL_CHILD_DESERT_CI_COMMAND_MARKER=definition["marker"],
                   SIMCTL_CHILD_DESERT_CI_CAMERA_FOCUS=definition["focus"],
                   SIMCTL_CHILD_DESERT_CI_HUD_CONTRACT="1" if name.startswith("prewarm:") else "0",
                   SIMCTL_CHILD_DESERT_CI_NONCE=nonce, SIMCTL_CHILD_DESERT_CI_PROBE_ID=probe_id,
                   SIMCTL_CHILD_DESERT_CI_DEVICE_UDID=self.device["udid"],
                   SIMCTL_CHILD_DESERT_CI_COMMIT_SHA=self.summary["commitSha"],
                   SIMCTL_CHILD_DESERT_CI_RUN_ID=self.summary["runId"],
                   SIMCTL_CHILD_DESERT_CI_RUN_ATTEMPT=self.summary["runAttempt"],
                   SIMCTL_CHILD_DESERT_CI_VERSION=self.summary["version"])
        try:
            output = self.simctl(name, "launch", "--terminate-running-process",
                                 f"--stdout={(self.directory / self.last_scene['stdout']['path']).resolve()}",
                                 f"--stderr={(self.directory / self.last_scene['stderr']['path']).resolve()}",
                                 self.device["udid"], self.bundle, cap=120, env=env)
        finally:
            for channel in ("stdout", "stderr"):
                self.last_scene[channel], _ = file_evidence(self.directory, self.last_scene[channel]["path"])
        matches = re.findall(rf"^{re.escape(self.bundle)}:\s*(\d+)\s*$", output, re.MULTILINE)
        if len(matches) != 1 or not alive(int(matches[0])):
            raise ProbeFailure(f"{name} did not return one live app PID")
        self.last_scene.update(pid=int(matches[0]), launchedAtMonotonic=time.monotonic())
        return int(matches[0])

    def wait_scene(self, record, definition, minimum, window=30):
        scene = record["scene"]
        end = scene["launchedAtMonotonic"] + window
        try:
            self.wait(f"scene:{definition['id']}:minimum-wait", minimum)
            with self.stage(f"scene:{definition['id']}:readiness"):
                while True:
                    self.remaining(2)
                    previous_stage = scene.get("lastStage")
                    records = trace_records(self.summary, scene, self.directory)
                    last = records[-1]["stage"] if records else "no-direct-beacon"
                    if previous_stage != last:
                        scene["lastStage"] = last
                        print(f"[scene] {scene['probeID']} nonce={scene['nonce']} last={last}", flush=True)
                        self.save()
                    ready = latest_ready(records, definition)
                    if ready is not None:
                        scene.update(status="success", ready=ready)
                        return
                    if time.monotonic() >= end:
                        raise ValueError(f"Scene readiness deadline; last={last}")
                    time.sleep(min(0.25, end - time.monotonic(), self.remaining(2) - 2))
        except (ValueError, KeyError, OSError, TypeError, ProbeFailure) as error:
            scene.update(status="failure", error=str(error))
            if isinstance(error, ProbeFailure):
                raise
            raise SceneFailure(str(error)) from error
        finally:
            self.save()

    def collect_hud_contract(self, pid):
        with self.stage("hud-contract-read-and-validate"):
            self.remaining()
            producer = next(item for item in self.summary["prewarm"] if item.get("pid") == pid)
            scene = producer["scene"]
            root = Path(self.device["dataPath"])
            if root.name != "data" or root.parent.name != self.device["udid"]:
                raise SceneFailure("Selected device dataPath is not bound to its UDID")
            data = read_hud_report(root, scene["ready"]["hudReport"], scene["nonce"], self.bundle)
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
            self.last_scene = None
            try:
                record["pid"] = self.launch(f"probe:{definition['id']}:launch", definition)
            finally:
                if self.last_scene is not None:
                    record["scene"] = self.last_scene
            record["aliveAfterLaunch"] = True
            self.save()
            self.wait_scene(record, definition, definition["wait"])
            path = self.directory / definition["png"]
            self.simctl(f"probe:{definition['id']}:screenshot", "io", self.device["udid"], "screenshot", str(path), cap=180)
            self.normalize_screenshot(f"probe:{definition['id']}", path, record)
            try:
                validate_page_images(self.summary["probes"])
                records = trace_records(self.summary, record["scene"], self.directory)
                ready = latest_ready(records, definition)
                if ready is None or ready != record["scene"]["ready"]:
                    raise ValueError("Scene geometry invalidated before screenshot completed")
            except ValueError as error:
                raise SceneFailure(str(error)) from error
            with self.stage(f"probe:{definition['id']}:pid-image-check"):
                record["aliveAfterScreenshot"] = alive(record["pid"])
                if not record["aliveAfterScreenshot"] or record["image"]["width"] <= record["image"]["height"]:
                    raise ProbeFailure("App exited after capture or PNG is not landscape")
                self.remaining()
                seal_scene(self.summary, record["scene"], self.directory, definition)
                record["scene"]["sealedAtMonotonic"] = time.monotonic()
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
            self.summary["appProduct"] = {"bundleId": self.bundle, "path": str(app)}
        sdk = self.command("simulator-sdk-version", ["/usr/bin/xcrun", "--sdk", "iphonesimulator", "--show-sdk-version"]).strip()
        runtimes = json.loads(self.simctl("installed-runtimes", "list", "runtimes", "--json", log="simulator-runtimes.json"))
        devices = json.loads(self.simctl("available-devices", "list", "devices", "available", "--json"))
        with self.stage("device-selection"):
            self.device = select_device(runtimes, devices, info["MinimumOSVersion"], sdk)
            self.summary["selectedDevice"] = self.device
            if not self.device.get("dataPath"):
                raise SceneFailure("Selected device has no authoritative dataPath")
            print(json.dumps(self.device, indent=2), flush=True)
        udid = self.device["udid"]
        self.boot_device()
        self.install_app(app)
        help_text = self.simctl("launch-output-options", "help", "launch", cap=10, log="simulator-launch-help.log")
        if not all(option in help_text for option in ("--stdout", "--stderr")):
            raise SceneFailure("This Xcode lacks supported launch stdout/stderr file redirection")
        for attempt in range(1, 4):
            if attempt > 1:
                self.remaining(120 + 95 + sum(p["wait"] for p in self.probes))
            record = {"attempt": attempt, "status": "running"}
            self.summary["prewarm"].append(record)
            try:
                self.last_scene = None
                try:
                    pid = self.launch(f"prewarm:{attempt}:launch", self.probes[0])
                finally:
                    if self.last_scene is not None:
                        record["scene"] = self.last_scene
                record.update(pid=pid, aliveAfterLaunch=True)
                self.wait_scene(record, self.probes[0], 90, window=90)
                record["aliveAfterWait"] = alive(pid)
                if not record["aliveAfterWait"]:
                    raise ProbeFailure("Prewarm PID exited before notification wait ended")
                record["status"] = "success"
                self.save()
                break
            except ProbeFailure as error:
                record.update(status="failure", error=str(error))
                self.save()
                if attempt == 3 or error.code >= 128 or isinstance(error, SceneFailure):
                    raise
                self.wait("prewarm-retry-wait", 20)
        self.collect_hud_contract(record["pid"])
        self.simctl("prewarm-terminate", "terminate", udid, self.bundle)
        with self.stage("prewarm-trace-snapshot"):
            self.remaining()
            seal_scene(self.summary, record["scene"], self.directory, self.probes[0])
            record["scene"]["sealedAtMonotonic"] = time.monotonic()
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
