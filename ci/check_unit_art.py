#!/usr/bin/env python3
"""Verify original entity, scenery and effect sprites in the checkout and built app."""
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
STRUCTURES = {"hq": "command-hq", "barracks": "war-factory", "airfield": "airfield", "shipyard": "shipyard",
              "oilDerrick": "oil-derrick", "radarOutpost": "radar-outpost", "sonarBuoy": "sonar-buoy",
              "guardTower": "guard-tower", "samSite": "sam-site", "coastalBattery": "coastal-battery"}
SCENERY = {"desertRocks": "desert-rocks", "datePalm": "date-palm", "desertHamlet": "desert-hamlet"}
EFFECTS = {"waterImpact": "water-impact", "impactBurst": "impact-burst"}
DIRECTIONS = {"tankDirections": "tank-eight", "fighterDirections": "fighter-eight", "helicopterDirections": "helicopter-eight",
              "battleshipDirections": "battleship-eight", "carrierDirections": "carrier-eight", "submarineDirections": "submarine-eight",
              "scoutDirections": "scout-eight", "artilleryDirections": "artillery-eight",
              "mobileAADirections": "mobile-aa-eight", "repairTruckDirections": "repair-truck-eight"}
MATERIALS = {"sandSurface": "desert-sand", "waterSurface": "open-water"}
ASSET_PATHS = {**{kind: f"Units/{name}.png" for kind, name in KINDS.items()},
               **{kind: f"Structures/{name}.png" for kind, name in STRUCTURES.items()},
               **{kind: f"Scenery/{name}.png" for kind, name in SCENERY.items()},
               **{kind: f"Effects/{name}.png" for kind, name in EFFECTS.items()},
               **{kind: f"Directions/{name}.png" for kind, name in DIRECTIONS.items()},
               **{kind: f"Terrain/{name}.png" for kind, name in MATERIALS.items()}}


def inspect_png(data, atlas_grid=None, opaque_rgb=False):
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
    expected_color = 2 if opaque_rgb else 6
    if (depth, color, compression, filtering, interlace) != (8, expected_color, 0, 0, 0):
        raise ValueError("Terrain materials must be RGB8" if opaque_rgb else
                         "Sprites must be noninterlaced RGBA8 PNGs with real alpha")
    channels = 3 if opaque_rgb else 4
    expected = (width * channels + 1) * height
    decoder = zlib.decompressobj()
    raw = decoder.decompress(b"".join(chunks), expected + 1)
    if len(raw) != expected or not decoder.eof or decoder.unused_data:
        raise ValueError("Invalid or oversized PNG scanlines")
    if opaque_rgb:
        stride, offset, previous = width * 3, 0, bytearray(width * 3)
        lows, highs = [255] * 3, [0] * 3
        for _ in range(height):
            method = raw[offset]
            if method not in range(5):
                raise ValueError("Invalid PNG filter")
            row = bytearray(raw[offset + 1:offset + 1 + stride])
            offset += stride + 1
            if method:
                for x in range(stride):
                    left, up = row[x - 3] if x >= 3 else 0, previous[x]
                    upper_left = previous[x - 3] if x >= 3 else 0
                    if method == 1: predictor = left
                    elif method == 2: predictor = up
                    elif method == 3: predictor = (left + up) // 2
                    else:
                        p = left + up - upper_left
                        distances = (abs(p - left), abs(p - up), abs(p - upper_left))
                        predictor = (left, up, upper_left)[distances.index(min(distances))]
                    row[x] = (row[x] + predictor) & 255
            for channel in range(3):
                values = row[channel::3]
                lows[channel], highs[channel] = min(lows[channel], min(values)), max(highs[channel], max(values))
            previous = row
        if max(high - low for low, high in zip(lows, highs)) < 4:
            raise ValueError("Terrain material is blank or flat colored")
        return {"width": width, "height": height, "format": "RGB8", "opaque": True,
                "channelMin": lows, "channelMax": highs}
    previous = bytearray(width)
    transparent = solid = 0
    min_x, min_y, max_x, max_y = width, height, -1, -1
    corners = []
    alpha_rows = []
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
        if atlas_grid:
            alpha_rows.append(bytes(row))
        previous = row
    info = {"width": width, "height": height, "cornerAlpha": corners,
            "transparentFraction": round(transparent / (width * height), 6),
            "solidFraction": round(solid / (width * height), 6),
            "contentBounds": [min_x, min_y, max_x + 1, max_y + 1]}
    if atlas_grid:
        columns, rows = atlas_grid
        cells = []
        for index in range(columns * rows):
            column, row = index % columns, index // columns
            x0, x1 = column * width // columns, (column + 1) * width // columns
            y0, y1 = row * height // rows, (row + 1) * height // rows
            pixels = b"".join(line[x0:x1] for line in alpha_rows[y0:y1])
            if not pixels:
                raise ValueError("Empty atlas cell")
            cells.append({"index": index, "width": x1 - x0, "height": y1 - y0,
                          "cornerAlpha": [alpha_rows[y][x] for y in (y0, y1 - 1) for x in (x0, x1 - 1)],
                          "transparentFraction": sum(a <= 8 for a in pixels) / len(pixels),
                          "solidFraction": sum(a >= 200 for a in pixels) / len(pixels),
                          "alphaSha256": hashlib.sha256(pixels).hexdigest()})
        info["cells"] = cells
    return info


