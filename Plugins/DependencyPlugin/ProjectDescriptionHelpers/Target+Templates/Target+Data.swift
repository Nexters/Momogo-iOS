import ProjectDescription

public extension Target {
    /// Data 레이어 — Domain이 정의한 Repository 포트를 자체 NetworkClient로 구현한다.
    static func data(factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Data.name
        f.sources = .sources
        return make(factory: f)
    }

    /// Tests 타겟 — 단위 테스트. 외부에 노출 안 됨
    static func data(tests factory: TargetFactory) -> Self {
        var f = factory
        f.name = "DataTests"
        f.sources = .tests
        f.product = .unitTests
        return make(factory: f)
    }
}
