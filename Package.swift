// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mocker",
    products: [
        .library(
            name: "Mocker",
            targets: ["Mocker"]),
    ],
    targets: [
        .target(
            name: "Mocker",
            path: "Sources")
    ],
    swiftLanguageVersions: [.v5]
)
