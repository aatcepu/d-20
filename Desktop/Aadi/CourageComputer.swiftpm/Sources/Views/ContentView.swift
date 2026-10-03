import SwiftUI

public struct ContentView: View {
    @StateObject private var intelligenceEngine = ComputerIntelligenceEngine.shared
    @StateObject private var memoryManager = MemoryManager.shared
    @StateObject private var speechManager = SpeechManager.shared
    @StateObject private var visionManager = VisionManager.shared

    @State private var hasBooted: Bool = false
    @State private var activeScreen: ActiveScreen = .console
    @State private var currentPhosphor: PhosphorColor = .green

    public init() {}

    public var body: some View {
        CRTMonitorFrame(
            phosphor: currentPhosphor,
            isProcessing: intelligenceEngine.isProcessing
        ) {
            ZStack {
                if !hasBooted {
                    BootView(phosphor: currentPhosphor) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            hasBooted = true
                        }
                    }
                } else {
                    VStack(spacing: 0) {
                        // Top CRT Navigation Bar
                        screenTabBar

                        Divider()
                            .background(currentPhosphor.primaryColor.opacity(0.3))

                        // Active Screen
                        Group {
                            switch activeScreen {
                            case .console:
                                MainConsoleView(
                                    phosphor: currentPhosphor,
                                    intelligenceEngine: intelligenceEngine,
                                    memoryManager: memoryManager,
                                    speechManager: speechManager,
                                    visionManager: visionManager,
                                    onNavigateToVision: { activeScreen = .vision },
                                    onNavigateToInvestigate: { activeScreen = .investigate }
                                )

                            case .vision:
                                VisionScannerView(
                                    phosphor: currentPhosphor,
                                    visionManager: visionManager,
                                    intelligenceEngine: intelligenceEngine,
                                    onNavigateToConsole: { activeScreen = .console }
                                )

                            case .investigate:
                                InvestigationView(
                                    phosphor: currentPhosphor,
                                    intelligenceEngine: intelligenceEngine,
                                    visionManager: visionManager,
                                    speechManager: speechManager,
                                    memoryManager: memoryManager
                                )

                            case .memory:
                                MemoryBankView(
                                    phosphor: currentPhosphor,
                                    memoryManager: memoryManager
                                )

                            case .diagnostics:
                                DiagnosticsView(
                                    currentPhosphor: $currentPhosphor,
                                    intelligenceEngine: intelligenceEngine,
                                    speechManager: speechManager,
                                    memoryManager: memoryManager
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .crtFlicker()
        }
        .frame(minWidth: 700, minHeight: 520)
    }

    private var screenTabBar: some View {
        HStack(spacing: 6) {
            ForEach(ActiveScreen.allCases) { screen in
                let isSelected = activeScreen == screen
                Button(action: {
                    SoundSynthesizer.shared.playKeyClick()
                    withAnimation(.easeInOut(duration: 0.15)) {
                        activeScreen = screen
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: screen.symbol)
                            .font(.system(size: 9))
                        Text(screen.rawValue)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(isSelected ? currentPhosphor.backgroundColor : currentPhosphor.primaryColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(isSelected ? currentPhosphor.primaryColor : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(currentPhosphor.primaryColor.opacity(0.4), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // Quick Reboot Button
            Button(action: {
                SoundSynthesizer.shared.playBoot()
                withAnimation {
                    hasBooted = false
                }
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 11))
                    .foregroundColor(currentPhosphor.dimColor)
                    .padding(5)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(currentPhosphor.backgroundColor)
    }
}
