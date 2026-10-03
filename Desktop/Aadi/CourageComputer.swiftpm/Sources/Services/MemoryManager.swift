import Foundation
import Combine

@MainActor
public final class MemoryManager: ObservableObject {
    public static let shared = MemoryManager()

    @Published public private(set) var entries: [MemoryEntry] = []
    private let storageKey = "courage_computer_memory_store_v1"
    private let lock = NSLock()

    public init() {
        loadMemories()
        if entries.isEmpty {
            seedInitialMemories()
        }
    }

    public func record(
        category: MemoryCategory,
        title: String,
        content: String,
        importance: Double = 0.5,
        threatLevel: ThreatLevel = .nominal,
        tags: [String] = [],
        metadata: [String: String] = [:]
    ) -> MemoryEntry {
        lock.lock()
        defer { lock.unlock() }

        let entry = MemoryEntry(
            category: category,
            title: title,
            content: content,
            importance: importance,
            threatLevel: threatLevel,
            tags: tags,
            metadata: metadata
        )

        entries.insert(entry, at: 0)
        // Keep memory bounded to 150 items to stay lightweight and fast
        if entries.count > 150 {
            entries = Array(entries.prefix(150))
        }

        saveMemories()
        return entry
    }

    public func findRecentObject(query: String? = nil) -> MemoryEntry? {
        lock.lock()
        defer { lock.unlock() }

        if let q = query?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty {
            return entries.first { entry in
                entry.category == .object &&
                (entry.title.lowercased().contains(q) ||
                 entry.content.lowercased().contains(q) ||
                 entry.tags.contains(where: { $0.lowercased().contains(q) }))
            }
        }
        return entries.first { $0.category == .object }
    }

    public func findRecentAnomaly() -> MemoryEntry? {
        lock.lock()
        defer { lock.unlock() }
        return entries.first { $0.category == .anomaly || $0.threatLevel == .high || $0.threatLevel == .severe }
    }

    public func search(query: String) -> [MemoryEntry] {
        lock.lock()
        defer { lock.unlock() }

        let q = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return entries }

        return entries.filter { entry in
            entry.title.lowercased().contains(q) ||
            entry.content.lowercased().contains(q) ||
            entry.tags.contains(where: { $0.lowercased().contains(q) }) ||
            entry.category.rawValue.lowercased().contains(q)
        }
    }

    public func filter(by category: MemoryCategory?) -> [MemoryEntry] {
        lock.lock()
        defer { lock.unlock() }
        guard let cat = category else { return entries }
        return entries.filter { $0.category == cat }
    }

    public func purgeAll() {
        lock.lock()
        defer { lock.unlock() }
        entries.removeAll()
        saveMemories()
    }

    public var totalAnomaliesCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return entries.filter { $0.category == .anomaly || $0.threatLevel == .high || $0.threatLevel == .severe }.count
    }

    public var totalObjectsCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return entries.filter { $0.category == .object }.count
    }

    private func saveMemories() {
        DispatchQueue.global(qos: .utility).async { [entries] in
            do {
                let data = try JSONEncoder().encode(entries)
                UserDefaults.standard.set(data, forKey: self.storageKey)
            } catch {
                // Non-fatal
            }
        }
    }

    private func loadMemories() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([MemoryEntry].self, from: data)
            self.entries = decoded
        } catch {
            self.entries = []
        }
    }

    private func seedInitialMemories() {
        let now = Date()
        let initial: [MemoryEntry] = [
            MemoryEntry(
                timestamp: now.addingTimeInterval(-3600 * 2),
                category: .system,
                title: "INITIAL BOOT STRAP",
                content: "Local storage initialized. Network interface severed permanently. Intelligence kernel online.",
                importance: 0.9,
                threatLevel: .nominal,
                tags: ["kernel", "coldboot"]
            ),
            MemoryEntry(
                timestamp: now.addingTimeInterval(-3600 * 1.5),
                category: .observation,
                title: "ATTIC AMBIENT SCAN",
                content: "Sub-optimal humidity. Excessive dust particles. Creaking floorboards detected at 0.4 Hz. Probability of paranormal occurrence: within baseline.",
                importance: 0.6,
                threatLevel: .low,
                tags: ["attic", "telemetry"]
            ),
            MemoryEntry(
                timestamp: now.addingTimeInterval(-3600 * 0.8),
                category: .anomaly,
                title: "DISTANT SHADOW PATTERN",
                content: "Unregistered silhouette observed near windmill perimeter. Disappeared upon optical focus. Logged for trend analysis.",
                importance: 0.85,
                threatLevel: .elevated,
                tags: ["shadow", "perimeter", "windmill"]
            )
        ]
        self.entries = initial
        saveMemories()
    }
}
