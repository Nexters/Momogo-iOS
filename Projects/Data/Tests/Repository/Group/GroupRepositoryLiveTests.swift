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
                        todayPhotoUploaderCount: 2
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
    }
}
