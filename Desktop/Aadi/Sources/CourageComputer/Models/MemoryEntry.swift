import Foundation

public struct MemoryEntry: Identifiable, Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let category: MemoryCategory
    public let title: String
    public let content: String
    public let importance: Double
    public let threatLevel: ThreatLevel
    public let tags: [String]
    public let metadata: [String: String]

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        category: MemoryCategory,
        title: String,
        content: String,
        importance: Double = 0.5,
        threatLevel: ThreatLevel = .nominal,
        tags: [String] = [],
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.category = category
        self.title = title
        self.content = content
        self.importance = importance
        self.threatLevel = threatLevel
        self.tags = tags
        self.metadata = metadata
    }

    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: timestamp)
    }

    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter.string(from: timestamp)
    }
}
