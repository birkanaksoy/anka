// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AnkaShared",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(name: "AnkaShared", targets: ["AnkaShared"])
    ],
    targets: [
        .target(
            name: "AnkaShared",
            path: "Sources/AnkaShared"
        ),
        .testTarget(
            name: "AnkaSharedTests",
            dependencies: ["AnkaShared"],
            path: "Tests/AnkaSharedTests"
        )
    ]
)
