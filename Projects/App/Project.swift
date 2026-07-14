import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: env.appName,
    targets: [
        .app(factory: .init(
            sources: ["Sources/**"],
            dependencies: [.feature, .domain]
        ))
    ],
    schemes: [
        .scheme(
            name: env.appName,
            buildAction: .buildAction(targets: [.target(env.appName)]),
            runAction: .runAction(configuration: .debug)
        )
    ]
)
