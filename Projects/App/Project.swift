import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: env.appName,
    targets: [
        .app(factory: .init(
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            scripts: [
                .post(
                    script: """
                    "${SRCROOT}/../../Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run"
                    """,
                    name: "Firebase Crashlytics Upload Symbols",
                    inputPaths: [
                        "$(DWARF_DSYM_FOLDER_PATH)/$(DWARF_DSYM_FILE_NAME)/Contents/Resources/DWARF/$(TARGET_NAME)"
                    ],
                    basedOnDependencyAnalysis: false
                )
            ],
            dependencies: [.feature, .domain, .firebaseAnalytics, .firebaseCrashlytics],
            settings: .settings(base: ["OTHER_LDFLAGS": ["-ObjC"]])
        ))
    ],
    schemes: [
        .scheme(
            name: env.appName,
            buildAction: .buildAction(targets: [.target(env.appName)]),
            runAction: .runAction(configuration: .debug)
        )
    ]
)
