import Dependencies

/// 참여 코드로 그룹 정보를 확인하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct CheckGroupByCodeUseCase: Sendable {
    public var execute: @Sendable (_ code: String) async throws -> CheckGroupByCodeResponse

    public init(execute: @escaping @Sendable (_ code: String) async throws -> CheckGroupByCodeResponse) {
        self.execute = execute
    }
}

extension CheckGroupByCodeUseCase: TestDependencyKey {
    public static let testValue = CheckGroupByCodeUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var checkGroupByCodeUseCase: CheckGroupByCodeUseCase {
        get { self[CheckGroupByCodeUseCase.self] }
        set { self[CheckGroupByCodeUseCase.self] = newValue }
    }
}
