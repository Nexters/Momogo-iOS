import ProjectDescription

public extension Project {
    static func makeModule(
        name: String,
        options: Project.Options = .options(),
        targets: [Target],
        schemes: [Scheme] = [],
        resourceSynthesizers: [ResourceSynthesizer] = .default
    ) -> Project {
        return Project(
            name: name,
            organizationName: env.organizationName,
            options: options,
            settings: .settings(
                configurations: [
                    .debug(name: .dev),
                    .release(name: .prod)
                ]
            ),
            targets: targets,
            schemes: schemes,
            resourceSynthesizers: resourceSynthesizers
        )
    }
}
