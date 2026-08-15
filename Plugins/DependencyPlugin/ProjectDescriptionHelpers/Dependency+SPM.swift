import ProjectDescription

// MARK: - SPM External

public extension TargetDependency {
    static let dependencies: TargetDependency = .external(name: "Dependencies")
    static let swiftUINavigation: TargetDependency = .external(name: "SwiftUINavigation")
    static let moya: TargetDependency = .external(name: "Moya")
    static let firebaseAnalytics: TargetDependency = .external(name: "FirebaseAnalytics")
    static let firebaseCrashlytics: TargetDependency = .external(name: "FirebaseCrashlytics")
    static let lottie: TargetDependency = .external(name: "Lottie")
}
