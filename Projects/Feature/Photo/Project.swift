import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.photo.rawValue,
    targets: [
        .feature(implements: .photo, factory: .init(
            dependencies: [
                .designSystem,
                .dependencies,
                .domainInterface
            ]
        )),
        .feature(tests: .photo, factory: .init(
            dependencies: [
                .feature(implements: .photo)
            ]
        )),
        .feature(example: .photo, factory: .init(
            dependencies: [
                .feature(implements: .photo),
                .dependencies,
                .domainInterface
            ]
        ))
    ],
    schemes: [
        .scheme(
            name: "FeaturePhotoExample",
            buildAction: .buildAction(targets: [.target("FeaturePhotoExample")]),
            runAction: .runAction(configuration: .dev, executable: .target("FeaturePhotoExample"))
        )
    ]
)
