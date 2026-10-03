import SwiftUI

public struct BootView: View {
    let phosphor: PhosphorColor
    let onBootComplete: () -> Void

    @State private var currentStepIndex: Int = 0
    @State private var displayedLines: [String] = []
    @State private var isBooting: Bool = true

    private let bootSequence: [(text: String, delay: Double)] = [
        ("========================================", 0.08),
        ("       COURAGE COMPUTER SYSTEM", 0.12),
        ("========================================", 0.08),
        ("", 0.05),
        ("MEMORY ................. OK", 0.18),
        ("VISION ................. OK", 0.18),
        ("AUDIO .................. OK", 0.18),
        ("PROCESSOR .............. OK", 0.18),
        ("LOCAL INTELLIGENCE ..... OK", 0.22),
        ("", 0.08),
        ("INITIALIZING KERNEL...", 0.25),
        ("........................................", 0.20),
        ("SYSTEM READY.", 0.25),
        ("", 0.08),
        ("HELLO.", 0.35),
        ("WHAT DO YOU WANT?", 0.40),
        ("========================================", 0.10)
    ]

    public init(phosphor: PhosphorColor, onBootComplete: @escaping () -> Void) {
        self.phosphor = phosphor
        self.onBootComplete = onBootComplete
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(displayedLines.indices, id: \.self) { idx in
                            Text(displayedLines[idx])
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(phosphor.primaryColor)
                                .crtGlow(color: phosphor.glowColor, radius: 4)
                        }

                        HStack(spacing: 4) {
                            if isBooting {
                                Text("SYSTEM CALIBRATING")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(phosphor.dimColor)
                            }
                            BlinkingCursor(color: phosphor.primaryColor)
                        }
                        .id("bottomAnchor")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                }
                .onChange(of: displayedLines.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo("bottomAnchor", anchor: .bottom)
                    }
                }
            }

            Spacer()

            // Skip / Enter Button
            HStack {
                Spacer()
                Button(action: {
                    SoundSynthesizer.shared.playConfirm()
                    onBootComplete()
                }) {
                    HStack(spacing: 8) {
                        Text(isBooting ? "[ SKIP BOOT ]" : "[ ENTER SYSTEM ]")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(phosphor.primaryColor)
                        Image(systemName: "chevron.right.2")
                            .foregroundColor(phosphor.primaryColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(phosphor.primaryColor, lineWidth: 1.5)
                            .background(phosphor.backgroundColor)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .onAppear {
            SoundSynthesizer.shared.playBoot()
            runBootSequence()
        }
    }

    private func runBootSequence() {
        Task { @MainActor in
            for step in bootSequence {
                try? await Task.sleep(nanoseconds: UInt64(step.delay * 1_000_000_000))
                displayedLines.append(step.text)
                SoundSynthesizer.shared.playTeletype()
            }
            isBooting = false
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            onBootComplete()
        }
    }
}
