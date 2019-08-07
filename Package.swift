// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mocker",
    platforms: [
        .macOS(.v10_14), .iOS(.v12), .tvOS(.v12), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Mocker",
            targets: ["Mocker"])
    ],
    targets: [
        .target(
            name: "Mocker",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "MockerTests",
            dependencies: ["Mocker"],
            path: "MockerTests")
    ],
    swiftLanguageVersions: [.v5]
)
