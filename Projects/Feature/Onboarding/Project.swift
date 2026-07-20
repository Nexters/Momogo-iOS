import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.onboarding.rawValue,
    targets: [
        .feature(implements: .onboarding, factory: .init(
            dependencies: [
                .dependencies,
                .swiftUINavigation
            ]
        )),
        .feature(tests: .onboarding, factory: .init(
            dependencies: [
                .feature(implements: .onboarding),
                .dependencies
            ]
        )),
        .feature(example: .onboarding, factory: .init(
            dependencies: [
                .feature(implements: .onboarding),
                .domainInterface,
                .dependencies
            ]
        ))
    ],
    schemes: [
        .scheme(
            name: "FeatureOnboardingExample",
            buildAction: .buildAction(targets: [.target("FeatureOnboardingExample")]),
            runAction: .runAction(executable: .target("FeatureOnboardingExample"))
        )
    ]
)
