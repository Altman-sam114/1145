import Foundation
import Vision
import ImageIO
import CryptoKit

// Cloud-only analysis of untouched native PNGs; never renders game content.
do {
    guard CommandLine.arguments.count == 3 else { throw NSError(domain: "CaptureVisibility", code: 1) }
    let input = URL(fileURLWithPath: CommandLine.arguments[1])
    let output = URL(fileURLWithPath: CommandLine.arguments[2])
    let bytes = try Data(contentsOf: input)
    guard let source = CGImageSourceCreateWithData(bytes as CFData, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil), image.width != image.height else {
        throw NSError(domain: "CaptureVisibility.Image", code: 1)
    }
    let portrait = image.height > image.width
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.recognitionLanguages = ["en-US"]
    request.usesLanguageCorrection = false
    request.regionOfInterest = CGRect(x: 0, y: 0.75, width: 1, height: 0.25)
    try VNImageRequestHandler(cgImage: image, orientation: portrait ? .left : .up, options: [:]).perform([request])
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
        "schemaVersion": 1, "policy": "system-banner-ocr-v1", "engine": "Vision.VNRecognizeTextRequest",
        "status": letters.contains("appleintelligence") ? "obstructed" : "clear",
        "image": ["bytes": bytes.count, "width": image.width, "height": image.height,
                  "sha256": SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()],
        "rotationDegrees": portrait ? 270 : 0, "region": [0, 0.75, 1, 0.25], "observations": observations
    ]
    let data = try JSONSerialization.data(withJSONObject: report, options: [.sortedKeys])
    try data.write(to: output, options: .atomic)
    print("capture visibility: \(report["status"]!) / \(observations.count) text observations")
} catch {
    fputs("Capture visibility failed: \(error)\n", stderr)
    exit(1)
}
