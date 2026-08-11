import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.settings.rawValue,
    targets: [
        .feature(implements: .settings, factory: .init(
            dependencies: [
                .domainInterface,
                .designSystem,
                .dependencies,
                .swiftUINavigation
            ]
        )),
        .feature(tests: .settings, factory: .init(
            dependencies: [
                .feature(implements: .settings),
                .dependencies
            ]
        )),
        .feature(example: .settings, factory: .init(
            dependencies: [
                .feature(implements: .settings),
                .dependencies
            ]
        ))
    ],
    schemes: [
        .scheme(
            name: "FeatureSettingsExample",
            buildAction: .buildAction(targets: [.target("FeatureSettingsExample")]),
            runAction: .runAction(executable: .target("FeatureSettingsExample"))
        )
    ]
)
