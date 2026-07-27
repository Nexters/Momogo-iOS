import ProjectDescription

public extension Target {
    /// DesignSystem 레이어 — 앱 전반에서 재사용하는 컬러, 타이포그래피, 컴포넌트를 담는다.
    static func designSystem(factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.DesignSystem.name
        f.sources = .sources
        return make(factory: f)
    }

    /// Tests 타겟 — 단위 테스트. 외부에 노출 안 됨
    static func designSystem(tests factory: TargetFactory) -> Self {
        var f = factory
        f.name = "\(ModulePath.DesignSystem.name)Tests"
        f.sources = .tests
        f.product = .unitTests
        return make(factory: f)
    }

    /// Example 타겟 — 독립 실행 앱. 컴포넌트 갤러리 확인용
    static func designSystem(example factory: TargetFactory) -> Self {
        var f = factory
        f.name = "\(ModulePath.DesignSystem.name)Example"
        f.sources = .exampleSources
        f.product = .app
        return make(factory: f)
    }
}
