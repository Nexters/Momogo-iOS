import Dependencies

/// 그룹 생성/참여/조회 API를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
public struct GroupRepository: Sendable {
    public typealias CreateGroup = @Sendable (CreateGroupRequest) async throws -> CreateGroupResponse
    public typealias CheckGroupByCode = @Sendable (CheckGroupByCodeRequest) async throws -> CheckGroupByCodeResponse
    public typealias JoinGroupByCode = @Sendable (JoinGroupByCodeRequest) async throws -> JoinGroupByCodeResponse
    public typealias GetGroups = @Sendable () async throws -> GetGroupsResponse
    public typealias GetGroupDetail = @Sendable (GetGroupDetailRequest) async throws -> GetGroupDetailResponse
    public typealias UpdateGroupName = @Sendable (UpdateGroupNameRequest) async throws -> UpdateGroupNameResponse
    public typealias LeaveGroup = @Sendable (LeaveGroupRequest) async throws -> Void

    public var createGroup: CreateGroup
    public var checkGroupByCode: CheckGroupByCode
    public var joinGroupByCode: JoinGroupByCode
    public var getGroups: GetGroups
    public var getGroupDetail: GetGroupDetail
    public var updateGroupName: UpdateGroupName
    public var leaveGroup: LeaveGroup

    public init(
        createGroup: @escaping CreateGroup,
        checkGroupByCode: @escaping CheckGroupByCode,
        joinGroupByCode: @escaping JoinGroupByCode,
        getGroups: @escaping GetGroups,
        getGroupDetail: @escaping GetGroupDetail,
        updateGroupName: @escaping UpdateGroupName,
        leaveGroup: @escaping LeaveGroup
    ) {
        self.createGroup = createGroup
        self.checkGroupByCode = checkGroupByCode
        self.joinGroupByCode = joinGroupByCode
        self.getGroups = getGroups
        self.getGroupDetail = getGroupDetail
        self.updateGroupName = updateGroupName
        self.leaveGroup = leaveGroup
    }
}

extension GroupRepository: TestDependencyKey {
    public static let testValue = GroupRepository(
        createGroup: unimplemented("\(Self.self).createGroup"),
        checkGroupByCode: unimplemented("\(Self.self).checkGroupByCode"),
        joinGroupByCode: unimplemented("\(Self.self).joinGroupByCode"),
        getGroups: unimplemented("\(Self.self).getGroups"),
        getGroupDetail: unimplemented("\(Self.self).getGroupDetail"),
        updateGroupName: unimplemented("\(Self.self).updateGroupName"),
        leaveGroup: unimplemented("\(Self.self).leaveGroup")
    )
}

public extension DependencyValues {
    var groupRepository: GroupRepository {
        get { self[GroupRepository.self] }
        set { self[GroupRepository.self] = newValue }
    }
}
