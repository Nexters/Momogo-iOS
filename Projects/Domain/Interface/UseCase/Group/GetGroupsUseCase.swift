import Dependencies

/// 내 그룹 목록을 조회하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct GetGroupsUseCase: Sendable {
    public var execute: @Sendable () async throws -> GetGroupsResponse

    public init(execute: @escaping @Sendable () async throws -> GetGroupsResponse) {
        self.execute = execute
    }
}

extension GetGroupsUseCase: TestDependencyKey {
    public static let testValue = GetGroupsUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var getGroupsUseCase: GetGroupsUseCase {
        get { self[GetGroupsUseCase.self] }
        set { self[GetGroupsUseCase.self] = newValue }
    }
}
