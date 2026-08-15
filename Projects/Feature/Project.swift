import DependencyPlugin
import ProjectDescription

let targets: [Target] = [
    .feature(factory: .init(
        dependencies: [
            .feature(implements: .home),
            .core,
            .feature(implements: .onboarding),
            .feature(implements: .group),
            .feature(implements: .splash),
            .feature(implements: .settings),
            .feature(implements: .photo),
            .feature(implements: .camera)
        ]
    ))
]

let project = Project.makeModule(name: "Feature", targets: targets)
