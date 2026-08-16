// swift-tools-version: 5.10
import PackageDescription

#if TUIST
    import struct ProjectDescription.Configuration
    import struct ProjectDescription.PackageSettings
    import struct ProjectDescription.Settings

    let packageSettings = PackageSettings(
        // 특정 패키지 제품의 타입을 커스터마이징
        // 기본값은 .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:],
        // SPM 의존성 프로젝트도 앱과 같은 configuration 이름을 가져야 한다.
        // 안 맞추면 tuist generate가 "missing or mismatching configurations" 경고를 내고
        // DEV/PROD 빌드 시 의존성이 엉뚱한 설정으로 빌드된다.
        baseSettings: .settings(
            configurations: [
                .debug(name: "DEV"),
                .release(name: "PROD")
            ]
        )
    )
#endif

let package = Package(
    name: "Momogo",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.3.0"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "1.5.0"),
        .package(url: "https://github.com/Moya/Moya", from: "15.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
        .package(url: "https://github.com/airbnb/lottie-ios", from: "4.5.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.0.0")
    ]
)
