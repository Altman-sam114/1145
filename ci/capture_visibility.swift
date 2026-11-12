import Foundation
import Vision
import ImageIO
import CryptoKit

// Cloud-only analysis of untouched native PNGs; never renders game content.
let started = ProcessInfo.processInfo.systemUptime
func stage(_ name: String) {
    let elapsed = ProcessInfo.processInfo.systemUptime - started
    fputs(String(format: "capture visibility stage=%@ elapsed=%.3fs\n", name, elapsed), stderr)
    fflush(stderr)
}
do {
    guard CommandLine.arguments.count == 3 else { throw NSError(domain: "CaptureVisibility", code: 1) }
    let input = URL(fileURLWithPath: CommandLine.arguments[1])
    let output = URL(fileURLWithPath: CommandLine.arguments[2])
    stage("read-start")
    let bytes = try Data(contentsOf: input)
    guard let source = CGImageSourceCreateWithData(bytes as CFData, [kCGImageSourceShouldCache: false] as CFDictionary),
          let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
          let width = properties[kCGImagePropertyPixelWidth] as? Int,
          let height = properties[kCGImagePropertyPixelHeight] as? Int,
          width > 0, height > 0, width != height else {
        throw NSError(domain: "CaptureVisibility.Image", code: 1)
    }
    stage("thumbnail-start")
    let maxPixelSize = 1280
    // Analysis only: do not write, replace or normalize the original evidence PNG.
    let options: [CFString: Any] = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                  kCGImageSourceCreateThumbnailWithTransform: false,
                                  kCGImageSourceThumbnailMaxPixelSize: min(maxPixelSize, max(width, height)),
                                  kCGImageSourceShouldCacheImmediately: true]
    guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary),
          max(image.width, image.height) <= maxPixelSize else {
        throw NSError(domain: "CaptureVisibility.Thumbnail", code: 1)
    }
    let portrait = height > width
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .fast
    request.usesCPUOnly = true
    request.recognitionLanguages = ["en-US"]
    request.usesLanguageCorrection = false
    request.regionOfInterest = CGRect(x: 0, y: 0.75, width: 1, height: 0.25)
    stage("recognize-start")
    try VNImageRequestHandler(cgImage: image, orientation: portrait ? .left : .up, options: [:]).perform([request])
    stage("recognize-end")
    let observations: [[String: Any]] = (request.results ?? []).prefix(16).compactMap { observation in
        guard let text = observation.topCandidates(1).first else { return nil }
        let box = observation.boundingBox
        return ["text": String(text.string.prefix(200)), "confidence": Double(text.confidence),
                "bounds": [Double(box.minX), Double(box.minY), Double(box.width), Double(box.height)]]
    }
    guard !observations.isEmpty else { throw NSError(domain: "CaptureVisibility.NoText", code: 1) }
    let words = observations.compactMap { $0["text"] as? String }.joined().lowercased()
    let letters = String(String.UnicodeScalarView(words.unicodeScalars.filter { CharacterSet.letters.contains($0) }))
    let report: [String: Any] = [
        "schemaVersion": 1, "policy": "system-banner-ocr-v2", "engine": "Vision.VNRecognizeTextRequest",
        "status": letters.contains("appleintelligence") ? "obstructed" : "clear",
        "image": ["bytes": bytes.count, "width": width, "height": height,
                  "sha256": SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()],
        "analysis": ["policy": "thumbnail-cpu-fast-v1", "maxPixelSize": maxPixelSize,
                     "width": image.width, "height": image.height, "cpuOnly": request.usesCPUOnly,
                     "recognitionLevel": request.recognitionLevel == .fast ? "fast" : "accurate"],
        "rotationDegrees": portrait ? 270 : 0, "region": [0, 0.75, 1, 0.25], "observations": observations
    ]
    let data = try JSONSerialization.data(withJSONObject: report, options: [.sortedKeys])
    try data.write(to: output, options: .atomic)
    stage("report-written")
    print("capture visibility: \(report["status"]!) / \(observations.count) text observations")
} catch {
    fputs("Capture visibility failed: \(error)\n", stderr)
    exit(1)
}
