import ProjectDescription

public extension Target {
    /// Interface 타겟 — NetworkClient struct, DependencyKey, NetworkError
    /// Data 프로젝트 안에 물리적으로 위치하되(Data/Networking/Interface), 빌드는 별도 타깃으로 분리한다.
    static func networking(interface factory: TargetFactory) -> Self {
        var f = factory
        f.name = "NetworkingInterface"
        f.sources = "Networking/Interface/**"
        return make(factory: f)
    }

    /// Implements 타겟 — liveValue, Moya 기반 실제 통신 구현
    /// Data 프로젝트 안에 물리적으로 위치하되(Data/Networking/Sources), 빌드는 별도 타깃으로 분리한다.
    static func networking(implements factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Networking.name
        f.sources = "Networking/Sources/**"
        return make(factory: f)
    }
}
