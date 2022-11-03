// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mocker",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v11),
        .tvOS(.v12),
        .watchOS(.v6)],
    products: [
        .library(name: "Mocker", targets: ["Mocker"])
    ],
    targets: [
        .target(name: "Mocker"),
        .testTarget(
            name: "MockerTests",
            dependencies: ["Mocker"],
            resources: [
                .process("Resources")
            ]
        )
    ],
    swiftLanguageVersions: [.v5])
