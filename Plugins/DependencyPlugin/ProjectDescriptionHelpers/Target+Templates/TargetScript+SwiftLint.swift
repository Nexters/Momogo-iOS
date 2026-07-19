import ProjectDescription

public extension TargetScript {
    /// 로컬 빌드 시 SwiftLint를 실행해 위반 사항을 Xcode 빌드 에러로 표시합니다.
    /// `--strict` 옵션으로 warning도 error로 승격시켜, CI(lint-format.yml)와 동일한 기준을 로컬에서도 강제합니다.
    static let swiftLint = TargetScript.pre(
        script: """
        export PATH="$PATH:$HOME/.local/share/mise/shims:/opt/homebrew/bin"

        if which swiftlint > /dev/null; then
          REPO_ROOT=$(git -C "${SRCROOT}" rev-parse --show-toplevel)
          swiftlint lint --strict --config "${REPO_ROOT}/.swiftlint.yml" "${SRCROOT}"
        else
          echo "warning: SwiftLint가 설치되어 있지 않습니다. 'mise install' 실행 후 다시 시도해주세요."
        fi
        """,
        name: "SwiftLint",
        basedOnDependencyAnalysis: false
    )
}
