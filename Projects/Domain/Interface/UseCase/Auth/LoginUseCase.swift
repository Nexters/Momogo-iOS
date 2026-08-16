import Dependencies

/// 게스트 토큰으로 로그인을 시도하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct LoginUseCase: Sendable {
    public var execute: @Sendable () async -> Bool

    public init(execute: @escaping @Sendable () async -> Bool) {
        self.execute = execute
    }
}

extension LoginUseCase: TestDependencyKey {
    public static let testValue = LoginUseCase(
        execute: unimplemented("\(Self.self).execute", placeholder: false)
    )
}

public extension DependencyValues {
    var loginUseCase: LoginUseCase {
        get { self[LoginUseCase.self] }
        set { self[LoginUseCase.self] = newValue }
    }
}
