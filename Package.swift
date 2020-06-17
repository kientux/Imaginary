// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Imaginary",
    // platforms: [.iOS("8.0"), .macOS("10.10"), .tvOS("9.0"), .watchOS("2.0")],
    products: [
        .library(name: "Imaginary", targets: ["Imaginary"])
    ],
    dependencies: [
        .package(url: "https://github.com/kientux/Cache.git", .upToNextMajor(from: "5.3.0")),
    ],
    targets: [
        .target(
            name: "Imaginary",
            dependencies: [
                "Cache",
            ],
            path: "Sources/Shared"
        )
    ]
)
