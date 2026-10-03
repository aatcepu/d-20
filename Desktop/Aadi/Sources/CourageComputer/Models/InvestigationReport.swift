import Foundation

public struct InvestigationReport: Identifiable, Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let targetDescription: String
    public let opticalFinding: String
    public let audioDecibels: Float
    public let lightLevelLux: Double
    public let motionVariance: Double
    public let anomalyIndex: Double
    public let correlationSteps: [String]
    public let threatLevel: ThreatLevel
    public let deduction: String
    public let advisory: String

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        targetDescription: String,
        opticalFinding: String,
        audioDecibels: Float,
        lightLevelLux: Double,
        motionVariance: Double,
        anomalyIndex: Double,
        correlationSteps: [String],
        threatLevel: ThreatLevel,
        deduction: String,
        advisory: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.targetDescription = targetDescription
        self.opticalFinding = opticalFinding
        self.audioDecibels = audioDecibels
        self.lightLevelLux = lightLevelLux
        self.motionVariance = motionVariance
        self.anomalyIndex = anomalyIndex
        self.correlationSteps = correlationSteps
        self.threatLevel = threatLevel
        self.deduction = deduction
        self.advisory = advisory
    }
}
