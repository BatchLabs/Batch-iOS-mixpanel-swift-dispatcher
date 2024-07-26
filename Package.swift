// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "BatchMixpanelSwiftDispatcher",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "BatchMixpanelSwiftDispatcher",
            targets: ["BatchMixpanelSwiftDispatcher"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mixpanel/mixpanel-swift", from: "4.3.0"),
        .package(url: "https://github.com/BatchLabs/Batch-iOS-SDK", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "BatchMixpanelSwiftDispatcher",
            dependencies: ["Mixpanel", "Batch"],
            path: "BatchMixpanelSwiftDispatcher/Classes"
            ),
    ]
)
