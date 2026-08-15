import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.group.rawValue,
    targets: [
        .feature(implements: .group, factory: .init(
            dependencies: [
                .designSystem,
                .swiftUINavigation,
                .dependencies,
                .domainInterface
            ]
        )),
        .feature(tests: .group, factory: .init(
            dependencies: [
                .feature(implements: .group)
            ]
        )),
        .feature(example: .group, factory: .init(
            dependencies: [
                .feature(implements: .group),
                .dependencies,
                .domainInterface
            ]
        ))
    ],
    schemes: [
        .scheme(
            name: "FeatureGroupExample",
            buildAction: .buildAction(targets: [.target("FeatureGroupExample")]),
            runAction: .runAction(configuration: .dev, executable: .target("FeatureGroupExample"))
        )
    ]
)
