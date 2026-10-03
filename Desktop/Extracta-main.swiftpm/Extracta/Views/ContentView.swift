// ContentView.swift
// Extracta — Root view (Phase 1 verified, Phase 2 integrated, Phase 3 wired)

import SwiftUI

struct ContentView: View {

    /// Shared ViewModel — owned here so toolbar and canvas share the same state.
    @StateObject private var canvasViewModel = CanvasViewModel()

    var body: some View {
        NavigationStack {
            ScreenshotCanvas(externalViewModel: canvasViewModel)
                .navigationTitle("Extracta")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            canvasViewModel.resetSweep()
                        } label: {
                            Image(systemName:
                                canvasViewModel.sweepProgress > 0
                                    ? "arrow.counterclockwise"
                                    : "wand.and.stars"
                            )
                            .foregroundStyle(
                                canvasViewModel.sweepProgress > 0
                                    ? Color.blue
                                    : Color.primary
                            )
                            .animation(.easeInOut(duration: 0.2),
                                       value: canvasViewModel.sweepProgress)
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
