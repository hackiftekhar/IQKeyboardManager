// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IQKeyboardManagerSwift",
    products: [
       .library(name: "IQKeyboardManagerSwift", targets: ["IQKeyboardManagerSwift"])
   ],
   targets: [
       .target(
           name: "IQKeyboardManagerSwift",
           path: "IQKeyboardManagerSwift"
       )
   ]
)
