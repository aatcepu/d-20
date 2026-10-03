// swift-tools-version: 5.9

// WARNING:
// This file is generated and managed by Apple Swift Playgrounds / Xcode.
// It is configured as a standalone Swift Student Challenge Playgrounds App.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Courage Computer",
    platforms: [
        .iOS("17.0"),
        .macOS("14.0")
    ],
    products: [
        .iOSApplication(
            name: "Courage Computer",
            targets: ["CourageComputer"],
            bundleIdentifier: "com.courage.computer",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .desktopComputer),
            accentColor: .presetColor(.green),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .camera(purposeString: "Courage Computer requires optical sensor access to analyze anomalies and detect environmental threats."),
                .microphone(purposeString: "Courage Computer requires auditory sensor access to detect sound anomalies and voice input."),
                .speechRecognition(purposeString: "Courage Computer processes speech locally to convert verbal queries.")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "CourageComputer",
            path: "Sources"
        )
    ]
)
