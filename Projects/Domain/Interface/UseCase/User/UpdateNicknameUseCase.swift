import Dependencies

/// 닉네임을 변경하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct UpdateNicknameUseCase: Sendable {
    public var execute: @Sendable (_ nickname: String) async throws -> Void

    public init(execute: @escaping @Sendable (_ nickname: String) async throws -> Void) {
        self.execute = execute
    }
}

extension UpdateNicknameUseCase: TestDependencyKey {
    public static let testValue = UpdateNicknameUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var updateNicknameUseCase: UpdateNicknameUseCase {
        get { self[UpdateNicknameUseCase.self] }
        set { self[UpdateNicknameUseCase.self] = newValue }
    }
}
