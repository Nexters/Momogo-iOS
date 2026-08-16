import Foundation

import Dependencies

public struct GroupDataSource: Sendable {
    public var create: @Sendable (CreateGroupRequestDTO) async throws -> CreateGroupResponseDTO
    public var updateName: @Sendable (Int, UpdateGroupNameRequestDTO) async throws -> UpdateGroupNameResponseDTO
    public var checkInvitation: @Sendable (String) async throws -> CheckInvitationResponseDTO
    public var join: @Sendable (JoinGroupByCodeRequestDTO) async throws -> JoinGroupByCodeResponseDTO
    public var list: @Sendable () async throws -> GroupListResponseDTO
    public var detail: @Sendable (Int, String?) async throws -> GroupDetailResponseDTO
    public var leave: @Sendable (Int) async throws -> Void
    public var reportPhoto: @Sendable (_ groupId: Int, _ photoId: Int, PhotoReportRequestDTO) async throws -> Void
    public var unlinkPhoto: @Sendable (_ groupId: Int, _ photoId: Int) async throws -> Void

    public init(
        create: @escaping @Sendable (CreateGroupRequestDTO) async throws -> CreateGroupResponseDTO,
        updateName: @escaping @Sendable (Int, UpdateGroupNameRequestDTO) async throws -> UpdateGroupNameResponseDTO,
        checkInvitation: @escaping @Sendable (String) async throws -> CheckInvitationResponseDTO,
        join: @escaping @Sendable (JoinGroupByCodeRequestDTO) async throws -> JoinGroupByCodeResponseDTO,
        list: @escaping @Sendable () async throws -> GroupListResponseDTO,
        detail: @escaping @Sendable (Int, String?) async throws -> GroupDetailResponseDTO,
        leave: @escaping @Sendable (Int) async throws -> Void,
        reportPhoto: @escaping @Sendable (_ groupId: Int, _ photoId: Int, PhotoReportRequestDTO) async throws -> Void,
        unlinkPhoto: @escaping @Sendable (_ groupId: Int, _ photoId: Int) async throws -> Void
    ) {
        self.create = create
        self.updateName = updateName
        self.checkInvitation = checkInvitation
        self.join = join
        self.list = list
        self.detail = detail
        self.leave = leave
        self.reportPhoto = reportPhoto
        self.unlinkPhoto = unlinkPhoto
    }
}

public extension DependencyValues {
    var groupDataSource: GroupDataSource {
        get { self[GroupDataSource.self] }
        set { self[GroupDataSource.self] = newValue }
    }
}
