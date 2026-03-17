// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SMPPayment",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "SMPPayment",
            targets: ["SMPPayment"]
        ),
    ],
    targets: [
        .target(
            name: "SMPPayment",
            path: "Sources/SMPPayment",
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedFramework("UIKit"),
            ]
        ),
    ]
)
