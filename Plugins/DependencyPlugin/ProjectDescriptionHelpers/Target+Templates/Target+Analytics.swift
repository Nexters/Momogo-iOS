import ProjectDescription

public extension Target {
    /// Core 프로젝트 안에 물리적으로 위치하되(Core/Analytics/Sources), 빌드는 별도 타깃으로 분리한다.
    static func analytics(factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Analytics.name
        f.sources = "Analytics/Sources/**"
        return make(factory: f)
    }

    /// Tests 타겟 — 단위 테스트. 외부에 노출 안 됨
    static func analytics(tests factory: TargetFactory) -> Self {
        var f = factory
        f.name = "AnalyticsTests"
        f.sources = "Analytics/Tests/**"
        f.product = .unitTests
        return make(factory: f)
    }
}
