import SwiftUI

public enum PhosphorColor: String, CaseIterable, Identifiable, Codable {
    case green = "PHOSPHOR GREEN (P1)"
    case amber = "AMBER MONOCHROME (P3)"
    case ghostBlue = "GHOST BLUE (P4)"

    public var id: String { rawValue }

    public var primaryColor: Color {
        switch self {
        case .green:
            return Color(red: 0.20, green: 1.0, blue: 0.35)
        case .amber:
            return Color(red: 1.0, green: 0.70, blue: 0.05)
        case .ghostBlue:
            return Color(red: 0.40, green: 0.85, blue: 1.0)
        }
    }

    public var glowColor: Color {
        switch self {
        case .green:
            return Color(red: 0.10, green: 0.80, blue: 0.20).opacity(0.4)
        case .amber:
            return Color(red: 0.90, green: 0.50, blue: 0.0).opacity(0.4)
        case .ghostBlue:
            return Color(red: 0.20, green: 0.60, blue: 0.90).opacity(0.4)
        }
    }

    public var dimColor: Color {
        primaryColor.opacity(0.35)
    }

    public var backgroundColor: Color {
        switch self {
        case .green:
            return Color(red: 0.02, green: 0.05, blue: 0.02)
        case .amber:
            return Color(red: 0.06, green: 0.03, blue: 0.01)
        case .ghostBlue:
            return Color(red: 0.02, green: 0.04, blue: 0.07)
        }
    }
}

public struct CRTScanlines: View {
    let opacity: Double

    public init(opacity: Double = 0.18) {
        self.opacity = opacity
    }

    public var body: some View {
        GeometryReader { geometry in
            let lineSpacing: CGFloat = 3.5
            let count = Int(geometry.size.height / lineSpacing) + 1

            Canvas { context, size in
                for i in 0..<count {
                    let y = CGFloat(i) * lineSpacing
                    let path = Path { p in
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(path, with: .color(Color.black.opacity(opacity)), lineWidth: 1.2)
                }
            }
            .allowsHitTesting(false)
        }
    }
}

public struct CRTVignette: View {
    public init() {}

    public var body: some View {
        RadialGradient(
            gradient: Gradient(colors: [
                Color.clear,
                Color.black.opacity(0.2),
                Color.black.opacity(0.65),
                Color.black.opacity(0.92)
            ]),
            center: .center,
            startRadius: 200,
            endRadius: 650
        )
        .allowsHitTesting(false)
    }
}

public struct CRTFlickerModifier: ViewModifier {
    @State private var flickerOpacity: Double = 1.0

    public func body(content: Content) -> some View {
        content
            .opacity(flickerOpacity)
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 120_000_000)
                    let randomVal = Double.random(in: 0.96...1.0)
                    withAnimation(.easeInOut(duration: 0.08)) {
                        flickerOpacity = randomVal
                    }
                }
            }
    }
}

public struct BlinkingCursor: View {
    let color: Color
    @State private var isVisible: Bool = true

    public init(color: Color = Color(red: 0.20, green: 1.0, blue: 0.35)) {
        self.color = color
    }

    public var body: some View {
        Text("█")
            .foregroundColor(color)
            .opacity(isVisible ? 1.0 : 0.0)
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    isVisible.toggle()
                }
            }
    }
}

public extension View {
    func crtGlow(color: Color, radius: CGFloat = 6) -> some View {
        self
            .shadow(color: color.opacity(0.8), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.4), radius: radius * 2, x: 0, y: 0)
    }

    func crtFlicker() -> some View {
        modifier(CRTFlickerModifier())
    }
}
