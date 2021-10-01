// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "TypedJSON",
    products: [
        .library(name: "TypedJSON", targets: ["TypedJSON"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "TypedJSON",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "TypedJSONTests",
            dependencies: ["TypedJSON"],
            resources: [
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
