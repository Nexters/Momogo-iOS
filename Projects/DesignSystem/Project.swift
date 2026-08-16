import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: ModulePath.DesignSystem.name,
    targets: [
        .designSystem(factory: .init(
            resources: ["Resources/**"],
            dependencies: [.lottie]
        )),
        .designSystem(tests: .init(
            dependencies: [
                .designSystem
            ]
        )),
        .designSystem(example: .init(
            dependencies: [
                .designSystem
            ]
        ))
    ],
    schemes: [
        .scheme(
            name: "DesignSystemExample",
            buildAction: .buildAction(targets: [.target("DesignSystemExample")]),
            runAction: .runAction(configuration: .dev, executable: .target("DesignSystemExample"))
        )
    ]
)
