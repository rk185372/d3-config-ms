// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StyleValidator",
    dependencies: [
        .package(
            url: "https://github.com/johnsundell/files.git",
            from: "2.2.1"
        ),
        .package(
            url: "https://github.com/kylef/Commander.git",
            from: "0.8.0"
        ),
        .package(
            url: "https://github.com/kylef/PathKit.git",
            from: "0.9.2"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "1.0.1"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "StyleValidator",
            dependencies: ["StyleValidatorCore", "Commander", "PathKit"]),
        .target(
            name: "StyleValidatorCore",
            dependencies: ["Files", "PathKit", "Yams"]),
    ]
)
