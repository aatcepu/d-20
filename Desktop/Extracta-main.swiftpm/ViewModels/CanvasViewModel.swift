// CanvasViewModel.swift
// Extracta — Phase 3: Sweep gesture state management
//
// Responsibilities:
//   • Own the sweep lifecycle (begin → update → end → reset)
//   • Expose sweepProgress (0–1) and isSweeping for the view layer
//   • Snap to complete (1.0) when the user crosses the completion threshold
//   • Snap back to idle (0.0) when the drag falls short
//   • Provide a clean hook point for Phase 4 chip extraction

import SwiftUI
import Combine

// ---------------------------------------------------------------------------
// MARK: - CanvasViewModel
// ---------------------------------------------------------------------------

@MainActor
final class CanvasViewModel: ObservableObject {

    // ── Published state ──────────────────────────────────────────────────

    /// Normalised sweep position: 0.0 (idle) → 1.0 (fully swept).
    @Published private(set) var sweepProgress: Double = 0.0

    /// True while the user's finger is actively dragging across the canvas.
    @Published private(set) var isSweeping: Bool = false

    /// True after a successful full sweep — used by Phase 4 to trigger extraction.
    @Published private(set) var didCompleteSweep: Bool = false

    // ── Configuration ────────────────────────────────────────────────────

    /// Fraction of canvas width at which releasing the gesture counts as "complete".
    private let completionThreshold: Double = 0.85

    // -----------------------------------------------------------------------
    // MARK: - Sweep lifecycle
    // -----------------------------------------------------------------------

    /// Call when a drag gesture first fires (onChanged, first event only).
    func beginSweep() {
        guard !isSweeping else { return }
        isSweeping = true
        didCompleteSweep = false
        sweepProgress = 0.0
    }

    /// Call on every onChanged event; progress is already normalised 0–1 by the view.
    func updateSweep(progress: Double) {
        sweepProgress = progress.clamped(to: 0...1)
    }

    /// Call when the drag gesture ends (onEnded).
    func endSweep() {
        isSweeping = false

        if sweepProgress >= completionThreshold {
            // Snap to full — Phase 4 extraction hook fires here.
            withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                sweepProgress = 1.0
            }
            didCompleteSweep = true
            // ── Phase 4 hook ───────────────────────────────────────────────
            // Task { await extractionService.extract(from: currentImage) }
        } else {
            // Incomplete sweep — animate back to idle.
            withAnimation(.easeOut(duration: 0.28)) {
                sweepProgress = 0.0
            }
        }
    }

    /// Hard reset — call when the canvas image changes or the user dismisses results.
    func resetSweep() {
        withAnimation(.easeOut(duration: 0.22)) {
            sweepProgress   = 0.0
            isSweeping      = false
            didCompleteSweep = false
        }
    }
}

// ---------------------------------------------------------------------------
// MARK: - Comparable + Clamped
// ---------------------------------------------------------------------------

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
