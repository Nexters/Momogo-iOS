import Dependencies

/// 현재 세션을 로그아웃하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct LogoutUseCase: Sendable {
    public var execute: @Sendable () async -> Bool

    public init(execute: @escaping @Sendable () async -> Bool) {
        self.execute = execute
    }
}

extension LogoutUseCase: TestDependencyKey {
    public static let testValue = LogoutUseCase(
        execute: unimplemented("\(Self.self).execute", placeholder: false)
    )
}

public extension DependencyValues {
    var logoutUseCase: LogoutUseCase {
        get { self[LogoutUseCase.self] }
        set { self[LogoutUseCase.self] = newValue }
    }
}
