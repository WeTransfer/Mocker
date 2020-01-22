// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "Mocker",
                      platforms: [
                        .macOS(.v10_15),
                        .iOS(.v10),
                        .tvOS(.v12),
                        .watchOS(.v6)],
                      products: [
                        .library(name: "DangerDeps", type: .dynamic, targets: ["DangerDependencies"]), // dev
                        .library(name: "Mocker", targets: ["Mocker"])
                        ],
                      dependencies: [
                        .package(url: "https://github.com/danger/swift", from: "3.0.0"), // dev
                        .package(path: "Submodules/WeTransfer-iOS-CI/Danger-Swift") // dev
                        ],
                      targets: [
                        .target(name: "Mocker", path: "Sources"),
                        .target(name: "DangerDependencies", dependencies: ["Danger", "WeTransferPRLinter"], path: "Submodules/WeTransfer-iOS-CI/Danger-Swift", sources: ["DangerFakeSource.swift"]) // dev
                        ],
                      swiftLanguageVersions: [.v5])
