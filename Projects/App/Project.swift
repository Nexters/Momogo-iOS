import DependencyPlugin
import ProjectDescription

let project = Project.makeModule(
    name: env.appName,
    targets: [
        .app(factory: .init(
            infoPlist: .extendingDefault(with: [
                "API_BASE_URL": "$(API_BASE_URL)",
                "UILaunchScreen": .dictionary([:])
            ]),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            scripts: [
                .pre(
                    script: """
                    SECRETS_DIR="${SRCROOT}/Config/Secrets"

                    check_not_placeholder() {
                      local name="$1"
                      local value="$2"
                      if [ -z "$value" ]; then
                        echo "error: ${name}이 비어 있습니다. ${SECRETS_DIR}/${CONFIGURATION}.xcconfig를 확인하세요."
                        exit 1
                      fi
                      case "$value" in
                        *example.com*)
                          echo "error: ${name}이 템플릿 플레이스홀더(example.com)입니다. ${SECRETS_DIR}/${CONFIGURATION}.xcconfig에 실제 값을 채우세요."
                          exit 1
                          ;;
                      esac
                    }

                    check_not_placeholder "API_BASE_URL" "${API_BASE_URL:-}"

                    extract_keys() {
                      grep -E '^[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=' "$1" | sed -E 's/^([A-Za-z_][A-Za-z0-9_]*).*/\\1/' | sort -u
                    }

                    for CONFIG_NAME in Debug Release; do
                      TEMPLATE="${SECRETS_DIR}/${CONFIG_NAME}.xcconfig.template"
                      ACTUAL="${SECRETS_DIR}/${CONFIG_NAME}.xcconfig"
                      if [ ! -f "$ACTUAL" ]; then
                        continue
                      fi
                      TEMPLATE_KEYS="$(extract_keys "$TEMPLATE")"
                      ACTUAL_KEYS="$(extract_keys "$ACTUAL")"
                      if [ "$TEMPLATE_KEYS" != "$ACTUAL_KEYS" ]; then
                        echo "error: ${CONFIG_NAME}.xcconfig.template과 ${CONFIG_NAME}.xcconfig의 키 목록이 다릅니다."
                        echo "  template: $(echo "$TEMPLATE_KEYS" | tr '\\n' ' ')"
                        echo "  actual:   $(echo "$ACTUAL_KEYS" | tr '\\n' ' ')"
                        exit 1
                      fi
                    done
                    """,
                    name: "Validate Secrets xcconfig",
                    basedOnDependencyAnalysis: false
                ),
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
            settings: .settings(
                base: ["OTHER_LDFLAGS": ["-ObjC"]],
                configurations: [
                    .debug(name: "Debug", xcconfig: .relativeToRoot("Projects/App/Config/Debug.xcconfig")),
                    .release(name: "Release", xcconfig: .relativeToRoot("Projects/App/Config/Release.xcconfig"))
                ]
            )
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
