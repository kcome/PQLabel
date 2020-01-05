// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "PQLabel",
    platforms: [
        .iOS(SupportedPlatform.IOSVersion.v10)
    ],
    products: [
        .library(
            name: "PQLabel",
            type: .dynamic,
            targets: ["PQLabel"])
    ],
    targets: [
        .target(
            name: "PQLabel",
            path: "Sources/PQLabel")
    ]
)
