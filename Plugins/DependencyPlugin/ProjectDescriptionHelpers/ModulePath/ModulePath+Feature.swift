import ProjectDescription

public extension ModulePath {
    enum Feature: String, CaseIterable {
        case home = "Home"
        case onboarding = "Onboarding"

        public static let name = "Feature"
    }
}
