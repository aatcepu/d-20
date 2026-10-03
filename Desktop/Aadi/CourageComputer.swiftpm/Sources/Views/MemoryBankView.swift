import SwiftUI

public struct MemoryBankView: View {
    let phosphor: PhosphorColor
    @ObservedObject var memoryManager: MemoryManager

    @State private var selectedCategory: MemoryCategory? = nil
    @State private var searchQuery: String = ""
    @State private var selectedEntry: MemoryEntry? = nil
    @State private var showPurgeConfirmation: Bool = false

    public init(phosphor: PhosphorColor, memoryManager: MemoryManager) {
        self.phosphor = phosphor
        self.memoryManager = memoryManager
    }

    private var filteredEntries: [MemoryEntry] {
        var result = memoryManager.entries
        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }
        if !searchQuery.isEmpty {
            let q = searchQuery.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(q) ||
                $0.content.lowercased().contains(q) ||
                $0.tags.contains(where: { $0.lowercased().contains(q) })
            }
        }
        return result
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SOLID-STATE MEMORY BANK")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(phosphor.primaryColor)
                        .crtGlow(color: phosphor.glowColor, radius: 2)
                    Text("\(memoryManager.entries.count) PERSISTENT REGISTERS // 100% LOCAL")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(phosphor.dimColor)
                }

                Spacer()

                Button(action: {
                    showPurgeConfirmation = true
                }) {
                    Text("[ PURGE ]")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.red.opacity(0.85))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.red.opacity(0.5), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundColor(phosphor.dimColor)

                TextField("SEARCH MEMORY REGISTERS...", text: $searchQuery)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(phosphor.primaryColor)
                    .textFieldStyle(.plain)

                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(phosphor.dimColor)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(phosphor.primaryColor.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 16)

            // Category Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    categoryPill(title: "ALL", category: nil)
                    ForEach(MemoryCategory.allCases) { cat in
                        categoryPill(title: cat.rawValue, category: cat)
                    }
                }
                .padding(.horizontal, 16)
            }

            // Entries List
            if filteredEntries.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Text("NO MATCHING MEMORY REGISTERS FOUND")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(phosphor.dimColor)
                    Spacer()
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredEntries) { entry in
                            memoryCardRow(for: entry)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
        }
        .sheet(item: $selectedEntry) { entry in
            entryDetailSheet(for: entry)
        }
        .alert("PURGE MEMORY BANK?", isPresented: $showPurgeConfirmation) {
            Button("CANCEL", role: .cancel) {}
            Button("PURGE ALL", role: .destructive) {
                SoundSynthesizer.shared.playAlert()
                memoryManager.purgeAll()
            }
        } message: {
            Text("This will permanently erase all local stored observations, anomalies, and dialogues from this device.")
        }
    }

    private func categoryPill(title: String, category: MemoryCategory?) -> some View {
        let isSelected = selectedCategory == category
        return Button(action: {
            SoundSynthesizer.shared.playKeyClick()
            selectedCategory = category
        }) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(isSelected ? phosphor.backgroundColor : phosphor.primaryColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(isSelected ? phosphor.primaryColor : phosphor.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(phosphor.primaryColor.opacity(0.5), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private func memoryCardRow(for entry: MemoryEntry) -> some View {
        Button(action: {
            SoundSynthesizer.shared.playKeyClick()
            selectedEntry = entry
        }) {
            HStack(spacing: 10) {
                Image(systemName: entry.category.iconName)
                    .font(.system(size: 13))
                    .foregroundColor(phosphor.primaryColor)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(entry.title)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(phosphor.primaryColor)
                        Spacer()
                        Text(entry.formattedTime)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(phosphor.dimColor)
                    }

                    Text(entry.content)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.85))
                        .lineLimit(2)
                }

                Text("[\(entry.threatLevel.rawValue.components(separatedBy: " ").first ?? "NOM")]")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(entry.threatLevel.color)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(phosphor.primaryColor.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(phosphor.primaryColor.opacity(0.18), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func entryDetailSheet(for entry: MemoryEntry) -> some View {
        ZStack {
            phosphor.backgroundColor.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("MEMORY REGISTER DETAIL")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(phosphor.primaryColor)
                    Spacer()
                    Button(action: { selectedEntry = nil }) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 16))
                            .foregroundColor(phosphor.primaryColor)
                    }
                    .buttonStyle(.plain)
                }

                Divider().background(phosphor.primaryColor)

                VStack(alignment: .leading, spacing: 6) {
                    Text("TITLE: \(entry.title)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(phosphor.primaryColor)
                    Text("TIMESTAMP: \(entry.formattedDate)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(phosphor.dimColor)
                    Text("CATEGORY: \(entry.category.rawValue)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(phosphor.dimColor)
                    Text("THREAT: \(entry.threatLevel.rawValue)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(entry.threatLevel.color)
                }

                Divider().background(phosphor.primaryColor.opacity(0.3))

                Text("STORED TELEMETRY:")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(phosphor.dimColor)

                Text(entry.content)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.white)
                    .lineSpacing(4)

                Spacer()
            }
            .padding(20)
        }
    }
}
