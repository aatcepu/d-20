import SwiftUI

public struct CRTMonitorFrame<Content: View>: View {
    let phosphor: PhosphorColor
    let isProcessing: Bool
    let content: Content

    @State private var ledPulse: Bool = false

    public init(
        phosphor: PhosphorColor = .green,
        isProcessing: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.phosphor = phosphor
        self.isProcessing = isProcessing
        self.content = content()
    }

    public var body: some View {
        ZStack {
            // Vintage Outer Monitor Bezel (dark charcoal / vintage computer composite)
            Color(red: 0.12, green: 0.13, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Bezel Header with screws and vintage badge
                HStack {
                    // Vintage screw
                    Circle()
                        .stroke(Color.gray.opacity(0.6), lineWidth: 1.5)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Rectangle()
                                .fill(Color.gray.opacity(0.8))
                                .frame(width: 6, height: 1)
                        )

                    Spacer()

                    // Metal badge
                    HStack(spacing: 6) {
                        Text("★")
                            .font(.system(size: 9))
                            .foregroundColor(Color.orange.opacity(0.9))
                        Text("COURAGE COMPUTER  MODEL-99")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(white: 0.75))
                            .tracking(2.0)
                        Text("★")
                            .font(.system(size: 9))
                            .foregroundColor(Color.orange.opacity(0.9))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0.18, green: 0.19, blue: 0.18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                    )

                    Spacer()

                    // Power & Drive Status LEDs
                    HStack(spacing: 12) {
                        // Power LED (Green)
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 7, height: 7)
                                .shadow(color: Color.green, radius: ledPulse ? 4 : 2)
                            Text("PWR")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.gray)
                        }

                        // Drive Activity LED (Amber)
                        HStack(spacing: 4) {
                            Circle()
                                .fill(isProcessing ? Color.orange : Color.orange.opacity(0.2))
                                .frame(width: 7, height: 7)
                                .shadow(color: Color.orange, radius: isProcessing ? 5 : 0)
                            Text("DRV")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)

                // The CRT Screen Glass
                ZStack {
                    // Curved screen background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(phosphor.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(white: 0.22), lineWidth: 4)
                        )
                        .shadow(color: Color.black, radius: 10, x: 0, y: 4)

                    // Inner Screen Content
                    content
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    // CRT Scanlines
                    CRTScanlines(opacity: 0.22)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    // CRT Vignette (barrel distortion / curvature shadow)
                    CRTVignette()
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Glass Glare / Curved reflection
                    VStack {
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.06),
                                Color.white.opacity(0.01),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 90)
                        .allowsHitTesting(false)
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                ledPulse = true
            }
        }
    }
}
