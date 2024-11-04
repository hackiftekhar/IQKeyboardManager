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
    dependencies: [
        .package(url: "https://github.com/hackiftekhar/IQKeyboardNotification.git", from: "1.0.5"),
        .package(url: "https://github.com/hackiftekhar/IQTextInputViewNotification.git", from: "1.0.8"),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardToolbarManager.git", from: "1.1.1"),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardReturnManager.git", from: "1.0.5"),
        .package(url: "https://github.com/hackiftekhar/IQTextView.git", from: "1.0.5")
    ],
    targets: [
        .target(name: "IQKeyboardManagerSwift",
                dependencies: [
                    "IQKeyboardNotification",
                    "IQTextInputViewNotification",
                    "IQKeyboardToolbarManager",
                    "IQKeyboardReturnManager",
                    "IQTextView"
                ],
                path: "IQKeyboardManagerSwift",
                resources: [
                    .copy("PrivacyInfo.xcprivacy")
                ],
                linkerSettings: [
                    .linkedFramework("UIKit")
                ]
               )
    ]
)
