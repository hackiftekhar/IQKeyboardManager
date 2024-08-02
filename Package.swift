// swift-tools-version:5.7

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
    dependencies: [
        .package(url: "https://github.com/hackiftekhar/IQKeyboardNotification.git", from: "1.0.1"),
        .package(url: "https://github.com/hackiftekhar/IQTextInputViewNotification.git", from: "1.0.3"),
    ],
    targets: [
        .target(name: "IQKeyboardManagerSwift",
                dependencies: ["IQKeyboardNotification", "IQTextInputViewNotification"],
            path: "IQKeyboardManagerSwift",
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
