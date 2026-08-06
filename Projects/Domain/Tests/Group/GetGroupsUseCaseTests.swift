import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Domain

struct GetGroupsUseCaseTests {
    @Test("Repository의 그룹 목록 응답을 그대로 반환한다")
    func execute_success_returnsResponse() async throws {
        let useCase = withDependencies {
            $0.groupRepository.getGroups = {
                GetGroupsResponse(groups: [
                    GroupSummary(groupId: 10, groupName: "우리 가족", totalMemberCount: 4, todayPhotoUploaderCount: 2),
                    GroupSummary(groupId: 11, groupName: "대학 동기", totalMemberCount: 3, todayPhotoUploaderCount: 0)
                ])
            }
        } operation: {
            GetGroupsUseCase.liveValue
        }

        let response = try await useCase.execute()

        #expect(response.groups.count == 2)
        #expect(response.groups.first?.groupName == "우리 가족")
        #expect(response.groups.last?.todayPhotoUploaderCount == 0)
    }

    @Test("Repository가 실패하면 에러를 그대로 던진다")
    func execute_repositoryFailure_throws() async throws {
        let useCase = withDependencies {
            $0.groupRepository.getGroups = { throw GetGroupsTestError.failed }
        } operation: {
            GetGroupsUseCase.liveValue
        }

        await #expect(throws: GetGroupsTestError.self) {
            _ = try await useCase.execute()
        }
    }
}

private enum GetGroupsTestError: Error {
    case failed
}
