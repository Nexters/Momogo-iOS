import Dependencies

/// 서버 호출 없이 로컬 인증 상태(accessToken/refreshToken/게스트 UUID)를 전부 지우는 디버그용 UseCase.
/// 플로우 검증(완전히 새 유저 상태 재현)을 위한 임시 진입점이며, ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct ClearLocalAuthStateUseCase: Sendable {
    public var execute: @Sendable () -> Void

    public init(execute: @escaping @Sendable () -> Void) {
        self.execute = execute
    }
}

extension ClearLocalAuthStateUseCase: TestDependencyKey {
    public static let testValue = ClearLocalAuthStateUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var clearLocalAuthStateUseCase: ClearLocalAuthStateUseCase {
        get { self[ClearLocalAuthStateUseCase.self] }
        set { self[ClearLocalAuthStateUseCase.self] = newValue }
    }
}
