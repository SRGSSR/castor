// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Castor",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "Castor",
            targets: ["Castor"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SRGSSR/google-cast-sdk.git", .upToNextMinor(from: "4.8.3"))
    ],
    targets: [
        .target(
            name: "Castor",
            dependencies: [
                .product(name: "GoogleCast", package: "google-cast-sdk")
            ],
            resources: [
                .process("Resources")
            ],
            plugins: [
                .plugin(name: "CastorPackageInfoPlugin")
            ]
        ),
        .binaryTarget(name: "CastorPackageInfo", path: "Artifacts/PackageInfo.artifactbundle"),
        .plugin(
            name: "CastorPackageInfoPlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "CastorPackageInfo")
            ]
        ),
        .testTarget(
            name: "CastorTests",
            dependencies: [
                .target(name: "Castor")
            ]
        )
    ]
)
