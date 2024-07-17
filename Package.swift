// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "IQKeyboardManagerSwift",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "IQKeyboardManagerSwift",
            targets: ["IQKeyboardManagerSwift"]
        )
    ],
    targets: [
        .target(name: "IQKeyboardManagerSwift",
            path: "IQKeyboardManagerSwift",
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
