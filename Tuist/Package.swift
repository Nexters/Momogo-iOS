// swift-tools-version: 5.10
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // 특정 패키지 제품의 타입을 커스터마이징
        // 기본값은 .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:]
    )
#endif

let package = Package(
    name: "Momogo",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.3.0"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "1.5.0"),
        .package(url: "https://github.com/Moya/Moya", from: "15.0.0"),
    ]
)