def verify_transparency(info):
    if max(info["cornerAlpha"]) > 8 or not 0.12 <= info["transparentFraction"] <= 0.95 or info["solidFraction"] < 0.03:
        raise ValueError("Sprite is empty, opaque, or has a painted background")


def verify_directional_cells(info):
    cells = info.get("cells", [])
    if len(cells) != 8 or len({cell["alphaSha256"] for cell in cells}) != 8:
        raise ValueError("Expected eight distinct populated directional views")
    for cell in cells:
        verify_transparency(cell)


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
    if len(assets) != len(ASSET_PATHS) or {a["kind"] for a in assets} != set(ASSET_PATHS):
        raise ValueError("Expected ten units, ten structures, three scenery, two effects, ten atlases and two terrain materials")
    reports = []
    for asset in assets:
        name = ASSET_PATHS[asset['kind']]
        path = art / name
        if asset["file"] != name or path.is_symlink():
            raise ValueError("Unexpected asset path")
        data = path.read_bytes()
        if len(data) != asset["bytes"] or hashlib.sha256(data).hexdigest() != asset["sha256"]:
            raise ValueError(f"Asset digest mismatch: {name}")
        directional = asset["kind"] in DIRECTIONS
        material = asset["kind"] in MATERIALS
        info = inspect_png(data, atlas_grid=(4, 2) if directional else None, opaque_rgb=material)
        if [info["width"], info["height"]] != [asset["width"], asset["height"]]:
            raise ValueError(f"Asset dimensions mismatch: {name}")
        if material:
            if asset.get("format") != "RGB8" or asset.get("decodeMaxPixels") != 1024:
                raise ValueError("Unexpected terrain material format / decode budget")
        else:
            verify_transparency(info)
        if directional:
            if (asset.get("columns"), asset.get("rows"), asset.get("decodeMaxPixels")) != (4, 2, 1536):
                raise ValueError("Unexpected directional atlas layout / decode budget")
            verify_directional_cells(info)
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


def fixture_rgb_png(rows, method=0):
    def chunk(tag, payload):
        return struct.pack(">I", len(payload)) + tag + payload + struct.pack(">I", binascii.crc32(tag + payload) & 0xFFFFFFFF)
    width, scanlines, previous = len(rows[0]), bytearray(), bytearray(len(rows[0]) * 3)
    for pixels in rows:
        row = bytes(channel for pixel in pixels for channel in pixel)
        scanlines.append(method)
        for x, value in enumerate(row):
            left, up = row[x - 3] if x >= 3 else 0, previous[x]
            upper_left = previous[x - 3] if x >= 3 else 0
            p = left + up - upper_left
            distances = [abs(p - v) for v in (left, up, upper_left)]
            predictor = [0, left, up, (left + up) // 2, (left, up, upper_left)[distances.index(min(distances))]][method]
            scanlines.append((value - predictor) & 255)
        previous = row
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", width, len(rows), 8, 2, 0, 0, 0)) +
            chunk(b"IDAT", zlib.compress(bytes(scanlines))) + chunk(b"IEND", b""))


class ArtContractTests(unittest.TestCase):
    def test_directional_atlas_rejects_missing_opaque_and_repeated_views(self):
        rows = [[0] * 16 for _ in range(8)]
        for index in range(8):
            x0, y0 = (index % 4) * 4, (index // 4) * 4
            for y in (y0 + 1, y0 + 2):
                rows[y][x0 + 1:x0 + 3] = [255 - index] * 2
        verify_directional_cells(inspect_png(fixture_png(rows), atlas_grid=(4, 2)))
        for defect in ("empty", "opaque", "duplicate"):
            broken = [row[:] for row in rows]
            for y in range(4):
                broken[y][0:4] = ([0] * 4 if defect == "empty" else
                                  [255] * 4 if defect == "opaque" else
                                  rows[y][4:8])
            with self.subTest(defect=defect), self.assertRaises(ValueError):
                verify_directional_cells(inspect_png(fixture_png(broken), atlas_grid=(4, 2)))

    def test_material_rgb_filters_and_ranges(self):
        rows = [[(10, 30, 50), (250, 230, 210)], [(30, 50, 70), (200, 180, 160)]]
        for method in range(5):
            with self.subTest(method=method):
                info = inspect_png(fixture_rgb_png(rows, method), opaque_rgb=True)
                self.assertEqual(info["channelMin"], [10, 30, 50])
                self.assertEqual(info["channelMax"], [250, 230, 210])
                self.assertIs(info["opaque"], True)

    def test_material_rejects_flat_rgba_corruption_and_sprite_mode(self):
        valid = fixture_rgb_png([[(10, 20, 30), (200, 180, 160)]])
        corrupt = bytearray(valid); corrupt[-1] ^= 1
        for data in (fixture_rgb_png([[(10, 30, 50)] * 2] * 2),
                     fixture_png([[0, 255], [255, 0]]), bytes(corrupt), valid[:-6], valid + b"extra"):
            with self.subTest(bytes=len(data)), self.assertRaises(ValueError):
                inspect_png(data, opaque_rgb=True)
        with self.assertRaises(ValueError):
            inspect_png(valid)

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
        print(f"Entity art {mode}: {len(report['assets'])} assets; sprite alpha / opaque terrain, digests and bounds verified", flush=True)
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
