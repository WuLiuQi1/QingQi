// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "QingQiCore",
    products: [.library(name: "QingQiCore", targets: ["QingQiCore"])],
    targets: [
        .target(name: "QingQiCore"),
        .testTarget(name: "QingQiCoreTests", dependencies: ["QingQiCore"])
    ]
)
