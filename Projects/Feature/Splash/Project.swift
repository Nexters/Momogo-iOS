import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.splash.rawValue,
    targets: [
        .feature(implements: .splash, factory: .init(
            dependencies: [
                .domainInterface,
                .designSystem,
                .dependencies
            ]
        )),
        .feature(tests: .splash, factory: .init(
            dependencies: [
                .feature(implements: .splash),
                .dependencies
            ]
        )),
        .feature(example: .splash, factory: .init(
            dependencies: [
                .feature(implements: .splash),
                .dependencies
            ]
        ))
    ],
    schemes: [
        .scheme(
            name: "FeatureSplashExample",
            buildAction: .buildAction(targets: [.target("FeatureSplashExample")]),
            runAction: .runAction(executable: .target("FeatureSplashExample"))
        )
    ]
)
