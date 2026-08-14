import Dependencies

/// 그룹을 탈퇴하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct LeaveGroupUseCase: Sendable {
    public var execute: @Sendable (_ groupId: Int) async throws -> Void

    public init(execute: @escaping @Sendable (_ groupId: Int) async throws -> Void) {
        self.execute = execute
    }
}

extension LeaveGroupUseCase: TestDependencyKey {
    public static let testValue = LeaveGroupUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var leaveGroupUseCase: LeaveGroupUseCase {
        get { self[LeaveGroupUseCase.self] }
        set { self[LeaveGroupUseCase.self] = newValue }
    }
}
