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
                    if [ "$CONFIGURATION" != "Release" ]; then
                      echo "Skipping Crashlytics symbol upload for $CONFIGURATION configuration."
                      exit 0
                    fi

                    CRASHLYTICS_RUN="${SRCROOT}/../../Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run"

                    if [ ! -f "$CRASHLYTICS_RUN" ]; then
                      echo "error: Crashlytics run 스크립트를 찾을 수 없습니다: $CRASHLYTICS_RUN (Tuist SPM 체크아웃 경로가 변경되었을 수 있습니다)"
                      exit 1
                    fi

                    "$CRASHLYTICS_RUN"
                    """,
                    name: "Firebase Crashlytics Upload Symbols",
                    inputPaths: [
                        "$(DWARF_DSYM_FOLDER_PATH)/$(DWARF_DSYM_FILE_NAME)/Contents/Resources/DWARF/$(TARGET_NAME)"
                    ],
                    basedOnDependencyAnalysis: false
                )
            ],
            dependencies: [.feature, .domain, .data, .firebaseCrashlytics],
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
