#!/usr/bin/env python3
"""Verify original unit sprites in the checkout and the actual built app."""
import argparse
import binascii
import hashlib
import json
import os
from pathlib import Path
import struct
import unittest
import zlib


ROOT = Path(__file__).resolve().parent.parent
KINDS = {"humvee": "scout", "tank": "tank", "artillery": "artillery",
         "mechanic": "repair-truck", "aaTruck": "mobile-aa", "helicopter": "helicopter",
         "fighter": "fighter", "battleship": "battleship", "carrier": "carrier", "submarine": "submarine"}


def inspect_png(data):
    if not data.startswith(b"\x89PNG\r\n\x1a\n") or len(data) > 12 * 1024 * 1024:
        raise ValueError("Invalid PNG signature or excessive file size")
    offset, chunks, header, ended = 8, [], None, False
    while offset < len(data):
        if offset + 12 > len(data):
            raise ValueError("Truncated PNG chunk")
        length = struct.unpack_from(">I", data, offset)[0]
        end = offset + length + 12
        if end > len(data):
            raise ValueError("Truncated PNG payload")
        tag, payload = data[offset + 4:offset + 8], data[offset + 8:end - 4]
        if binascii.crc32(tag + payload) & 0xFFFFFFFF != struct.unpack_from(">I", data, end - 4)[0]:
            raise ValueError("PNG CRC mismatch")
        if header is None and tag != b"IHDR":
            raise ValueError("IHDR must be first")
        if tag == b"IHDR":
            if header is not None or length != 13:
                raise ValueError("Invalid IHDR")
            header = struct.unpack(">IIBBBBB", payload)
        elif tag == b"IDAT":
            chunks.append(payload)
        elif tag == b"IEND":
            if length or end != len(data):
                raise ValueError("Invalid PNG ending")
            ended = True
            break
        offset = end
    if not ended or not chunks or header is None:
        raise ValueError("Incomplete PNG")
    width, height, depth, color, compression, filtering, interlace = header
    if not (0 < width <= 2048 and 0 < height <= 2048 and width * height <= 4194304):
        raise ValueError("PNG dimensions exceed the sprite budget")
    if (depth, color, compression, filtering, interlace) != (8, 6, 0, 0, 0):
        raise ValueError("Sprites must be noninterlaced RGBA8 PNGs with real alpha")
    expected = (width * 4 + 1) * height
    decoder = zlib.decompressobj()
    raw = decoder.decompress(b"".join(chunks), expected + 1)
    if len(raw) != expected or not decoder.eof or decoder.unused_data:
        raise ValueError("Invalid or oversized PNG scanlines")
    previous = bytearray(width)
    transparent = solid = 0
    min_x, min_y, max_x, max_y = width, height, -1, -1
    corners = []
    stride, offset = width * 4, 0
    for y in range(height):
        method = raw[offset]
        row = bytearray(raw[offset + 4:offset + 1 + stride:4])
        offset += stride + 1
        if method not in range(5):
            raise ValueError("Invalid PNG filter")
        # PNG prediction is channel-independent; only alpha needs reconstruction.
        for x in range(width):
            left = row[x - 1] if x else 0
            up, upper_left = previous[x], previous[x - 1] if x else 0
            if method == 1:
                predictor = left
            elif method == 2:
                predictor = up
            elif method == 3:
                predictor = (left + up) // 2
            elif method == 4:
                p = left + up - upper_left
                distances = (abs(p - left), abs(p - up), abs(p - upper_left))
                predictor = (left, up, upper_left)[distances.index(min(distances))]
            else:
                predictor = 0
            row[x] = (row[x] + predictor) & 255
            alpha = row[x]
            transparent += alpha <= 8
            solid += alpha >= 200
            if alpha >= 32:
                min_x, max_x = min(min_x, x), max(max_x, x)
                min_y, max_y = min(min_y, y), max(max_y, y)
        if y in (0, height - 1):
            corners.extend((row[0], row[-1]))
        previous = row
    return {"width": width, "height": height, "cornerAlpha": corners,
            "transparentFraction": round(transparent / (width * height), 6),
            "solidFraction": round(solid / (width * height), 6),
            "contentBounds": [min_x, min_y, max_x + 1, max_y + 1]}


def verify_transparency(info):
    if max(info["cornerAlpha"]) > 8 or not 0.12 <= info["transparentFraction"] <= 0.95 or info["solidFraction"] < 0.03:
        raise ValueError("Sprite is empty, opaque, or has a painted background")


