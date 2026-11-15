// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "FamilyCore",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "FamilyCore", targets: ["FamilyCore"])],
    targets: [
        .target(name: "FamilyCore"),
        .testTarget(name: "FamilyCoreTests", dependencies: ["FamilyCore"]),
    ]
)
