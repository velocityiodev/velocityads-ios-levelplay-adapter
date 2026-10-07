// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "VelocityAdsLevelPlayAdapter",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "VelocityAdsLevelPlayAdapter",
            targets: ["VelocityAdsLevelPlayAdapter"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ironsource-mobile/LevelPlay-Swift-Package",
            .upToNextMajor(from: "9.6.1")
        ),
        .package(
            url: "https://github.com/velocityiodev/velocityads-ios-sdk",
            .upToNextMinor(from: "0.11.0")
        )
    ],
    targets: [
        .target(
            name: "VelocityAdsLevelPlayAdapter",
            dependencies: [
                .product(name: "UnityMediationSDK", package: "LevelPlay-Swift-Package"),
                .product(name: "VelocityAdsSDK", package: "velocityads-ios-sdk")
            ]
        ),
        .testTarget(
            name: "VelocityAdsLevelPlayAdapterTests",
            dependencies: [
                "VelocityAdsLevelPlayAdapter",
                .product(name: "UnityMediationSDK", package: "LevelPlay-Swift-Package"),
                .product(name: "VelocityAdsSDK", package: "velocityads-ios-sdk")
            ]
        )
    ]
)
