import Dependencies

/// 그룹 이름 입력 후 그룹을 생성하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct CreateGroupUseCase: Sendable {
    public var execute: @Sendable (_ groupName: String) async throws -> CreateGroupResponse

    public init(execute: @escaping @Sendable (_ groupName: String) async throws -> CreateGroupResponse) {
        self.execute = execute
    }
}

extension CreateGroupUseCase: TestDependencyKey {
    public static let testValue = CreateGroupUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var createGroupUseCase: CreateGroupUseCase {
        get { self[CreateGroupUseCase.self] }
        set { self[CreateGroupUseCase.self] = newValue }
    }
}
