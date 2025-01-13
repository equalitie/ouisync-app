// swift-tools-version: 5.9
import PackageDescription


/* This package hosts functionality that is shared by the ios and macos versions of the file
 provider extension. It is currently used for:
 * mapping rust data models to those expected by the platform
 * white-label implementation of the file provider(s): because code in extension targets is not
   currently importable by tests, our extensions import and rename the class(es) defined here

 Before committing code to this package, consider the following questions:
 1. is the code only useful to our extensions? otherwise it might belong to `OuisyncCommon` (at the
    very least as an IPC protocol that calls into the extension that then links with this package)
 2. is the code only useful to our app? otherwise it might belong to the `OuisyncLib` swift
    bindings or even into the rust core library */
let package = Package(
    name: "OuisyncBackend",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "OuisyncBackend",
                 targets: ["OuisyncBackend"]),
    ],
    dependencies: [
        .package(path: "../OuisyncCommon"),
        .package(path: "../../ouisync/bindings/swift/OuisyncLib")
    ],
    targets: [
        .target(name: "OuisyncBackend",
                dependencies: [.product(name: "OuisyncCommon", package: "OuisyncCommon"),
                               .product(name: "OuisyncLib", package: "OuisyncLib")],
                path: "Sources"),
    ]
)
