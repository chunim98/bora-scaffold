// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BoraScaffold",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "BoraScaffold",
            targets: ["BoraScaffold"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/SnapKit/SnapKit.git",
            .upToNextMajor(from: "5.0.1")
        ),
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            .upToNextMajor(from: "6.0.0")
        ),
        .package(
            url: "https://github.com/CombineCommunity/CombineCocoa.git",
            .upToNextMajor(from: "0.2.1")
        ),
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            .upToNextMajor(from: "5.11.0")
        )
    ],
    targets: [
        .target(
            name: "BoraScaffold",
            dependencies: [
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "CombineCocoa", package: "CombineCocoa"),
                .product(name: "Alamofire", package: "Alamofire")
            ]
        )
    ]
)
