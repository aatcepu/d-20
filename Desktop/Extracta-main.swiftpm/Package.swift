// swift-tools-version: 5.9
// Extracta — Package.swift (Swift Playgrounds App)

import PackageDescription

let package = Package(
    name: "Extracta",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        // .iOSApplication is required for Swift Playgrounds 4 to treat
        // this as a runnable iOS app — not a library or CLI tool.
        .iOSApplication(
            name: "Extracta",
            targets: ["Extracta"],
            bundleIdentifier: "com.tamajit.extracta",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .photo),
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeLeft,
                .landscapeRight,
                .portraitUpsideDown
            ]
        )
    ],
    targets: [
        // .executableTarget is correct here — @main in ExtractaApp.swift
        // provides the single entry point Swift needs.
        .executableTarget(
            name: "Extracta",
            path: "."   // All source subdirs (App/, Views/, etc.) live at root
        )
    ]
)
