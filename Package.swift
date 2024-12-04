// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Fisticuffs",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Fisticuffs",
            targets: ["Fisticuffs"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "7.3.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.0.0"),
    ],
    targets: [
        .target(
            name: "Fisticuffs",
            dependencies: []),
        .testTarget(
            name: "FisticuffsTests",
            dependencies: [
                "Fisticuffs",
                "Quick",
                "Nimble",
            ]),
    ]
)