def verify(art):
    source_manifest = ROOT / "DesertFrontline/Art/unit-art-manifest.json"
    manifest_path = art / "unit-art-manifest.json"
    if manifest_path.is_symlink() or manifest_path.read_bytes() != source_manifest.read_bytes():
        raise ValueError("Built manifest differs from the checkout")
    manifest = json.loads(manifest_path.read_text())
    if manifest.get("schemaVersion") != 1 or manifest.get("decodeMaxPixels") != 384:
        raise ValueError("Unsupported art manifest / decode budget")
    document = (ROOT / manifest["promptDocument"]).resolve()
    if not document.is_relative_to(ROOT) or not document.is_file():
        raise ValueError("Art provenance document missing")
    assets = manifest["assets"]
    if len(assets) != len(KINDS) or {a["kind"] for a in assets} != set(KINDS):
        raise ValueError("Expected exactly ten land/air/naval unit assets")
    reports = []
    for asset in assets:
        name = f"Units/{KINDS[asset['kind']]}.png"
        path = art / name
        if asset["file"] != name or path.is_symlink():
            raise ValueError("Unexpected asset path")
        data = path.read_bytes()
        if len(data) != asset["bytes"] or hashlib.sha256(data).hexdigest() != asset["sha256"]:
            raise ValueError(f"Asset digest mismatch: {name}")
        info = inspect_png(data)
        if [info["width"], info["height"]] != [asset["width"], asset["height"]]:
            raise ValueError(f"Asset dimensions mismatch: {name}")
        verify_transparency(info)
        reports.append(dict(kind=asset["kind"], file=name, sha256=asset["sha256"], bytes=len(data), **info))
    return reports


def fixture_png(rows, method=0, color=6):
    def chunk(tag, payload):
        return struct.pack(">I", len(payload)) + tag + payload + struct.pack(">I", binascii.crc32(tag + payload) & 0xFFFFFFFF)
    width = len(rows[0])
    scanlines, previous = bytearray(), [0] * width
    for row in rows:
        scanlines.append(method)
        for x, alpha in enumerate(row):
            left, up = row[x - 1] if x else 0, previous[x]
            upper_left = previous[x - 1] if x else 0
            p = left + up - upper_left
            distances = [abs(p - v) for v in (left, up, upper_left)]
            predictor = [0, left, up, (left + up) // 2, (left, up, upper_left)[distances.index(min(distances))]][method]
            scanlines.extend((0, 0, 0, (alpha - predictor) & 255))
        previous = row
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", width, len(rows), 8, color, 0, 0, 0)) +
            chunk(b"IDAT", zlib.compress(bytes(scanlines))) + chunk(b"IEND", b""))


class ArtContractTests(unittest.TestCase):
    def test_all_png_filters(self):
        rows = [[0, 1, 0, 0], [0, 240, 255, 0], [0, 200, 230, 0], [0, 0, 0, 0]]
        for method in range(5):
            with self.subTest(method=method):
                info = inspect_png(fixture_png(rows, method))
                verify_transparency(info)
                self.assertEqual(info["contentBounds"], [1, 1, 3, 3])

    def test_opaque_and_empty_rejected(self):
        for alpha in (0, 255):
            with self.subTest(alpha=alpha), self.assertRaises(ValueError):
                verify_transparency(inspect_png(fixture_png([[alpha] * 4] * 4)))

    def test_bad_crc_rejected(self):
        data = bytearray(fixture_png([[0, 255], [255, 0]]))
        data[-1] ^= 1
        with self.assertRaises(ValueError):
            inspect_png(bytes(data))

    def test_truncation_rejected(self):
        with self.assertRaises(ValueError):
            inspect_png(fixture_png([[0, 255], [255, 0]])[:-6])

    def test_non_rgba_rejected(self):
        with self.assertRaises(ValueError):
            inspect_png(fixture_png([[0, 255], [255, 0]], color=2))

    def test_trailing_bytes_rejected(self):
        with self.assertRaises(ValueError):
            inspect_png(fixture_png([[0, 255], [255, 0]]) + b"extra")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bundle", type=Path)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if os.environ.get("GITHUB_ACTIONS") != "true":
        parser.error("Unit art validation runs in cloud CI only")
    if args.self_test:
        result = unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(ArtContractTests))
        raise SystemExit(0 if result.wasSuccessful() else 1)
    mode = "bundle" if args.bundle else "source"
    report = {"schemaVersion": 1, "mode": mode, "status": "failure",
              "branch": os.environ.get("GITHUB_REF_NAME", ""), "commitSha": os.environ.get("GITHUB_SHA", ""),
              "runId": os.environ.get("GITHUB_RUN_ID", ""), "runAttempt": os.environ.get("GITHUB_RUN_ATTEMPT", "")}
    try:
        report["assets"] = verify(args.bundle / "Art" if args.bundle else ROOT / "DesertFrontline/Art")
        report["status"] = "success"
        print(f"Unit art {mode}: ten RGBA sprites, digests, bounds and transparency verified", flush=True)
    except (OSError, ValueError, KeyError, TypeError, zlib.error) as error:
        report["error"] = str(error)
        print(f"Unit art {mode}: failure: {error}", flush=True)
    finally:
        destination = Path("ci-results")
        destination.mkdir(exist_ok=True)
        (destination / f"unit-art-{mode}.json").write_text(json.dumps(report, indent=2) + "\n")
    raise SystemExit(0 if report["status"] == "success" else 1)


if __name__ == "__main__":
    main()
