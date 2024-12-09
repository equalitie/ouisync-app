// swift-tools-version: 5.9
import PackageDescription


/* This package hosts functionality that is shared by the ios and macos versions of the client,
 regardless of entry point (app vs extension). It is best suited for:
 * common configuration options like well known ids and paths
 * IPC protocols, shared between providers and consumers
 * tools that work around or abstract over operating system behavior
 * backports of functionality that is not available on older operating systems

 Intentionally does not link with the rust core library, see `OuisyncBackend` if you need that. */
let package = Package(
    name: "OuisyncCommon",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "OuisyncCommon",
                 targets: ["OuisyncCommon"]),
    ],
    targets: [
        .target(name: "OuisyncCommon",
                path: "Sources"),
    ]
)
