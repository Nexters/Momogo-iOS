import ProjectDescription

let tuist = Tuist(
    project: .tuist(
        plugins: [.local(path: .relativeToRoot("Plugins/DependencyPlugin"))],
        // -configuration 없이 도는 xcodebuild(CI의 Momogo-Workspace 테스트)를 DEV로 고정한다.
        generationOptions: .options(defaultConfiguration: "DEV")
    )
)
