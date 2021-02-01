// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Fisticuffs",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "Fisticuffs",
            targets: ["Fisticuffs"]),
    ],
    dependencies: [
        .package(name: "Quick", url: "https://github.com/Quick/Quick.git", from: Version(3, 0, 0)),
        .package(name: "Nimble", url: "https://github.com/Quick/Nimble.git", from: Version(9, 0, 0)),
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
