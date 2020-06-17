// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Imaginary",
    // platforms: [.iOS("8.0"), .macOS("10.10"), .tvOS("9.0"), .watchOS("2.0")],
    dependencies: [
        .package(url: "https://github.com/kientux/Cache.git", .upToNextMajor(from: "5.3.0")),
    ],
    products: [
        .library(name: "Imaginary", targets: ["Imaginary"])
    ],
    targets: [
        .target(
            name: "Imaginary",
            path: "Sources",
            dependencies: [
                "Cache",
            ],
        )
    ]
)
