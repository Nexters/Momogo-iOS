import Dependencies

/// 그룹명을 변경하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct UpdateGroupNameUseCase: Sendable {
    public var execute: @Sendable (_ groupId: Int, _ groupName: String) async throws -> UpdateGroupNameResponse

    public init(
        execute: @escaping @Sendable (_ groupId: Int, _ groupName: String) async throws -> UpdateGroupNameResponse
    ) {
        self.execute = execute
    }
}

extension UpdateGroupNameUseCase: TestDependencyKey {
    public static let testValue = UpdateGroupNameUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var updateGroupNameUseCase: UpdateGroupNameUseCase {
        get { self[UpdateGroupNameUseCase.self] }
        set { self[UpdateGroupNameUseCase.self] = newValue }
    }
}
