import Foundation
@preconcurrency import AVFoundation
import Vision
import CoreImage
import SwiftUI
import Combine

public struct SimulatedTarget: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    public let category: String
    public let defaultConfidence: Double
    public let threatLevel: ThreatLevel
    public let technicalNotes: String
    public let visualAscii: String

    public init(name: String, category: String, defaultConfidence: Double, threatLevel: ThreatLevel, technicalNotes: String, visualAscii: String) {
        self.name = name
        self.category = category
        self.defaultConfidence = defaultConfidence
        self.threatLevel = threatLevel
        self.technicalNotes = technicalNotes
        self.visualAscii = visualAscii
    }
}

@MainActor
public final class VisionManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    public static let shared = VisionManager()

    @Published public var lastResult: VisionDetectionResult?
    @Published public var isAnalyzing: Bool = false
    @Published public var cameraActive: Bool = false
    @Published public var cameraPermissionGranted: Bool = false
    @Published public var simulatedTargets: [SimulatedTarget] = []
    @Published public var selectedSimulatedTarget: SimulatedTarget?

    @Published public var ambientLux: Double = 42.0
    @Published public var frameMotionVariance: Double = 0.08
    @Published public var livePreviewFrame: CGImage?

    private var captureSession: AVCaptureSession?
    private let videoOutputQueue = DispatchQueue(label: "com.courage.visionoutput", qos: .userInitiated)
    private var lastProcessTime = Date()

    public override init() {
        super.init()
        setupSimulatedTargets()
        checkCameraPermissions()
    }

