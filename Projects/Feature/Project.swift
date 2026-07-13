import ProjectDescription
import DependencyPlugin

let targets: [Target] = [
    .feature(factory: .init(
        dependencies: [
            .feature(implements: .home),
        ]
    ))
]

let project = Project.makeModule(name: "Feature", targets: targets)
