import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Data

struct GroupRepositoryLiveTests {
    @Test("createGroup은 DTO 필드(groupId/groupName/inviteCode)를 도메인 모델로 매핑한다")
    func createGroup_mapsDTOToDomainModel() async throws {
        let repository = withDependencies {
            $0.groupDataSource.create = { _ in
                CreateGroupResponseDTO(groupId: 10, groupName: "우리 가족", inviteCode: "A1B2C3D4")
            }
        } operation: {
            GroupRepository.liveValue
        }

        let response = try await repository.createGroup(CreateGroupRequest(groupName: "우리 가족"))

        #expect(response.groupId == 10)
        #expect(response.groupName == "우리 가족")
        #expect(response.invitationCode == "A1B2C3D4")
    }

    @Test("checkGroupByCode는 DTO 필드를 도메인 모델로 매핑한다")
    func checkGroupByCode_mapsDTOToDomainModel() async throws {
        let repository = withDependencies {
            $0.groupDataSource.checkInvitation = { _ in
                CheckInvitationResponseDTO(
                    groupId: 10,
                    groupName: "우리 가족",
                    totalMemberCount: 4,
                    participated: false
                )
            }
        } operation: {
            GroupRepository.liveValue
        }

        let response = try await repository.checkGroupByCode(CheckGroupByCodeRequest(code: "A1B2C3D4"))

        #expect(response.groupId == 10)
        #expect(response.totalMemberCount == 4)
        #expect(response.participated == false)
    }

    @Test("joinGroupByCode는 DTO 필드(groupId/code)를 도메인 모델로 매핑한다")
    func joinGroupByCode_mapsDTOToDomainModel() async throws {
        let repository = withDependencies {
            $0.groupDataSource.join = { _ in
                JoinGroupByCodeResponseDTO(groupId: 10, code: "A1B2C3D4")
            }
        } operation: {
            GroupRepository.liveValue
        }

        let response = try await repository.joinGroupByCode(JoinGroupByCodeRequest(code: "A1B2C3D4"))

        #expect(response.groupId == 10)
        #expect(response.code == "A1B2C3D4")
    }

    @Test("getGroups는 각 그룹 요약 DTO를 도메인 모델 배열로 매핑한다")
    func getGroups_mapsDTOListToDomainModels() async throws {
        let repository = withDependencies {
            $0.groupDataSource.list = {
                GroupListResponseDTO(groups: [
                    GroupSummaryDTO(
                        groupId: 10,
                        groupName: "우리 가족",
                        totalMemberCount: 4,
                        todayPhotoUploaderCount: 2,
                        members: [GroupMemberStatusDTO(userId: 1, nickname: "엄마", mine: true, photo: nil)],
                        todayPhotoUploaded: true,
                        latestUploadAt: "2026-08-12T09:30:00.000000",
                        createdAt: "2026-08-01T09:00:00.000000"
                    )
                ])
            }
        } operation: {
            GroupRepository.liveValue
        }

        let response = try await repository.getGroups()

        #expect(response.groups.count == 1)
        #expect(response.groups[0].groupId == 10)
        #expect(response.groups[0].todayPhotoUploaderCount == 2)
        #expect(response.groups[0].members == [GroupMember(userId: 1, nickname: "엄마", isMine: true)])
        #expect(response.groups[0].todayPhotoUploaded)
        #expect(response.groups[0].latestUploadAt == "2026-08-12T09:30:00.000000")
        #expect(response.groups[0].createdAt == "2026-08-01T09:00:00.000000")
    }

    @Test("getGroupDetail은 DTO를 도메인 모델로 매핑하고 mine 플래그를 isMine으로 전달한다")
    func getGroupDetail_mapsDTOToDomainModel() async throws {
        let repository = withDependencies {
            $0.groupDataSource.detail = { _, _ in
                GroupDetailResponseDTO(
                    groupId: 10,
                    groupName: "우리 가족",
                    inviteCode: "ABC123",
                    members: [
                        GroupMemberStatusDTO(
                            userId: 1,
                            nickname: "모모",
                            mine: true,
                            photo: GroupPhotoResponseDTO(
                                photoId: 501,
                                downloadUrl: "https://example.com/1.jpg",
                                contentType: "image/webp",
                                createdAt: "2026-08-05T12:30:00.123456",
                                expiresAt: "2026-08-05T12:45:00.123456"
                            )
                        ),
                        GroupMemberStatusDTO(userId: 2, nickname: "모고", mine: false, photo: nil)
                    ]
                )
            }
        } operation: {
            GroupRepository.liveValue
        }

        let response = try await repository.getGroupDetail(GetGroupDetailRequest(groupId: 10, date: nil))

        #expect(response.members.count == 2)
        #expect(response.members[0].isMine == true)
        #expect(response.members[0].photo?.downloadUrl == "https://example.com/1.jpg")
        #expect(response.members[1].photo == nil)
    }

    @Test("updateGroupName은 DTO 필드를 도메인 모델로 매핑한다")
    func updateGroupName_mapsDTOToDomainModel() async throws {
        let repository = withDependencies {
            $0.groupDataSource.updateName = { _, _ in
                UpdateGroupNameResponseDTO(groupId: 10, groupName: "우리 가족 하우스")
            }
        } operation: {
            GroupRepository.liveValue
        }

        let response = try await repository.updateGroupName(UpdateGroupNameRequest(groupId: 10, groupName: "우리 가족 하우스"))

        #expect(response.groupName == "우리 가족 하우스")
    }

    @Test("leaveGroup은 에러 없이 완료된다")
    func leaveGroup_success_completesWithoutThrowing() async throws {
        let repository = withDependencies {
            $0.groupDataSource.leave = { _ in }
        } operation: {
            GroupRepository.liveValue
        }

        try await repository.leaveGroup(LeaveGroupRequest(groupId: 10))
    }

    @Test("reportPhoto는 요청 필드를 DTO로 매핑해 전달하고, 에러 없이 완료된다")
    func reportPhoto_success_completesWithoutThrowing() async throws {
        let repository = withDependencies {
            $0.groupDataSource.reportPhoto = { groupId, photoId, dto in
                #expect(groupId == 10)
                #expect(photoId == 501)
                #expect(dto.reason == "부적절한 사진이 포함되어 있습니다.")
            }
        } operation: {
            GroupRepository.liveValue
        }

        try await repository.reportPhoto(
            ReportPhotoRequest(groupId: 10, photoId: 501, reason: "부적절한 사진이 포함되어 있습니다.")
        )
    }

    @Test("deletePhoto는 에러 없이 완료된다")
    func deletePhoto_success_completesWithoutThrowing() async throws {
        let repository = withDependencies {
            $0.groupDataSource.unlinkPhoto = { _, _ in }
        } operation: {
            GroupRepository.liveValue
        }

        try await repository.deletePhoto(DeletePhotoRequest(groupId: 10, photoId: 501))
    }
}
