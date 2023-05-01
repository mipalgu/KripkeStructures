// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KripkeStructures",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "KripkeStructures",
            targets: ["KripkeStructure"]),
        .library(
            name: "KripkeStructureViews",
            targets: ["KripkeStructureViews"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/mipalgu/swift_helpers", from: "2.0.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.13.3"),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "KripkeStructure",
            dependencies: [.product(name: "SQLite", package: "SQLite.swift")]),
        .target(
            name: "KripkeStructureViews",
            dependencies: [
                "KripkeStructure",
                .product(name: "IO", package: "swift_helpers"),
                .product(name: "SQLite", package: "SQLite.swift")
            ]),
        .testTarget(
            name: "KripkeStructureTests",
            dependencies: ["KripkeStructure"]),
    ]
)
