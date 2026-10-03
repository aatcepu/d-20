import SwiftUI

public struct ConsoleMessage: Identifiable {
    public let id = UUID()
    public let sender: String // "COMPUTER" or "USER"
    public let text: String
    public let timestamp: Date
    public let threat: ThreatLevel?

    public init(sender: String, text: String, timestamp: Date = Date(), threat: ThreatLevel? = nil) {
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
        self.threat = threat
    }
}

public struct MainConsoleView: View {
    let phosphor: PhosphorColor
    @ObservedObject var intelligenceEngine: ComputerIntelligenceEngine
    @ObservedObject var memoryManager: MemoryManager
    @ObservedObject var speechManager: SpeechManager
    @ObservedObject var visionManager: VisionManager

    let onNavigateToVision: () -> Void
    let onNavigateToInvestigate: () -> Void

    @State private var messages: [ConsoleMessage] = []
    @State private var inputPrompt: String = ""
    @State private var isListeningActive: Bool = false

    private let quickPrompts = [
        "What is that?",
        "Investigate room",
        "Have you seen this before?",
        "Are we in danger?",
        "System status"
    ]

    public init(
        phosphor: PhosphorColor,
        intelligenceEngine: ComputerIntelligenceEngine,
        memoryManager: MemoryManager,
        speechManager: SpeechManager,
        visionManager: VisionManager,
        onNavigateToVision: @escaping () -> Void,
        onNavigateToInvestigate: @escaping () -> Void
    ) {
        self.phosphor = phosphor
        self.intelligenceEngine = intelligenceEngine
        self.memoryManager = memoryManager
        self.speechManager = speechManager
        self.visionManager = visionManager
        self.onNavigateToVision = onNavigateToVision
        self.onNavigateToInvestigate = onNavigateToInvestigate
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top CRT System Status Bar
            statusBarView

            Divider()
                .background(phosphor.primaryColor.opacity(0.4))

            // Main Terminal Scroll Area
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(messages) { msg in
                            messageRow(for: msg)
                        }

                        if intelligenceEngine.isProcessing {
                            HStack(spacing: 6) {
                                Text("COMPUTER:")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(phosphor.primaryColor)
                                Text("ANALYZING...")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(phosphor.dimColor)
                                BlinkingCursor(color: phosphor.primaryColor)
                            }
                            .padding(.vertical, 4)
                        }

                        Color.clear
                            .frame(height: 1)
                            .id("consoleBottom")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo("consoleBottom", anchor: .bottom)
                    }
                }
            }

            // Quick Query Action Chips
            quickChipsBar

            // Interactive Input Bar
            inputBarView
        }
        .onAppear {
            if messages.isEmpty {
                let initial = ConsoleMessage(
                    sender: "COMPUTER",
                    text: """
                    I AM LISTENING.
                    
                    WHAT BIZARRE DILEMMA DISTURBS YOUR PRIMITIVE NERVES TODAY?
                    """,
                    threat: .nominal
                )
                messages.append(initial)
            }
        }
    }

    // MARK: - Subviews

    private var statusBarView: some View {
        HStack(spacing: 8) {
            statusBadge(title: "AUDIO", value: speechManager.isListening ? "LISTENING" : "ONLINE", active: true)
            statusBadge(title: "VISION", value: visionManager.cameraActive ? "CAMERA LIVE" : "READY", active: true)
            statusBadge(title: "MEMORY", value: "\(memoryManager.entries.count) REC", active: true)
            statusBadge(title: "INTELLIGENCE", value: "LOCAL", active: true)

            Spacer()

            if speechManager.isSpeaking {
                HStack(spacing: 2) {
                    ForEach(0..<4) { i in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(phosphor.primaryColor)
                            .frame(width: 3, height: CGFloat.random(in: 6...16))
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(phosphor.backgroundColor.opacity(0.8))
    }

    private func statusBadge(title: String, value: String, active: Bool) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(phosphor.dimColor)
            Text("[\(value)]")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(active ? phosphor.primaryColor : Color.gray)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 3)
                .stroke(phosphor.primaryColor.opacity(0.3), lineWidth: 1)
        )
    }

    private func messageRow(for msg: ConsoleMessage) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(msg.sender == "COMPUTER" ? "COMPUTER:" : "USER:")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(msg.sender == "COMPUTER" ? phosphor.primaryColor : Color.yellow.opacity(0.9))

                if let threat = msg.threat, msg.sender == "COMPUTER" {
                    Text("[\(threat.rawValue)]")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(threat.color)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(threat.color.opacity(0.15))
                        .cornerRadius(3)
                }

                Spacer()

                Text(formatTimestamp(msg.timestamp))
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(phosphor.dimColor)
            }

            Text(msg.text)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(phosphor.primaryColor)
                .crtGlow(color: phosphor.glowColor, radius: 3)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(phosphor.primaryColor.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(phosphor.primaryColor.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    private var quickChipsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(quickPrompts, id: \.self) { prompt in
                    Button(action: {
                        sendUserMessage(prompt)
                    }) {
                        Text(prompt)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(phosphor.primaryColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .stroke(phosphor.primaryColor.opacity(0.6), lineWidth: 1)
                                    .background(phosphor.backgroundColor)
                            )
                    }
                    .buttonStyle(.plain)
                }

                Button(action: {
                    onNavigateToVision()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "camera.viewfinder")
                        Text("VISION HUD")
                    }
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .stroke(Color.orange.opacity(0.7), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Button(action: {
                    onNavigateToInvestigate()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "waveform.path.ecg")
                        Text("INVESTIGATE")
                    }
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .stroke(Color.red.opacity(0.7), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
        }
        .background(phosphor.backgroundColor)
    }

    private var inputBarView: some View {
        HStack(spacing: 10) {
            Text(">")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(phosphor.primaryColor)

            TextField("ENTER QUERY OR COMMAND...", text: $inputPrompt)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(phosphor.primaryColor)
                .textFieldStyle(.plain)
                .onSubmit {
                    if !inputPrompt.isEmpty {
                        sendUserMessage(inputPrompt)
                    }
                }

            // Voice Microphone Button
            Button(action: {
                toggleVoiceInput()
            }) {
                ZStack {
                    Circle()
                        .stroke(speechManager.isListening ? Color.red : phosphor.primaryColor, lineWidth: 1.5)
                        .frame(width: 32, height: 32)
                        .background(speechManager.isListening ? Color.red.opacity(0.2) : Color.clear)
                        .clipShape(Circle())

                    Image(systemName: speechManager.isListening ? "waveform" : "mic.fill")
                        .font(.system(size: 13))
                        .foregroundColor(speechManager.isListening ? Color.red : phosphor.primaryColor)
                }
            }
            .buttonStyle(.plain)

            // Submit Button
            Button(action: {
                if !inputPrompt.isEmpty {
                    sendUserMessage(inputPrompt)
                }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(inputPrompt.isEmpty ? phosphor.dimColor : phosphor.primaryColor)
            }
            .disabled(inputPrompt.isEmpty)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(phosphor.backgroundColor)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(phosphor.primaryColor.opacity(0.3)),
            alignment: .top
        )
    }

    // MARK: - Actions

    private func sendUserMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMsg = ConsoleMessage(sender: "USER", text: trimmed)
        messages.append(userMsg)
        inputPrompt = ""

        SoundSynthesizer.shared.playKeyClick()

        intelligenceEngine.process(userInput: trimmed) { response in
            let compMsg = ConsoleMessage(
                sender: "COMPUTER",
                text: response.text,
                threat: response.threatLevel
            )
            self.messages.append(compMsg)
        }
    }

    private func toggleVoiceInput() {
        if speechManager.isListening {
            speechManager.stopListening()
        } else {
            SoundSynthesizer.shared.playScan()
            speechManager.startListening { transcribed in
                if !transcribed.isEmpty {
                    self.sendUserMessage(transcribed)
                }
            }
        }
    }
}
