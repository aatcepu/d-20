import SwiftUI

public struct DiagnosticsView: View {
    @Binding var currentPhosphor: PhosphorColor
    @ObservedObject var intelligenceEngine: ComputerIntelligenceEngine
    @ObservedObject var speechManager: SpeechManager
    @ObservedObject var memoryManager: MemoryManager

    @State private var selfTestRunning: Bool = false
    @State private var selfTestReport: String = "ALL REGISTERS NOMINAL."
    @State private var sfxEnabled: Bool = true

    public init(
        currentPhosphor: Binding<PhosphorColor>,
        intelligenceEngine: ComputerIntelligenceEngine,
        speechManager: SpeechManager,
        memoryManager: MemoryManager
    ) {
        self._currentPhosphor = currentPhosphor
        self.intelligenceEngine = intelligenceEngine
        self.speechManager = speechManager
        self.memoryManager = memoryManager
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SYSTEM DIAGNOSTICS & TELEMETRY")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(currentPhosphor.primaryColor)
                            .crtGlow(color: currentPhosphor.glowColor, radius: 2)
                        Text("COURAGE MODEL-99 CRT OPERATING SYSTEM")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(currentPhosphor.dimColor)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)

                // Subsystem Status Box
                VStack(alignment: .leading, spacing: 6) {
                    Text("SUBSYSTEM REGISTERS:")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(currentPhosphor.dimColor)

                    subsystemRow(label: "COMPUTER PROCESSOR", status: "ONLINE (3.2 GHz)", ok: true)
                    subsystemRow(label: "VISION ENGINE", status: "ACTIVE (APPLE VISION)", ok: true)
                    subsystemRow(label: "AUDIO SENSORS", status: "READY (AVFOUNDATION)", ok: true)
                    subsystemRow(label: "LOCAL MEMORY", status: "\(memoryManager.entries.count) REGISTERS", ok: true)
                    subsystemRow(label: "LOCAL AI MODEL", status: "100% OFFLINE (NO CLOUD)", ok: true)
                    subsystemRow(label: "NETWORK INTERFACE", status: "PERMANENTLY DISCONNECTED", ok: true)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(currentPhosphor.primaryColor.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 16)

                // The Iconic Computer Network Disconnect Quote
                VStack(alignment: .leading, spacing: 4) {
                    Text("NETWORK TELEMETRY:")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(currentPhosphor.dimColor)
                    Text("NETWORK ......... DISCONNECTED.")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(currentPhosphor.primaryColor)
                    Text("GOOD. I PREFER TO BE ALONE.")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.orange)
                        .crtGlow(color: Color.orange.opacity(0.4), radius: 3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(currentPhosphor.primaryColor.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(currentPhosphor.primaryColor.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)

                // Phosphor Color Switcher
                VStack(alignment: .leading, spacing: 8) {
                    Text("CRT PHOSPHOR TUBE CONFIGURATION:")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(currentPhosphor.dimColor)

                    HStack(spacing: 8) {
                        ForEach(PhosphorColor.allCases) { p in
                            let isSelected = currentPhosphor == p
                            Button(action: {
                                SoundSynthesizer.shared.playKeyClick()
                                currentPhosphor = p
                            }) {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(p.primaryColor)
                                        .frame(width: 8, height: 8)
                                    Text(p.rawValue)
                                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                                }
                                .foregroundColor(isSelected ? p.backgroundColor : p.primaryColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(isSelected ? p.primaryColor : p.backgroundColor)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(p.primaryColor, lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)

                // Speech & Audio Controls
                VStack(alignment: .leading, spacing: 10) {
                    Text("SPEECH & AUDIO CONFIGURATION:")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(currentPhosphor.dimColor)

                    Toggle(isOn: $speechManager.isVoiceOutputEnabled) {
                        Text("VOICE SYNTHESIS OUTPUT")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(currentPhosphor.primaryColor)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: currentPhosphor.primaryColor))

                    Toggle(isOn: $sfxEnabled) {
                        Text("PROCEDURAL CRT SOUND EFFECTS")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(currentPhosphor.primaryColor)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: currentPhosphor.primaryColor))
                    .onChange(of: sfxEnabled) { _, val in
                        SoundSynthesizer.shared.setMuted(!val)
                    }

                    // Pitch Multiplier Slider
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("VOICE PITCH: \(String(format: "%.2f", speechManager.pitchMultiplier))")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(currentPhosphor.dimColor)
                            Spacer()
                            Text(speechManager.pitchMultiplier < 0.9 ? "METALLIC / DRY" : "STANDARD")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(currentPhosphor.primaryColor)
                        }
                        Slider(value: Binding(
                            get: { Double(speechManager.pitchMultiplier) },
                            set: { speechManager.pitchMultiplier = Float($0) }
                        ), in: 0.65...1.25)
                        .tint(currentPhosphor.primaryColor)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(currentPhosphor.primaryColor.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 16)

                // Self-Test Action Button
                Button(action: {
                    runSelfTest()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: selfTestRunning ? "gearshape.2.fill" : "hammer")
                        Text(selfTestRunning ? "RUNNING SELF-TEST..." : "EXECUTE HARDWARE SELF-TEST")
                    }
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(currentPhosphor.backgroundColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(currentPhosphor.primaryColor)
                    )
                }
                .disabled(selfTestRunning)
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
    }

    private func subsystemRow(label: String, status: String, ok: Bool) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(currentPhosphor.dimColor)
            Spacer()
            Text(status)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(currentPhosphor.primaryColor)
        }
    }

    private func runSelfTest() {
        SoundSynthesizer.shared.playScan()
        selfTestRunning = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            SoundSynthesizer.shared.playConfirm()
            selfTestRunning = false
            speechManager.speak("Hardware self test concluded. All logical registers superior to user intelligence.")
        }
    }
}
