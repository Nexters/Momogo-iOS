import ProjectDescription

public extension ModulePath {
    enum Feature: String, CaseIterable {
        case home = "Home"
        case onboarding = "Onboarding"
        case group = "Group"
        case splash = "Splash"
        case settings = "Settings"
        case photo = "Photo"
        case camera = "Camera"

        public static let name = "Feature"
    }
}
