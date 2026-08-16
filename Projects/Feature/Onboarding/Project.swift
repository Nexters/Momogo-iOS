import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.onboarding.rawValue,
    targets: [
        .feature(implements: .onboarding, factory: .init(
            dependencies: [
                .designSystem,
                .swiftUINavigation,
                .dependencies,
                .domainInterface,
                .feature(implements: .group)
            ]
        )),
        .feature(tests: .onboarding, factory: .init(
            dependencies: [
                .feature(implements: .onboarding)
            ]
        )),
        .feature(example: .onboarding, factory: .init(
            dependencies: [
                .feature(implements: .onboarding),
                .dependencies,
                .domainInterface
            ]
        ))
    ],
    schemes: [
        .scheme(
            name: "FeatureOnboardingExample",
            buildAction: .buildAction(targets: [.target("FeatureOnboardingExample")]),
            runAction: .runAction(configuration: .dev, executable: .target("FeatureOnboardingExample"))
        )
    ]
)
