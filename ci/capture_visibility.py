"""Validate cloud Vision reports against their untouched screenshot bytes."""
import json
import math

from scene_evidence import file_evidence

POLICY = "system-banner-ocr-v2"


def validate_visibility(report, image):
    def number(value):
        return type(value) in (int, float) and math.isfinite(value)

    if (not isinstance(report, dict) or set(report) != {
            "schemaVersion", "policy", "engine", "status", "image", "analysis", "rotationDegrees", "region", "observations"}
            or type(report.get("schemaVersion")) is not int or report["schemaVersion"] != 1
            or report.get("policy") != POLICY or report.get("engine") != "Vision.VNRecognizeTextRequest"
            or report.get("image") != image or type(report.get("rotationDegrees")) is not int
            or report["rotationDegrees"] != (270 if image["height"] > image["width"] else 0)
            or not isinstance(report.get("region"), list) or not all(number(v) for v in report["region"])
            or report["region"] != [0, 0.75, 1, 0.25]):
        raise ValueError("Screenshot visibility identity, orientation or OCR policy invalid")
    analysis = report.get("analysis")
    if (not isinstance(analysis, dict) or set(analysis) != {
            "policy", "maxPixelSize", "width", "height", "cpuOnly", "recognitionLevel"}
            or analysis.get("policy") != "thumbnail-cpu-fast-v1" or analysis.get("cpuOnly") is not True
            or analysis.get("recognitionLevel") != "fast" or type(analysis.get("maxPixelSize")) is not int
            or analysis["maxPixelSize"] != 1280
            or any(type(analysis.get(key)) is not int or analysis[key] <= 0 for key in ("width", "height"))
            or analysis["width"] > image["width"] or analysis["height"] > image["height"]
            or max(analysis["width"], analysis["height"]) != min(1280, max(image["width"], image["height"]))
            or abs(analysis["width"] * image["height"] - analysis["height"] * image["width"]) > max(image["width"], image["height"])):
        raise ValueError("Screenshot visibility bounded CPU analysis evidence invalid")
    observations = report.get("observations")
    if not isinstance(observations, list) or not 0 < len(observations) <= 16:
        raise ValueError("Screenshot visibility OCR observations missing")
    for item in observations:
        if (not isinstance(item, dict) or set(item) != {"text", "confidence", "bounds"}
                or not isinstance(item["text"], str) or not 0 < len(item["text"].strip()) <= 200
                or not number(item["confidence"]) or not 0 <= item["confidence"] <= 1
                or not isinstance(item["bounds"], list) or len(item["bounds"]) != 4
                or not all(number(v) and 0 <= v <= 1 for v in item["bounds"])
                or item["bounds"][2] <= 0 or item["bounds"][3] <= 0):
            raise ValueError("Screenshot visibility OCR text or geometry invalid")
    letters = ''.join(char for item in observations for char in item['text'].lower() if char.isalpha())
    expected = "obstructed" if "appleintelligence" in letters else "clear"
    if report.get("status") != expected:
        raise ValueError("Screenshot visibility status contradicts recognized text")
    return expected


def read_visibility(directory, descriptor, image):
    actual, data = file_evidence(directory, descriptor.get("path"), limit=32768)
    if actual != descriptor:
        raise ValueError("Screenshot visibility report changed")
    report = json.loads(data)
    return validate_visibility(report, image)
