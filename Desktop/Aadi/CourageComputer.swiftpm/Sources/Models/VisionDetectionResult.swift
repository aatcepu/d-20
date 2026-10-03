import Foundation
import CoreGraphics

public struct DetectedLabel: Identifiable, Codable, Sendable {
    public let id: UUID
    public let label: String
    public let confidence: Double
    public let category: String

    public init(id: UUID = UUID(), label: String, confidence: Double, category: String = "general") {
        self.id = id
        self.label = label
        self.confidence = confidence
        self.category = category
    }

    public var confidencePercentage: Int {
        Int(confidence * 100)
    }
}

public struct VisionDetectionResult: Identifiable, Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let labels: [DetectedLabel]
    public let primaryObject: String
    public let confidence: Double
    public let threatLevel: ThreatLevel
    public let opticalNotes: String
    public let isSimulated: Bool
    public let targetName: String
    public let boundingBoxDescription: String?

    public var confidencePercentage: Int {
        Int(confidence * 100)
    }

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        labels: [DetectedLabel] = [],
        primaryObject: String,
        confidence: Double,
        threatLevel: ThreatLevel = .nominal,
        opticalNotes: String = "",
        isSimulated: Bool = false,
        targetName: String = "Live Optical Feed",
        boundingBoxDescription: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.labels = labels
        self.primaryObject = primaryObject
        self.confidence = confidence
        self.threatLevel = threatLevel
        self.opticalNotes = opticalNotes
        self.isSimulated = isSimulated
        self.targetName = targetName
        self.boundingBoxDescription = boundingBoxDescription
    }
}
