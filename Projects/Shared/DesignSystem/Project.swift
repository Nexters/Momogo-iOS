import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: ModulePath.Shared.name + ModulePath.Shared.designSystem.rawValue,
    targets: [
        .shared(implements: .designSystem, factory: .init(
            dependencies: []
        )),
        .shared(tests: .designSystem, factory: .init(
            dependencies: [
                .shared(implements: .designSystem)
            ]
        )),
        .shared(example: .designSystem, factory: .init(
            dependencies: [
                .shared(implements: .designSystem)
            ]
        ))
    ],
    schemes: [
        .scheme(
            name: "SharedDesignSystemExample",
            buildAction: .buildAction(targets: [.target("SharedDesignSystemExample")]),
            runAction: .runAction(executable: .target("SharedDesignSystemExample"))
        )
    ]
)
