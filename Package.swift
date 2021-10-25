// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Arc",
    defaultLocalization: "en",
    platforms: [
        // Add support for all platforms starting from a specific version.
        .iOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HMMarkup",
            targets: ["HMMarkup"]),
        .library(
            name: "ArcUIKit",
            targets: ["ArcUIKit"]),
        .library(
            name: "Arc",
            targets: ["Arc"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            name: "BridgeApp-Apple-SDK",
            url: "https://github.com/Sage-Bionetworks/BridgeApp-Apple-SDK.git",
            from: "5.1.4"),
        .package(
            name: "SageResearch",
            url: "https://github.com/Sage-Bionetworks/SageResearch.git",
            from: "4.2.3"),
        .package(
            name: "BridgeSDK",
            url: "https://github.com/Sage-Bionetworks/Bridge-iOS-SDK.git",
            from: "4.4.84"),
        .package(
            name: "JsonModel",
            url: "https://github.com/Sage-Bionetworks/JsonModel-Swift.git",
            from: "1.2.3"),
    ],
    targets: [
        
        .target(
            name: "HMMarkup",
            path: "HMMarkup",
            ),
        
        .target(
            name: "ArcUIKit",
            dependencies: [
                "HMMarkup",
            ],
            path: "ArcUIKit",
            ),

        .target(
            name: "Arc",
            dependencies: [
                .product(name: "BridgeApp", package: "BridgeApp-Apple-SDK"),
                .product(name: "BridgeAppUI", package: "BridgeApp-Apple-SDK"),
                .product(name: "Research", package: "SageResearch"),
                .product(name: "ResearchUI", package: "SageResearch"),
                "BridgeSDK",
                "JsonModel",
                "ArcUIKit",
                "HMMarkup",
            ],
            path: "Arc",
            ),

    ]
)
