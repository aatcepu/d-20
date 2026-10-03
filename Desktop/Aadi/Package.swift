// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CourageComputer",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .executable(
            name: "CourageComputer",
            targets: ["CourageComputer"]
        )
    ],
    targets: [
        .executableTarget(
            name: "CourageComputer",
            path: "Sources/CourageComputer"
        ),
        .testTarget(
            name: "CourageComputerTests",
            dependencies: ["CourageComputer"],
            path: "Tests/CourageComputerTests"
        )
    ]
)
