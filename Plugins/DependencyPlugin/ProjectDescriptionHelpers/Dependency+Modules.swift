import ProjectDescription

// MARK: - Layer aggregators

public extension TargetDependency {
    static let feature: TargetDependency = .project(
        target: "Feature",
        path: .relativeToRoot("Projects/Feature")
    )
    static let core: TargetDependency = .project(
        target: "Core",
        path: .relativeToRoot("Projects/Core")
    )
    static let data: TargetDependency = .project(
        target: "Data",
        path: .relativeToRoot("Projects/Data")
    )
    static let designSystem: TargetDependency = .project(
        target: "DesignSystem",
        path: .relativeToRoot("Projects/DesignSystem")
    )
}

// MARK: - Domain shorthands

public extension TargetDependency {
    static let domainInterface: TargetDependency = .project(
        target: "DomainInterface",
        path: .relativeToRoot("Projects/Domain")
    )
    static let domain: TargetDependency = .project(
        target: "Domain",
        path: .relativeToRoot("Projects/Domain")
    )
}

// MARK: - Networking shorthands

public extension TargetDependency {
    static let networkingInterface: TargetDependency = .project(
        target: "NetworkingInterface",
        path: .relativeToRoot("Projects/Data")
    )
    static let networking: TargetDependency = .project(
        target: "Networking",
        path: .relativeToRoot("Projects/Data")
    )
}

// MARK: - Feature sub-module shorthands

public extension TargetDependency {
    static func feature(implements module: ModulePath.Feature) -> TargetDependency {
        .project(
            target: "Feature\(module.rawValue)",
            path: .relativeToRoot("Projects/Feature/\(module.rawValue)")
        )
    }
}
