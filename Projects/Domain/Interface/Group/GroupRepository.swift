import Dependencies

/// 그룹 생성/참여 API를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
public struct GroupRepository: Sendable {
    public var createGroup: @Sendable (_ request: CreateGroupRequest) async throws -> CreateGroupResponse

    public init(createGroup: @escaping @Sendable (_ request: CreateGroupRequest) async throws -> CreateGroupResponse) {
        self.createGroup = createGroup
    }
}

extension GroupRepository: TestDependencyKey {
    public static let testValue = GroupRepository(
        createGroup: unimplemented("\(Self.self).createGroup")
    )
}

public extension DependencyValues {
    var groupRepository: GroupRepository {
        get { self[GroupRepository.self] }
        set { self[GroupRepository.self] = newValue }
    }
}
