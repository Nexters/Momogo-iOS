import ProjectDescription

public extension TargetScript {
    /// 로컬 빌드 시 SwiftLint를 실행해 위반 사항을 Xcode 빌드 에러로 표시합니다.
    /// `--strict` 옵션으로 warning도 error로 승격시켜, CI(lint-format.yml)와 동일한 기준을 로컬에서도 강제합니다.
    ///
    /// App 타겟에만 부착합니다. 모든 타겟에 붙이면 타겟 수만큼 swiftlint 프로세스가 뜨고,
    /// 각 타겟이 SRCROOT(= 프로젝트 디렉토리) 전체를 린트해 같은 파일을 중복 검사합니다.
    /// 린트 범위는 `.swiftlint.yml`의 `included`가 결정하므로 경로 인자 없이 CI와 동일하게 1회만 실행합니다.
    static let swiftLint = TargetScript.pre(
        script: """
        export PATH="$PATH:$HOME/.local/share/mise/shims:/opt/homebrew/bin"

        if which swiftlint > /dev/null; then
          REPO_ROOT=$(git -C "${SRCROOT}" rev-parse --show-toplevel)
          cd "${REPO_ROOT:?저장소 루트를 찾을 수 없어 SwiftLint를 실행하지 못했습니다}"
          swiftlint lint --strict
        else
          echo "warning: SwiftLint가 설치되어 있지 않습니다. 'mise install' 실행 후 다시 시도해주세요."
        fi
        """,
        name: "SwiftLint",
        basedOnDependencyAnalysis: false
    )
}
