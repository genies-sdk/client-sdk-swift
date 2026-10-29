// swift-tools-version:6.2
// (Xcode26.0+)

import PackageDescription

let package = Package(
    name: "LiveKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "LiveKit",
            targets: ["LiveKit"],
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/livekit/livekit-uniffi-xcframework.git", exact: "0.1.9"),
        // Test-only: conformance oracle for the nanopb facades.
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.31.0"),
        // Only used for DocC generation
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.3.0"),
    ],
    targets: [
        // Genies WebRTC source: 37da78f55660265cade2a601dca4a171636e369c
        .binaryTarget(
            name: "LiveKitWebRTC",
            url: "https://github.com/geniesinc/webrtc/releases/download/m150-genies.1/LiveKitWebRTC.xcframework.zip",
            checksum: "b16a361bc67b99f03cc70dbeaf811e0f9e757d9d9bdb9ad6b199db328548c5f1",
        ),
        .target(
            name: "CLiveKitProto",
            exclude: ["LICENSE-nanopb.txt", "module.modulemap"],
            publicHeadersPath: "include",
            cSettings: [
                // ABI defines live in include/lk_pb_config.h (included from
                // pb.h); lk_abi_check.c guards them at compile time.
                .headerSearchPath("include"),
            ],
        ),
        .target(
            name: "LiveKitNanopb",
            dependencies: ["CLiveKitProto"],
        ),
        .target(
            name: "LKObjCHelpers",
            publicHeadersPath: "include",
        ),
        .target(
            name: "LiveKit",
            dependencies: [
                "LiveKitWebRTC",
                .product(name: "LiveKitUniFFI", package: "livekit-uniffi-xcframework"),
                "LiveKitNanopb",
                "LKObjCHelpers",
            ],
            exclude: [
                "Broadcast/NOTICE",
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ],
        ),
        .testTarget(
            // SwiftProtobuf is a test-only conformance oracle here: the same
            // protos are compiled with protoc-gen-swift so every nanopb-encoded
            // payload can be verified against a second, independent implementation.
            name: "LiveKitNanopbTests",
            dependencies: [
                "LiveKit",
                "LiveKitNanopb",
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ],
        ),
        .target(
            name: "LiveKitTestSupport",
            dependencies: [
                "LiveKit",
            ],
            path: "Tests/LiveKitTestSupport",
        ),
        .testTarget(
            name: "LiveKitCoreTests",
            dependencies: [
                "LiveKit",
                "LiveKitTestSupport",
            ],
        ),
        .testTarget(
            name: "LiveKitAudioTests",
            dependencies: [
                "LiveKit",
                "LiveKitTestSupport",
            ],
        ),
        .testTarget(
            name: "LiveKitObjCTests",
            dependencies: [
                "LiveKit",
                "LiveKitTestSupport",
            ],
        ),
    ],
    swiftLanguageModes: [.v5, .v6],
)
