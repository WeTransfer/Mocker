// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
// We're hiding dev, test, and danger dependencies with // dev to make sure they're not fetched by users of this package.

import PackageDescription

let package = Package(name: "Mocker",
                      platforms: [
                        .macOS(.v10_15),
                        .iOS(.v10),
                        .tvOS(.v12),
                        .watchOS(.v6)],
                      products: [
                        // dev .library(name: "DangerDeps", type: .dynamic, targets: ["DangerDependencies"]),
                        .library(name: "Mocker", targets: ["Mocker"])
                        ],
                      dependencies: [
                        // dev .package(name: "danger-swift", url: "https://github.com/danger/swift", from: "3.12.1"),
                        // dev .package(name: "WeTransferPRLinter", path: "Submodules/WeTransfer-iOS-CI/WeTransferPRLinter")
                        ],
                      targets: [
                        // dev .target(name: "DangerDependencies", dependencies: [
                        // dev     .product(name: "Danger", package: "danger-swift"),
                        // dev     .product(name: "WeTransferPRLinter", package: "WeTransferPRLinter")
                        // dev ], path: "Submodules/WeTransfer-iOS-CI/DangerFakeSources", sources: ["DangerFakeSource.swift"]),
                        .target(name: "Mocker", path: "Sources"),
                        .testTarget(name: "MockerTests", dependencies: ["Mocker"], path: "MockerTests")
                        ],
                      swiftLanguageVersions: [.v5])
