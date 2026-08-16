import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.home.rawValue,
    targets: [
        .feature(implements: .home, factory: .init(
            dependencies: [
                .domainInterface,
                .designSystem,
                .dependencies,
                .swiftUINavigation,
                .kingfisher,
                .feature(implements: .group),
                .feature(implements: .settings),
                .feature(implements: .camera),
                .feature(implements: .photo)
            ]
        )),
        .feature(tests: .home, factory: .init(
            dependencies: [
                .feature(implements: .home),
                .dependencies
            ]
        )),
        .feature(example: .home, factory: .init(
            dependencies: [
                .feature(implements: .home),
                .dependencies
            ]
        ))
    ],
    schemes: [
        .scheme(
            name: "FeatureHomeExample",
            buildAction: .buildAction(targets: [.target("FeatureHomeExample")]),
            runAction: .runAction(configuration: .dev, executable: .target("FeatureHomeExample"))
        )
    ]
)
