import ProjectDescription

public struct ProjectEnvironment {
    public let appName: String
    public let organizationName: String
    public let bundleIDPrefix: String
    public let deploymentTargets: DeploymentTargets
    public let destinations: Destinations
}

public let env = ProjectEnvironment(
    appName: "Momogo",
    organizationName: "Momogo",
    bundleIDPrefix: "com.mogumogu.momogo",
    deploymentTargets: .iOS("17.0"),
    destinations: .iOS
)
