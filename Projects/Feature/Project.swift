import DependencyPlugin
import ProjectDescription

let targets: [Target] = [
    .feature(factory: .init(
        dependencies: [
            .feature(implements: .home)
        ]
    ))
]

let project = Project.makeModule(name: "Feature", targets: targets)
