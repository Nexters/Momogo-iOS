import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: "Core",
    targets: [
        .core(factory: .init(dependencies: [.analytics])),
        .core(tests: .init(dependencies: [.core])),
        .analytics(factory: .init(
            dependencies: [
                .dependencies,
                .firebaseAnalytics
            ]
        )),
        .analytics(tests: .init(
            dependencies: [
                .analytics,
                .dependencies
            ]
        ))
    ]
)
