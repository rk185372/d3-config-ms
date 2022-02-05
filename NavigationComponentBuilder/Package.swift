// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NavigationComponentBuilder",
    dependencies: [
        .package(
            url: "https://github.com/johnsundell/files.git",
            from: "2.3.0"
        ),
        .package(
            url: "https://github.com/kylef/Commander.git",
            from: "0.9.0"
        ),
        .package(
            url: "https://github.com/kylef/PathKit.git",
            from: "0.9.2"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "2.0.0"
        ),
        .package(
            url: "https://github.com/stencilproject/Stencil.git",
            from: "0.13.0"
        )
    ],
    targets: [
        .target(
            name: "NavigationComponentBuilder",
            dependencies: ["Commander", "PathKit", "NavigationComponentBuilderCore"]),
        .target(
            name: "NavigationComponentBuilderCore",
            dependencies: ["Files", "PathKit", "Stencil", "Yams"]
        )
    ]
)
