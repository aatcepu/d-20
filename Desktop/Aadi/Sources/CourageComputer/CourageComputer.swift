import SwiftUI

@main
struct CourageComputerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 820, height: 600)
        #endif
    }
}
