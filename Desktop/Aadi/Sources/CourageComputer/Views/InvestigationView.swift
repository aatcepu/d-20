import SwiftUI

public struct InvestigationView: View {
    let phosphor: PhosphorColor
    @ObservedObject var intelligenceEngine: ComputerIntelligenceEngine
    @ObservedObject var visionManager: VisionManager
    @ObservedObject var speechManager: SpeechManager
    @ObservedObject var memoryManager: MemoryManager

    @State private var isInvestigating: Bool = false
    @State private var correlationProgress: Double = 0.0
    @State private var currentStepText: String = "STANDBY // READY FOR PROTOCOL"
    @State private var latestReport: InvestigationReport?

    public init(
        phosphor: PhosphorColor,
        intelligenceEngine: ComputerIntelligenceEngine,
        visionManager: VisionManager,
        speechManager: SpeechManager,
        memoryManager: MemoryManager
    ) {
        self.phosphor = phosphor
        self.intelligenceEngine = intelligenceEngine
        self.visionManager = visionManager
        self.speechManager = speechManager
        self.memoryManager = memoryManager
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ENVIRONMENTAL INVESTIGATION PROTOCOL")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(phosphor.primaryColor)
                            .crtGlow(color: phosphor.glowColor, radius: 2)
                        Text("MULTIMODAL SENSOR CORRELATION // OFFLINE MATRIX")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(phosphor.dimColor)
                    }
                    Spacer()

                    if isInvestigating {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            Text("CORRELATING")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.red)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)

                // 4 Multimodal Sensor Channels
                VStack(spacing: 8) {
                    sensorChannelRow(
                        channel: "CH-01",
                        name: "OPTICAL TARGET",
                        value: visionManager.selectedSimulatedTarget?.name ?? "LIVE OPTICAL",
                        icon: "camera.viewfinder",
                        status: "LOCKED"
                    )

                    sensorChannelRow(
                        channel: "CH-02",
                        name: "ACOUSTIC AMPLITUDE",
                        value: "\(Int(speechManager.audioLevel)) dB // NOISE SPECTRUM",
                        icon: "waveform",
                        status: speechManager.audioLevel > -20.0 ? "SPIKE" : "NOMINAL"
                    )

                    sensorChannelRow(
                        channel: "CH-03",
                        name: "PHOTONIC LUX",
                        value: "\(Int(visionManager.ambientLux)) LUX // ILLUMINANCE",
                        icon: "sun.min",
                        status: visionManager.ambientLux < 20.0 ? "OBSCURE" : "OPTIMAL"
                    )

                    sensorChannelRow(
                        channel: "CH-04",
                        name: "HISTORICAL MEMORY",
                        value: "\(memoryManager.entries.count) TOTAL // \(memoryManager.totalAnomaliesCount) ANOMALIES",
                        icon: "clock.arrow.circlepath",
                        status: "SYNCED"
                    )
                }
                .padding(.horizontal, 16)

                // Correlation Progress Bar
                if isInvestigating {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(currentStepText)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(phosphor.primaryColor)
                            Spacer()
                            Text("\(Int(correlationProgress * 100))%")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(phosphor.dimColor)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(phosphor.primaryColor.opacity(0.15))
                                    .frame(height: 6)

                                Rectangle()
                                    .fill(phosphor.primaryColor)
                                    .frame(width: geo.size.width * CGFloat(correlationProgress), height: 6)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                        .frame(height: 6)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }

                // Investigation Report Result
                if let report = latestReport {
                    reportCardView(for: report)
                }

                // Trigger Button
                Button(action: {
                    startInvestigation()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: isInvestigating ? "arrow.triangle.2.circlepath" : "exclamationmark.shield")
                        Text(isInvestigating ? "CORRELATING TELEMETRY..." : "EXECUTE INVESTIGATION")
                    }
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(phosphor.backgroundColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isInvestigating ? Color.orange : phosphor.primaryColor)
                    )
                }
                .disabled(isInvestigating)
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }

    // MARK: - Subviews

    private func sensorChannelRow(channel: String, name: String, value: String, icon: String, status: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(phosphor.primaryColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(channel)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(phosphor.dimColor)
                    Text("•")
                        .foregroundColor(phosphor.dimColor)
                    Text(name)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(phosphor.primaryColor)
                }
                Text(value)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.85))
            }

            Spacer()

            Text("[\(status)]")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(status == "SPIKE" || status == "OBSCURE" ? Color.yellow : phosphor.primaryColor)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(phosphor.primaryColor.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(phosphor.primaryColor.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private func reportCardView(for report: InvestigationReport) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("INVESTIGATION VERDICT")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(phosphor.primaryColor)
                Spacer()
                Text("[\(report.threatLevel.rawValue)]")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(report.threatLevel.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(report.threatLevel.color.opacity(0.2))
                    .cornerRadius(3)
            }

            Divider()
                .background(phosphor.primaryColor.opacity(0.3))

            // Factors
            VStack(alignment: .leading, spacing: 4) {
                Text("CORRELATION FACTORS:")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(phosphor.dimColor)

                ForEach(report.correlationSteps, id: \.self) { step in
                    HStack(alignment: .top, spacing: 6) {
                        Text("►")
                            .font(.system(size: 8))
                            .foregroundColor(phosphor.primaryColor)
                        Text(step)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color.white.opacity(0.9))
                    }
                }
            }

            Divider()
                .background(phosphor.primaryColor.opacity(0.3))

            // Deduction
            VStack(alignment: .leading, spacing: 2) {
                Text("COMPUTER DEDUCTION:")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(phosphor.dimColor)
                Text(report.deduction)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(phosphor.primaryColor)
                    .crtGlow(color: phosphor.glowColor, radius: 2)
            }

            // Advisory
            VStack(alignment: .leading, spacing: 2) {
                Text("TACTICAL ADVISORY:")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.orange.opacity(0.9))
                Text(report.advisory)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.orange)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(phosphor.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(report.threatLevel.color, lineWidth: 1.5)
                )
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Protocol Execution

    private func startInvestigation() {
        SoundSynthesizer.shared.playScan()
        isInvestigating = true
        correlationProgress = 0.0

        Task { @MainActor in
            let steps = [
                ("SAMPLING OPTICAL CHANNELS...", 0.25),
                ("ANALYZING ACOUSTIC DECIBEL RESIDUE...", 0.50),
                ("MEASURING AMBIENT LUX ENTROPY...", 0.75),
                ("CALCULATING THREAT VULNERABILITY INDEX...", 1.0)
            ]

            for step in steps {
                currentStepText = step.0
                SoundSynthesizer.shared.playTeletype()
                withAnimation(.easeInOut(duration: 0.35)) {
                    correlationProgress = step.1
                }
                try? await Task.sleep(nanoseconds: 400_000_000)
            }

            let response = await intelligenceEngine.handleInvestigation()
            latestReport = response.investigationReport
            isInvestigating = false
            currentStepText = "INVESTIGATION PROTOCOL CONCLUDED."
        }
    }
}
