// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Communicado",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "Communicado",
            targets: ["Communicado"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Communicado",
            dependencies: [])
    ]
)
