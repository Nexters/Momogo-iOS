import Dependencies

/// 계정을 탈퇴하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
/// 서버 탈퇴 성공 후 로컬 인증 상태(토큰 + 게스트 UUID) 정리까지 책임진다.
public struct DeleteAccountUseCase: Sendable {
    public var execute: @Sendable () async throws -> Void

    public init(execute: @escaping @Sendable () async throws -> Void) {
        self.execute = execute
    }
}

extension DeleteAccountUseCase: TestDependencyKey {
    public static let testValue = DeleteAccountUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var deleteAccountUseCase: DeleteAccountUseCase {
        get { self[DeleteAccountUseCase.self] }
        set { self[DeleteAccountUseCase.self] = newValue }
    }
}
