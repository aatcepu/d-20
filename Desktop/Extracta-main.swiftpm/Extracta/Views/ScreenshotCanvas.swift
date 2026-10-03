// ScreenshotCanvas.swift
// Extracta — Phase 3: Screenshot canvas with sweep gesture layer
//
// Design contract:
//   • Loads "sample_screenshot" from Assets; falls back to a generated placeholder
//   • GeometryReader fills available space while preserving a fixed card aspect ratio
//   • Adapts layout for iPhone (compact) and iPad (regular)
//   • Accepts an optional externally-owned CanvasViewModel so ContentView's
//     toolbar and the canvas share the same sweep state.

import SwiftUI
import UIKit

// ---------------------------------------------------------------------------
// MARK: - ScreenshotCanvas
// ---------------------------------------------------------------------------

struct ScreenshotCanvas: View {

    /// Pass a ViewModel from the parent when you need shared state (e.g. toolbar button).
    /// If nil, the canvas creates its own private instance.
    var externalViewModel: CanvasViewModel? = nil

    private let imageName = "sample_screenshot"
    @Environment(\.horizontalSizeClass) private var hSizeClass

    /// Internal fallback — used only when no external VM is provided.
    @StateObject private var _internalVM = CanvasViewModel()

    /// Resolves to whichever VM is in use.
    private var viewModel: CanvasViewModel { externalViewModel ?? _internalVM }

    // -----------------------------------------------------------------------
    // MARK: - Body
    // -----------------------------------------------------------------------

    var body: some View {
        GeometryReader { geo in
            let isRegular  = hSizeClass == .regular
            let cardSize   = canvasRect(in: geo.size, regular: isRegular)
            let centerX    = geo.size.width  / 2
            let centerY    = geo.size.height / 2

            ZStack {
                // ── Background ─────────────────────────────────────────────
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                // ── Card shell ─────────────────────────────────────────────
                RoundedRectangle(cornerRadius: isRegular ? 24 : 18, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.12),
                            radius: isRegular ? 24 : 14, x: 0, y: 6)
                    .frame(width: cardSize.width, height: cardSize.height)
                    .position(x: centerX, y: centerY)

                // ── Screenshot image ────────────────────────────────────────
                screenshotImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: isRegular ? 20 : 14,
                                               style: .continuous))
                    .padding(isRegular ? 16 : 10)
                    .frame(width: cardSize.width, height: cardSize.height)
                    .position(x: centerX, y: centerY)

                // ── Phase 3: Sweep gesture overlay ─────────────────────────
                SweepOverlay(canvasSize: cardSize, viewModel: viewModel)
                    .position(x: centerX, y: centerY)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // -----------------------------------------------------------------------
    // MARK: - Helpers
    // -----------------------------------------------------------------------

    private func canvasRect(in available: CGSize, regular: Bool) -> CGSize {
        let hPad: CGFloat = regular ? 120 : 32
        let vPad: CGFloat = regular ? 80  : 48

        let maxW = available.width  - hPad
        let maxH = available.height - vPad
        let clampedW = min(maxW, regular ? 680 : maxW)

        let aspect: CGFloat = 3.0 / 5.0
        let cardH = min(maxH, clampedW / aspect)
        let cardW = cardH * aspect
        return CGSize(width: cardW, height: cardH)
    }

    private var screenshotImage: Image {
        UIImage(named: imageName) != nil
            ? Image(imageName)
            : Image(uiImage: .placeholderScreenshot())
    }
}

// ---------------------------------------------------------------------------
// MARK: - Placeholder generator
// ---------------------------------------------------------------------------

private extension UIImage {

    static func placeholderScreenshot(
        size: CGSize = CGSize(width: 390, height: 650)
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let bounds = CGRect(origin: .zero, size: size)

            UIColor.systemBackground.setFill()
            UIBezierPath(roundedRect: bounds, cornerRadius: 0).fill()

            UIColor.systemGray5.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: 0,
                                     width: size.width, height: 44)).fill()

            UIColor.systemGray6.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: 44,
                                     width: size.width, height: 44)).fill()

            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
            NSAttributedString(string: "Sample Screenshot", attributes: titleAttr)
                .drawCentered(in: CGRect(x: 0, y: 44, width: size.width, height: 44))

            let rowAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let rows = [
                "🗓  Team standup at 10:00 AM tomorrow",
                "📦  Deploy release candidate by Friday",
                "✅  Review PR #42 before EOD",
                "💬  Call with client — confirm agenda",
                "📝  Update project README and docs",
                "🔔  Reminder: renew domain certificate",
                "📊  Send weekly metrics to Priya",
            ]
            var y: CGFloat = 110
            for row in rows {
                NSAttributedString(string: row, attributes: rowAttr)
                    .draw(at: CGPoint(x: 20, y: y))
                let sep = UIBezierPath()
                sep.move(to:    CGPoint(x: 20,              y: y + 24))
                sep.addLine(to: CGPoint(x: size.width - 20, y: y + 24))
                sep.lineWidth = 0.5
                UIColor.separator.setStroke()
                sep.stroke()
                y += 40
            }

            NSAttributedString(
                string: "Sweep to extract →",
                attributes: [
                    .font: UIFont.italicSystemFont(ofSize: 12),
                    .foregroundColor: UIColor.tertiaryLabel
                ]
            ).drawCentered(in: CGRect(x: 0, y: size.height - 40,
                                     width: size.width, height: 30))
        }
    }
}

private extension NSAttributedString {
    func drawCentered(in rect: CGRect) {
        let s = self.size()
        draw(at: CGPoint(
            x: rect.minX + (rect.width  - s.width)  / 2,
            y: rect.minY + (rect.height - s.height) / 2
        ))
    }
}

// ---------------------------------------------------------------------------
// MARK: - Previews
// ---------------------------------------------------------------------------

#Preview("iPhone 15 Pro") {
    ScreenshotCanvas()
}

#Preview("iPad (regular)") {
    ScreenshotCanvas()
        .environment(\.horizontalSizeClass, .regular)
}
