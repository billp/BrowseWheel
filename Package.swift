import PackageDescription

let package = Package(
    name: "BrowseWheel",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "BrowseWheel",
            targets: ["BrowseWheel"]
        )
    ],
    targets: [
        .target(
            name: "BrowseWheel",
            path: "Source"
        )
    ],
    swiftLanguageVersions: [.v5]
)
