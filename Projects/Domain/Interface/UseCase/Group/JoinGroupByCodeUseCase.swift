import Dependencies

/// 참여 코드로 그룹에 참여하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct JoinGroupByCodeUseCase: Sendable {
    public var execute: @Sendable (_ code: String) async throws -> JoinGroupByCodeResponse

    public init(execute: @escaping @Sendable (_ code: String) async throws -> JoinGroupByCodeResponse) {
        self.execute = execute
    }
}

extension JoinGroupByCodeUseCase: TestDependencyKey {
    public static let testValue = JoinGroupByCodeUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var joinGroupByCodeUseCase: JoinGroupByCodeUseCase {
        get { self[JoinGroupByCodeUseCase.self] }
        set { self[JoinGroupByCodeUseCase.self] = newValue }
    }
}
