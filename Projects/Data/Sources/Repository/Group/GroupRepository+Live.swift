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
                do {
                    let dto = try await groupDataSource.checkInvitation(request.code)
                    return CheckGroupByCodeResponse(
                        groupId: dto.groupId,
                        groupName: dto.groupName,
                        totalMemberCount: dto.totalMemberCount,
                        participated: dto.participated
                    )
                } catch {
                    throw mapToGroupJoinError(error)
                }
            },
            joinGroupByCode: { request in
                do {
                    let dto = try await groupDataSource.join(JoinGroupByCodeRequestDTO(code: request.code))
                    return JoinGroupByCodeResponse(groupId: dto.groupId, code: dto.code)
                } catch {
                    throw mapToGroupJoinError(error)
                }
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
            },
            getGroupDetail: { request in
                let dto = try await groupDataSource.detail(request.groupId, request.date)
                return GetGroupDetailResponse(
                    groupId: dto.groupId,
                    groupName: dto.groupName,
                    members: dto.members.map { member in
                        GroupMember(
                            userId: member.userId,
                            nickname: member.nickname,
                            isMine: member.mine,
                            photo: member.photo.map {
                                GroupMemberPhoto(photoId: $0.photoId, downloadUrl: $0.downloadUrl)
                            }
                        )
                    }
                )
            },
            updateGroupName: { request in
                let dto = try await groupDataSource.updateName(
                    request.groupId,
                    UpdateGroupNameRequestDTO(groupName: request.groupName)
                )
                return UpdateGroupNameResponse(groupId: dto.groupId, groupName: dto.groupName)
            },
            leaveGroup: { request in
                try await groupDataSource.leave(request.groupId)
            }
        )
    }
}

/// 그룹 참여 실패를 도메인 에러로 승격시킨다. 매핑되지 않는 에러는 원본 그대로 통과시킨다.
private func mapToGroupJoinError(_ error: Error) -> Error {
    guard case let NetworkError.serverError(_, problem) = error,
          let code = problem?.code
    else { return error }

    switch code {
    // 실제 서버 응답으로 확인된 값만 매핑한다. USER_NOT_FOUND는 Swagger 문서에 이 엔드포인트의 404 예시로
    // 함께 실려 있지만, 이 엔드포인트가 실제로 그 코드를 내려주는 것을 관찰한 적이 없고 계정/세션 문제처럼
    // 초대코드와 무관한 의미일 수도 있어 여기서 임의로 매핑하지 않는다. 실제로 관찰되면 그때 추가한다.
    case "INVALID_INVITATION_CODE": return GroupJoinError.invalidInvitationCode
    case "ALREADY_JOINED": return GroupJoinError.alreadyJoined
    case "GROUP_FULL": return GroupJoinError.groupFull
    default: return error
    }
}
