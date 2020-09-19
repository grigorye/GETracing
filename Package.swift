// swift-tools-version:5.3
// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "GETracing",
    products: [
        .library(
            name: "GETracing",
            targets: ["GETracing"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "GETracing",
            dependencies: [],
            exclude: ["ModuleExports-GETracing.swift"],
            swiftSettings: [
                .define("GE_TRACE_ENABLED")
            ]
        ),
        .testTarget(
            name: "GETracingTests",
            dependencies: ["GETracing"]
        ),
    ]
)
