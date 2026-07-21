import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.group.rawValue,
    targets: [
        .feature(implements: .group, factory: .init(
            dependencies: [
                .dependencies,
                .domainInterface,
                .swiftUINavigation
            ]
        )),
        .feature(tests: .group, factory: .init(
            dependencies: [
                .feature(implements: .group),
                .dependencies
            ]
        )),
        .feature(example: .group, factory: .init(
            dependencies: [
                .feature(implements: .group),
                .domainInterface,
                .dependencies
            ]
        ))
    ],
    schemes: [
        .scheme(
            name: "FeatureGroupExample",
            buildAction: .buildAction(targets: [.target("FeatureGroupExample")]),
            runAction: .runAction(executable: .target("FeatureGroupExample"))
        )
    ]
)
