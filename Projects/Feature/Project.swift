import DependencyPlugin
import ProjectDescription

let targets: [Target] = [
    .feature(factory: .init(
        dependencies: [
            .feature(implements: .home),
            .core,
            .feature(implements: .onboarding)
        ]
    ))
]

let project = Project.makeModule(name: "Feature", targets: targets)
