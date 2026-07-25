import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: "Data",
    targets: [
        .networking(interface: .init(
            dependencies: [.moya, .dependencies]
        )),
        .networking(implements: .init(
            dependencies: [
                .networkingInterface,
                .moya,
                .dependencies,
            ]
        )),
        .data(factory: .init(
            dependencies: [
                .domainInterface,
                .networkingInterface,
                .moya,
                .dependencies,
            ]
        )),
        .data(tests: .init(
            dependencies: [.data]
        )),
    ]
)
