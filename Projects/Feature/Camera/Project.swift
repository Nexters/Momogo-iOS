import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.camera.rawValue,
    targets: [
        .feature(implements: .camera, factory: .init(
            dependencies: [
                .designSystem,
                .dependencies
            ]
        )),
        .feature(tests: .camera, factory: .init(
            dependencies: [
                .feature(implements: .camera)
            ]
        )),
        // 실제 앱(FeatureHome)과 동일하게 촬영 완료 후 그룹 선택 화면(FeaturePhoto)으로 전환되는
        // 흐름까지 보여주기 위해 FeaturePhoto/DomainInterface에 의존한다. FeatureCamera 프레임워크
        // 자체는 FeaturePhoto를 모르므로(의존 방향이 반대가 됨) 이 의존은 Example 타겟에만 건다.
        .feature(example: .camera, factory: .init(
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": .dictionary([:]),
                "NSCameraUsageDescription": .string(env.cameraUsageDescription)
            ]),
            dependencies: [
                .feature(implements: .camera),
                .feature(implements: .photo),
                .dependencies,
                .domainInterface
            ]
        ))
    ],
    schemes: [
        .scheme(
            name: "FeatureCameraExample",
            buildAction: .buildAction(targets: [.target("FeatureCameraExample")]),
            runAction: .runAction(configuration: .dev, executable: .target("FeatureCameraExample"))
        )
    ]
)
