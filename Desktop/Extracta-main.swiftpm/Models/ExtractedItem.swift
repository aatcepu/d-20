import Foundation

// Phase 1: stub — extended in Phase 2
struct ExtractedItem: Identifiable {
    let id: UUID
    let text: String

    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}
