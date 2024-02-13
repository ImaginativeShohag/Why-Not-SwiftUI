// swift-tools-version: 5.8

//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "PackageName",
    dependencies: [
        .package(path: "../../../packages/SwiftMacros"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        .package(url: "https://github.com/Moya/Moya", from: "15.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.0.0"),
        .package(url: "https://github.com/danielgindi/Charts", from: "5.0.0"),
        .package(url: "https://github.com/airbnb/lottie-ios", from: "4.3.0"),
        .package(url: "https://github.com/markiv/SwiftUI-Shimmer", from: "1.4.2")
    ]
)
