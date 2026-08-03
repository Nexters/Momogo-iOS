import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: "Data",
    targets: [
        .data(factory: .init(
            dependencies: [
                .domainInterface,
                .moya,
                .dependencies
            ]
        )),
        .data(tests: .init(
            dependencies: [.data]
        ))
    ]
)
