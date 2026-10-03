import SwiftUI

public struct VisionScannerView: View {
    let phosphor: PhosphorColor
    @ObservedObject var visionManager: VisionManager
    @ObservedObject var intelligenceEngine: ComputerIntelligenceEngine
    let onNavigateToConsole: () -> Void

    @State private var scanLineOffset: CGFloat = -140
    @State private var analysisOutput: String = ""

    public init(
        phosphor: PhosphorColor,
        visionManager: VisionManager,
        intelligenceEngine: ComputerIntelligenceEngine,
        onNavigateToConsole: @escaping () -> Void
    ) {
        self.phosphor = phosphor
        self.visionManager = visionManager
        self.intelligenceEngine = intelligenceEngine
        self.onNavigateToConsole = onNavigateToConsole
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Viewfinder HUD Header
            HStack {
                Text("OPTICAL SENSOR FEED // HUD 2.4")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(phosphor.primaryColor)
                    .crtGlow(color: phosphor.glowColor, radius: 2)

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(visionManager.cameraActive ? Color.green : Color.yellow)
                        .frame(width: 6, height: 6)
                    Text(visionManager.cameraActive ? "LIVE CAMERA" : "SIMULATED TARGET")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(phosphor.dimColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            // The Viewfinder Screen Area
            ZStack {
                // Background screen
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(phosphor.primaryColor.opacity(0.4), lineWidth: 1.5)
                    )

                // ASCII / Visual Representation of Target
                if let target = visionManager.selectedSimulatedTarget {
                    VStack(spacing: 8) {
                        Text(target.visualAscii)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(phosphor.primaryColor)
                            .crtGlow(color: phosphor.glowColor, radius: 4)
                            .multilineTextAlignment(.center)

                        Text("[ ENTITY: \(target.name.uppercased()) ]")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(phosphor.dimColor)
                    }
                }

                // HUD Reticle Overlay
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height

                    // Center Crosshair
                    Path { p in
                        p.move(to: CGPoint(x: w/2 - 25, y: h/2))
                        p.addLine(to: CGPoint(x: w/2 + 25, y: h/2))
                        p.move(to: CGPoint(x: w/2, y: h/2 - 25))
                        p.addLine(to: CGPoint(x: w/2, y: h/2 + 25))
                    }
                    .stroke(phosphor.primaryColor.opacity(0.6), lineWidth: 1)

                    // Reticle Circle
                    Circle()
                        .stroke(phosphor.primaryColor.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .frame(width: 80, height: 80)
                        .position(x: w/2, y: h/2)

                    // Corner Brackets
                    cornerBracket(x: 16, y: 16, dx: 20, dy: 20)
                    cornerBracket(x: w - 16, y: 16, dx: -20, dy: 20)
                    cornerBracket(x: 16, y: h - 16, dx: 20, dy: -20)
                    cornerBracket(x: w - 16, y: h - 16, dx: -20, dy: -20)

                    // Animated Scanning Beam
                    if visionManager.isAnalyzing {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.clear, phosphor.primaryColor.opacity(0.7), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 6)
                            .offset(y: scanLineOffset)
                    }
                }
            }
            .frame(height: 220)
            .padding(.horizontal, 16)

            // Target Selector Carousel
            VStack(alignment: .leading, spacing: 6) {
                Text("SELECT OPTICAL TARGET:")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(phosphor.dimColor)
                    .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(visionManager.simulatedTargets) { target in
                            let isSelected = visionManager.selectedSimulatedTarget?.id == target.id
                            Button(action: {
                                SoundSynthesizer.shared.playKeyClick()
                                visionManager.selectedSimulatedTarget = target
                            }) {
                                Text(target.name)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(isSelected ? phosphor.backgroundColor : phosphor.primaryColor)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(isSelected ? phosphor.primaryColor : phosphor.backgroundColor)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .stroke(phosphor.primaryColor, lineWidth: 1)
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }

            // Optical Telemetry Readout Box
            HStack(spacing: 12) {
                telemetryItem(title: "LUX", value: "\(Int(visionManager.ambientLux))")
                telemetryItem(title: "MOTION", value: String(format: "%.2f", visionManager.frameMotionVariance))
                telemetryItem(
                    title: "CONFIDENCE",
                    value: "\(Int((visionManager.selectedSimulatedTarget?.defaultConfidence ?? 0.85) * 100))%"
                )
                telemetryItem(
                    title: "THREAT",
                    value: (visionManager.selectedSimulatedTarget?.threatLevel ?? .low).rawValue.components(separatedBy: " ").first ?? "LOW"
                )
            }
            .padding(.horizontal, 16)

            Spacer()

            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {
                    triggerTargetAnalysis()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "waveform.path.badge.plus")
                        Text(visionManager.isAnalyzing ? "SCANNING..." : "ANALYZE TARGET")
                    }
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(phosphor.backgroundColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(phosphor.primaryColor)
                    )
                }
                .buttonStyle(.plain)
                .disabled(visionManager.isAnalyzing)

                Button(action: {
                    onNavigateToConsole()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "terminal")
                        Text("CONSOLE")
                    }
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(phosphor.primaryColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(phosphor.primaryColor, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }

    private func cornerBracket(x: CGFloat, y: CGFloat, dx: CGFloat, dy: CGFloat) -> some View {
        Path { p in
            p.move(to: CGPoint(x: x, y: y + dy))
            p.addLine(to: CGPoint(x: x, y: y))
            p.addLine(to: CGPoint(x: x + dx, y: y))
        }
        .stroke(phosphor.primaryColor.opacity(0.8), lineWidth: 1.8)
    }

    private func telemetryItem(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(phosphor.dimColor)
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(phosphor.primaryColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(phosphor.primaryColor.opacity(0.2), lineWidth: 1)
        )
    }

    private func triggerTargetAnalysis() {
        SoundSynthesizer.shared.playScan()
        withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: true)) {
            scanLineOffset = 100
        }

        intelligenceEngine.process(userInput: "Computer, what is that?") { _ in
            withAnimation {
                self.scanLineOffset = -140
            }
        }
    }
}
