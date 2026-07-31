import Foundation

import Dependencies

public struct GroupDataSource: Sendable {
    public var create: @Sendable (CreateGroupRequestDTO) async throws -> CreateGroupResponseDTO
    public var updateName: @Sendable (Int, UpdateGroupNameRequestDTO) async throws -> UpdateGroupNameResponseDTO
    public var checkInvitation: @Sendable (String) async throws -> CheckInvitationResponseDTO
    public var list: @Sendable () async throws -> GroupListResponseDTO
    public var detail: @Sendable (Int, String?) async throws -> GroupDetailResponseDTO

    public init(
        create: @escaping @Sendable (CreateGroupRequestDTO) async throws -> CreateGroupResponseDTO,
        updateName: @escaping @Sendable (Int, UpdateGroupNameRequestDTO) async throws -> UpdateGroupNameResponseDTO,
        checkInvitation: @escaping @Sendable (String) async throws -> CheckInvitationResponseDTO,
        list: @escaping @Sendable () async throws -> GroupListResponseDTO,
        detail: @escaping @Sendable (Int, String?) async throws -> GroupDetailResponseDTO
    ) {
        self.create = create
        self.updateName = updateName
        self.checkInvitation = checkInvitation
        self.list = list
        self.detail = detail
    }
}

public extension DependencyValues {
    var groupDataSource: GroupDataSource {
        get { self[GroupDataSource.self] }
        set { self[GroupDataSource.self] = newValue }
    }
}
