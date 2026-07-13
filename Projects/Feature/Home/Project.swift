import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.home.rawValue,
    targets: [
        .feature(implements: .home, factory: .init(
            dependencies: [
                .dependencies,
                .swiftUINavigation,
            ]
        )),
        .feature(tests: .home, factory: .init(
            dependencies: [
                .feature(implements: .home),
                .dependencies,
            ]
        )),
        .feature(example: .home, factory: .init(
            dependencies: [
                .feature(implements: .home),
                .domainInterface,
                .dependencies,
            ]
        )),
    ],
    schemes: [
        .scheme(
            name: "FeatureHomeExample",
            buildAction: .buildAction(targets: [.target("FeatureHomeExample")]),
            runAction: .runAction(executable: .target("FeatureHomeExample"))
        )
    ]
)
