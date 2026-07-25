import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: "Core",
    targets: [
        .core(factory: .init(dependencies: [.dependencies, .firebaseAnalytics])),
        .core(tests: .init(dependencies: [.core]))
    ]
)
