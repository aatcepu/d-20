import SwiftUI

public enum SystemState: String, CaseIterable, Codable, Sendable {
    case booting = "BOOTING"
    case online = "ONLINE"
    case analyzing = "ANALYZING"
    case investigating = "INVESTIGATING"
    case speaking = "TRANSMITTING"
    case warning = "WARNING"
}

public enum SensorStatus: String, CaseIterable, Codable, Sendable {
    case offline = "OFFLINE"
    case calibrating = "CALIBRATING"
    case ready = "READY"
    case active = "ACTIVE"
    case anomaly = "ANOMALY"
}

public enum MemoryCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case conversation = "CONVERSATION"
    case object = "OBJECT"
    case location = "LOCATION"
    case event = "EVENT"
    case observation = "OBSERVATION"
    case system = "SYSTEM"
    case anomaly = "ANOMALY"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .conversation: return "bubble.left.and.bubble.right"
        case .object: return "cube"
        case .location: return "mappin.and.ellipse"
        case .event: return "clock.arrow.circlepath"
        case .observation: return "eye"
        case .system: return "cpu"
        case .anomaly: return "exclamationmark.triangle"
        }
    }
}

public enum ThreatLevel: String, CaseIterable, Codable, Sendable {
    case nominal = "NOMINAL (SAFE)"
    case low = "LOW (MONITOR)"
    case elevated = "ELEVATED (SUSPICIOUS)"
    case high = "HIGH (HAZARDOUS)"
    case severe = "CRITICAL (ANOMALOUS)"

    public var color: Color {
        switch self {
        case .nominal: return Color.green
        case .low: return Color(red: 0.7, green: 0.9, blue: 0.2)
        case .elevated: return Color.yellow
        case .high: return Color.orange
        case .severe: return Color.red
        }
    }

    public var score: Double {
        switch self {
        case .nominal: return 0.05
        case .low: return 0.25
        case .elevated: return 0.55
        case .high: return 0.80
        case .severe: return 0.98
        }
    }
}

public enum UserIntent: String, CaseIterable, Codable, Sendable, Hashable {
    case greeting
    case question
    case visionQuery
    case objectQuery
    case memoryQuery
    case investigation
    case systemStatus
    case threatCheck
    case philosophical
    case help
    case unknown
}

public enum ActiveScreen: String, CaseIterable, Identifiable, Sendable {
    case console = "CONSOLE"
    case vision = "VISION HUD"
    case investigate = "INVESTIGATE"
    case memory = "MEMORY BANK"
    case diagnostics = "DIAGNOSTICS"

    public var id: String { rawValue }

    public var symbol: String {
        switch self {
        case .console: return "terminal"
        case .vision: return "camera.viewfinder"
        case .investigate: return "waveform.path.ecg"
        case .memory: return "externaldrive.badge.timemachine"
        case .diagnostics: return "gearshape.2"
        }
    }
}
