// SweepOverlay.swift
// Extracta — Phase 3: Sweep gesture interaction layer
//
// Design contract:
//   • Transparent overlay that sits on top of the screenshot card
//   • DragGesture tracks left-to-right drag, normalised to 0–1
//   • Visual feedback:
//       – Blue translucent fill grows from the leading edge
//       – A glowing vertical line rides exactly at the fill's right edge
//       – Percentage label anchored to the sweep line for live feedback
//   • Idle state shows a subtle hint pill ("Sweep to extract")
//   • Completion burst: haptic + brief white flash when sweep finishes
//   • Phase 4 hook clearly marked at gesture end

import SwiftUI

// ---------------------------------------------------------------------------
// MARK: - SweepOverlay
// ---------------------------------------------------------------------------

struct SweepOverlay: View {

    // ── Inputs ───────────────────────────────────────────────────────────
    let canvasSize: CGSize
    @ObservedObject var viewModel: CanvasViewModel

    // ── Internal drag state ──────────────────────────────────────────────
    @State private var dragStartX: CGFloat   = 0
    @State private var hasBegunDrag: Bool    = false
    @State private var showCompletionFlash:  Bool = false

    // Haptic engine — created once, reused.
    private let impactHaptic  = UIImpactFeedbackGenerator(style: .light)
    private let successHaptic = UINotificationFeedbackGenerator()

    // ── Derived geometry ─────────────────────────────────────────────────
    private var fillWidth:  CGFloat { canvasSize.width * viewModel.sweepProgress }
    private var lineOffset: CGFloat { fillWidth - 1 }   // line sits at fill's right edge

    // -----------------------------------------------------------------------
    // MARK: - Body
    // -----------------------------------------------------------------------

    var body: some View {
        ZStack(alignment: .leading) {

            // ── 1. Reveal fill ─────────────────────────────────────────────
            sweepFill

            // ── 2. Leading-edge glow line + percentage label ───────────────
            if viewModel.isSweeping || viewModel.sweepProgress > 0 {
                sweepLine
                progressLabel
            }

            // ── 3. Idle hint pill ──────────────────────────────────────────
            if !viewModel.isSweeping && viewModel.sweepProgress == 0 {
                hintLabel
            }

            // ── 4. Completion flash ────────────────────────────────────────
            if showCompletionFlash {
                Color.white.opacity(0.18)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .contentShape(Rectangle())          // ensure full hit-test area
        .gesture(sweepGesture)
        // Fix: use onChange(of:perform:) — the single-closure form is
        // deprecated in Swift 5.9 / Xcode 15 and causes a compile error.
        .onChange(of: viewModel.didCompleteSweep, perform: { completed in
            if completed { handleCompletion() }
        })
    }

    // -----------------------------------------------------------------------
    // MARK: - Visual components
    // -----------------------------------------------------------------------

    /// Blue translucent fill that grows left → right as progress increases.
    private var sweepFill: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.26),
                Color.blue.opacity(0.10)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: max(fillWidth, 0), height: canvasSize.height)
        .frame(maxWidth: .infinity, alignment: .leading)   // pin to leading edge
        .animation(
            viewModel.isSweeping
                ? .interactiveSpring(response: 0.20, dampingFraction: 0.80)
                : .spring(response: 0.32, dampingFraction: 0.72),
            value: viewModel.sweepProgress
        )
    }

    /// Vertical glowing line pinned to the right edge of the fill.
    private var sweepLine: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.0),
                Color.blue.opacity(1.0),
                Color.blue.opacity(0.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(width: 2.5, height: canvasSize.height)
        .shadow(color: .blue.opacity(0.6), radius: 8, x: 0, y: 0)
        .offset(x: max(lineOffset, 0))
        .animation(
            viewModel.isSweeping
                ? .interactiveSpring(response: 0.20, dampingFraction: 0.80)
                : .spring(response: 0.32, dampingFraction: 0.72),
            value: viewModel.sweepProgress
        )
    }

    /// Percentage readout that follows the sweep line.
    private var progressLabel: some View {
        let pct = Int(viewModel.sweepProgress * 100)
        let labelWidth: CGFloat = 44
        // Keep label visible: clamp so it never overflows the canvas bounds.
        let clampedX = min(max(fillWidth - labelWidth / 2, 0),
                          canvasSize.width - labelWidth)
        return Text("\(pct)%")
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(.blue)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.ultraThinMaterial, in: Capsule())
            .frame(width: labelWidth)
            .offset(x: clampedX, y: -(canvasSize.height / 2 - 20))
            .animation(
                .interactiveSpring(response: 0.20, dampingFraction: 0.80),
                value: viewModel.sweepProgress
            )
    }

    /// Hint pill shown when idle.
    private var hintLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: "hand.draw")
                .font(.system(size: 13, weight: .medium))
            Text("Sweep to extract")
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    // -----------------------------------------------------------------------
    // MARK: - Gesture
    // -----------------------------------------------------------------------

    private var sweepGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .local)
            .onChanged { value in
                if !hasBegunDrag {
                    dragStartX  = value.startLocation.x
                    hasBegunDrag = true
                    viewModel.beginSweep()
                    impactHaptic.impactOccurred()
                }
                let travel   = value.location.x - dragStartX
                let progress = travel / canvasSize.width
                viewModel.updateSweep(progress: progress)
            }
            .onEnded { _ in
                hasBegunDrag = false
                viewModel.endSweep()
                // ── Phase 4 hook ──────────────────────────────────────────
                // Fires *after* endSweep() sets didCompleteSweep = true if
                // the threshold was reached. onChange(of:perform:) above
                // will call handleCompletion() at that point.
            }
    }

    // -----------------------------------------------------------------------
    // MARK: - Completion handling
    // -----------------------------------------------------------------------

    private func handleCompletion() {
        successHaptic.notificationOccurred(.success)
        withAnimation(.easeIn(duration: 0.12)) { showCompletionFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.easeOut(duration: 0.20)) { showCompletionFlash = false }
        }
    }
}

// ---------------------------------------------------------------------------
// MARK: - Previews
// ---------------------------------------------------------------------------

#Preview("Idle") {
    SweepOverlay(
        canvasSize: CGSize(width: 320, height: 560),
        viewModel: CanvasViewModel()
    )
    .background(Color(.secondarySystemGroupedBackground))
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .padding()
}

#Preview("In progress – 55%") {
    let vm = CanvasViewModel()
    vm.updateSweep(progress: 0.55)
    return SweepOverlay(
        canvasSize: CGSize(width: 320, height: 560),
        viewModel: vm
    )
    .background(Color(.secondarySystemGroupedBackground))
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .padding()
}

#Preview("Complete – 100%") {
    let vm = CanvasViewModel()
    vm.updateSweep(progress: 1.0)
    return SweepOverlay(
        canvasSize: CGSize(width: 320, height: 560),
        viewModel: vm
    )
    .background(Color(.secondarySystemGroupedBackground))
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .padding()
}
