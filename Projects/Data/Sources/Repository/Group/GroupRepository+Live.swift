import Foundation

import Dependencies

import DomainInterface

extension GroupRepository: DependencyKey {
    public static var liveValue: GroupRepository {
        @Dependency(\.groupDataSource) var groupDataSource

        return GroupRepository(
            createGroup: { request in
                let dto = try await groupDataSource.create(CreateGroupRequestDTO(name: request.groupName))
                return CreateGroupResponse(
                    groupId: dto.groupId,
                    groupName: dto.groupName,
                    invitationCode: dto.inviteCode
                )
            },
            checkGroupByCode: { request in
                let dto = try await groupDataSource.checkInvitation(request.code)
                return CheckGroupByCodeResponse(
                    groupId: dto.groupId,
                    groupName: dto.groupName,
                    totalMemberCount: dto.totalMemberCount,
                    participated: dto.participated
                )
            },
            joinGroupByCode: { request in
                let dto = try await groupDataSource.join(JoinGroupByCodeRequestDTO(code: request.code))
                return JoinGroupByCodeResponse(groupId: dto.groupId, code: dto.code)
            },
            getGroups: {
                let dto = try await groupDataSource.list()
                return GetGroupsResponse(
                    groups: dto.groups.map { summary in
                        GroupSummary(
                            groupId: summary.groupId,
                            groupName: summary.groupName,
                            totalMemberCount: summary.totalMemberCount,
                            todayPhotoUploaderCount: summary.todayPhotoUploaderCount
                        )
                    }
                )
            }
        )
    }
}
