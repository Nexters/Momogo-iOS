import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: "Domain",
    targets: [
        .domain(interface: .init(
            dependencies: [.dependencies]
        )),
        .domain(implements: .init(
            dependencies: [
                .domainInterface,
                .dependencies
            ]
        )),
        .domain(tests: .init(
            dependencies: [
                .domain,
                .domainInterface,
                .dependencies
            ]
        ))
    ]
)
