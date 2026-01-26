// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Castor",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Castor",
            targets: ["Castor"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SRGSSR/google-cast-sdk.git", .upToNextMinor(from: "4.8.3")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "Castor",
            dependencies: [
                .product(name: "GoogleCast", package: "google-cast-sdk"),
                .product(name: "OrderedCollections", package: "swift-collections")
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
