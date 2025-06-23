// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OFREPClientProvider",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14),
        .macOS(.v12),
        .watchOS(.v7),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OFREPClientProvider",
            targets: ["OFREPClientProvider"]),
    ],
    dependencies: [
        .package(url: "https://github.com/open-feature/swift-sdk.git", from: "0.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OFREPClientProvider",
            dependencies: [
                .product(name: "OpenFeature", package: "swift-sdk")
            ]
        ),
        .testTarget(
            name: "OFREPClientProviderTests",
            dependencies: ["OFREPClientProvider"]
        ),
    ]
)
