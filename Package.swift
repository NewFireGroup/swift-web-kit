// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-web-kit",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftWebKit",
            targets: ["SwiftWebKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/NewFireGroup/swift-newfire-foundation.git", from: "1.0.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftWebKit",
            dependencies: [
                .product(name: "NFGFoundation", package : "swift-newfire-foundation")
            ]
        ),
        .testTarget(
            name: "SwiftWebKitTests",
            dependencies: ["SwiftWebKit"]
        ),
    ]
)
