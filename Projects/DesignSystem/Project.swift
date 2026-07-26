import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.DesignSystem.name,
    targets: [
        .designSystem(factory: .init(
            dependencies: []
        )),
    ]
)
