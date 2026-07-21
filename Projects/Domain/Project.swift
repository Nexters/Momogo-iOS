import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: "Domain",
    targets: [
        .domain(interface: .init(
            dependencies: [.dependencies, .core]
        )),
        .domain(implements: .init(
            dependencies: [
                .domainInterface,
                .core,
                .dependencies,
                .moya
            ]
        )),
        .domain(tests: .init(
            dependencies: [
                .domain,
                .domainInterface,
                .core,
                .dependencies
            ]
        ))
    ]
)