private func setupSimulatedTargets() {
        simulatedTargets = [
            SimulatedTarget(
                name: "Black Feline (Cat)",
                category: "Animal / Domestic",
                defaultConfidence: 0.94,
                threatLevel: .low,
                technicalNotes: "Bioluminescent retinas. Heart rate 140 BPM. Continuous unblinking observation.",
                visualAscii: " /\\_/\\ \n( o.o )\n > ^ < "
            ),
            SimulatedTarget(
                name: "Ancient Cursed Urn",
                category: "Archaeological Artifact",
                defaultConfidence: 0.91,
                threatLevel: .high,
                technicalNotes: "Atypical isotopic decay. Inscriptions translate to: Return what was taken or face torment.",
                visualAscii: "  .---.  \n /     \\ \n| [xxx] |\n \\_____/ "
            ),
            SimulatedTarget(
                name: "Ticking Brown Parcel",
                category: "Unidentified Container",
                defaultConfidence: 0.96,
                threatLevel: .elevated,
                technicalNotes: "Rhythmic mechanical clicking at 1.0 Hz. Return address obscured by suspicious grease stains.",
                visualAscii: "+-------+\n| [!] T |\n+-------+"
            ),
            SimulatedTarget(
                name: "Shadow Entity at Windmill",
                category: "Environmental Anomaly",
                defaultConfidence: 0.88,
                threatLevel: .severe,
                technicalNotes: "Apparent silhouette absorbing ambient photons. Optical sensor temperature dropped 4.2 degrees.",
                visualAscii: " ~ (O_O) ~\n/  / | \\  \\\n  /  |  \\  "
            ),
            SimulatedTarget(
                name: "Ceramic Teacup",
                category: "Household Utensil",
                defaultConfidence: 0.98,
                threatLevel: .nominal,
                technicalNotes: "Lukewarm chamomile infusion. Ceramic density nominal. No observable poison compounds detected.",
                visualAscii: "  ( (\n   ) )\n .....\n|     |]\n \\___/ "
            ),
            SimulatedTarget(
                name: "Unsettling Wooden Mask",
                category: "Relic / Supernatural",
                defaultConfidence: 0.93,
                threatLevel: .severe,
                technicalNotes: "Audible resonance at 432 Hz. Responds to direct visual contact by altering timber grain pattern.",
                visualAscii: " .-----.\n/  o o  \\\n|   ^   |\n\\  ===  /\n `-----'"
            )
        ]
        selectedSimulatedTarget = simulatedTargets.first
    }

    public func checkCameraPermissions() {
        #if os(iOS) || os(macOS)
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.cameraPermissionGranted = granted
                }
            }
        default:
            cameraPermissionGranted = false
        }
        #endif
    }

    public func startCamera() {
        guard cameraPermissionGranted else { return }
        if captureSession == nil {
            setupCaptureSession()
        }
        let session = self.captureSession
        videoOutputQueue.async {
            session?.startRunning()
        }
        self.cameraActive = true
    }

    public func stopCamera() {
        let session = self.captureSession
        videoOutputQueue.async {
            session?.stopRunning()
        }
        self.cameraActive = false
    }

    private func setupCaptureSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .medium

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: videoOutputQueue)

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        self.captureSession = session
    }

    nonisolated public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let (lux, variance) = calculateLuminanceAndVariance(from: pixelBuffer)
        let visionResult = runVisionClassification(on: pixelBuffer)

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.ambientLux = lux
            self.frameMotionVariance = variance
            if let result = visionResult {
                self.lastResult = result
            }
        }
    }

    nonisolated private func calculateLuminanceAndVariance(from pixelBuffer: CVPixelBuffer) -> (Double, Double) {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return (45.0, 0.05) }

        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)

        var totalLum: Double = 0
        let sampleStep = 16
        var count = 0

        for y in stride(from: 0, to: height, by: sampleStep) {
            for x in stride(from: 0, to: width, by: sampleStep) {
                let offset = y * bytesPerRow + x * 4
                let r = Double(buffer[offset])
                let g = Double(buffer[offset + 1])
                let b = Double(buffer[offset + 2])
                let lum = 0.299 * r + 0.587 * g + 0.114 * b
                totalLum += lum
                count += 1
            }
        }

        let avg = count > 0 ? (totalLum / Double(count)) : 45.0
        let variance = Double.random(in: 0.02...0.12)
        return (avg, variance)
    }

    nonisolated private func runVisionClassification(on pixelBuffer: CVPixelBuffer) -> VisionDetectionResult? {
        let classifyRequest = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([classifyRequest])
            if let observations = classifyRequest.results,
               let top = observations.first {
                let threat: ThreatLevel = (top.identifier.contains("knife") || top.identifier.contains("weapon") || top.identifier.contains("fire")) ? .high : .low
                return VisionDetectionResult(
                    labels: observations.prefix(4).map {
                        DetectedLabel(label: $0.identifier.replacingOccurrences(of: "_", with: " "), confidence: Double($0.confidence))
                    },
                    primaryObject: top.identifier.replacingOccurrences(of: "_", with: " ").capitalized,
                    confidence: Double(top.confidence),
                    threatLevel: threat,
                    opticalNotes: "Optical recognition calibrated. Ident: \(top.identifier)",
                    isSimulated: false,
                    targetName: "Optical Sensor Feed"
                )
            }
        } catch {
            return nil
        }
        return nil
    }

    public func analyzeCurrentView(completion: @escaping @Sendable @MainActor (VisionDetectionResult) -> Void) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            let res = await self.analyzeCurrentViewAsync()
            completion(res)
        }
    }


    public func analyzeCurrentViewAsync() async -> VisionDetectionResult {
        isAnalyzing = true
        try? await Task.sleep(nanoseconds: 300_000_000)

        let result: VisionDetectionResult
        if cameraActive, let last = lastResult {
            result = last
        } else {
            let target = selectedSimulatedTarget ?? simulatedTargets[0]
            result = VisionDetectionResult(
                labels: [
                    DetectedLabel(label: target.name, confidence: target.defaultConfidence, category: target.category),
                    DetectedLabel(label: "Material Composition", confidence: target.defaultConfidence - 0.12),
                    DetectedLabel(label: "Temporal Stability", confidence: 0.82)
                ],
                primaryObject: target.name,
                confidence: target.defaultConfidence,
                threatLevel: target.threatLevel,
                opticalNotes: target.technicalNotes,
                isSimulated: true,
                targetName: target.name
            )
        }

        self.isAnalyzing = false
        self.lastResult = result
        return result
    }

    public func selectTarget(named name: String) {
        if let target = simulatedTargets.first(where: { $0.name.lowercased().contains(name.lowercased()) }) {
            self.selectedSimulatedTarget = target
        }
    }
}
