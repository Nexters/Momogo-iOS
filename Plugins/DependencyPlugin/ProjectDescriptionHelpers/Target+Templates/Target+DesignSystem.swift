import ProjectDescription

public extension Target {
    /// DesignSystem 레이어 — 앱 전반에서 재사용하는 컬러, 타이포그래피, 컴포넌트를 담는다.
    static func designSystem(factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.DesignSystem.name
        f.sources = .sources
        return make(factory: f)
    }
}
