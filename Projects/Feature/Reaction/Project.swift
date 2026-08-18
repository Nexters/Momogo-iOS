import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.reaction.rawValue,
    targets: [
        .feature(implements: .reaction, factory: .init(
            dependencies: [
                .domainInterface,
                .designSystem,
                .dependencies,
                .kingfisher
            ]
        )),
        .feature(tests: .reaction, factory: .init(
            dependencies: [
                .feature(implements: .reaction),
                .dependencies
            ]
        )),
        .feature(example: .reaction, factory: .init(
            dependencies: [
                .feature(implements: .reaction),
                .dependencies,
                .domainInterface
            ]
        ))
    ],
    schemes: [
        .scheme(
            name: "FeatureReactionExample",
            buildAction: .buildAction(targets: [.target("FeatureReactionExample")]),
            runAction: .runAction(configuration: .dev, executable: .target("FeatureReactionExample"))
        )
    ]
)
