import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: "Core",
    targets: [
        .core(factory: .init(dependencies: [.shared, .moya, .dependencies, .firebaseAnalytics])),
        .core(tests: .init(dependencies: [.core]))
    ]
)
