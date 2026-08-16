import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Domain

struct UpdateGroupNameUseCaseTests {
    @Test("Repository의 그룹명 변경 응답을 그대로 반환한다")
    func execute_success_returnsResponse() async throws {
        let useCase = withDependencies {
            $0.groupRepository.updateGroupName = { request in
                UpdateGroupNameResponse(groupId: request.groupId, groupName: request.groupName)
            }
        } operation: {
            UpdateGroupNameUseCase.liveValue
        }

        let response = try await useCase.execute(10, "우리 가족 하우스")

        #expect(response.groupName == "우리 가족 하우스")
    }

    @Test("Repository가 실패하면 에러를 그대로 던진다")
    func execute_repositoryFailure_throws() async throws {
        let useCase = withDependencies {
            $0.groupRepository.updateGroupName = { _ in throw UpdateGroupNameTestError.failed }
        } operation: {
            UpdateGroupNameUseCase.liveValue
        }

        await #expect(throws: UpdateGroupNameTestError.self) {
            _ = try await useCase.execute(10, "우리 가족 하우스")
        }
    }
}

private enum UpdateGroupNameTestError: Error {
    case failed
}
