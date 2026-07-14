import DependencyPlugin
import ProjectDescription

let targets: [Target] = [
    .shared(factory: .init(dependencies: []))
]

let project = Project.makeModule(name: "Shared", targets: targets)
