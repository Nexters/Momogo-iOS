import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Domain

struct CreateGroupUseCaseTests {
    @Test("그룹명을 요청으로 감싸 Repository에 전달하고, 응답을 그대로 반환한다")
    func execute_success_forwardsRequestAndReturnsResponse() async throws {
        let capturedRequest = Locked<CreateGroupRequest?>(nil)

        let useCase = withDependencies {
            $0.groupRepository.createGroup = { request in
                capturedRequest.set(request)
                return CreateGroupResponse(groupId: 10, groupName: request.groupName, invitationCode: "ABC123")
            }
        } operation: {
            CreateGroupUseCase.liveValue
        }

        let response = try await useCase.execute("우리 가족")

        #expect(capturedRequest.get()?.groupName == "우리 가족")
        #expect(response.groupId == 10)
        #expect(response.groupName == "우리 가족")
        #expect(response.invitationCode == "ABC123")
    }

    @Test("Repository가 실패하면 에러를 그대로 던진다")
    func execute_repositoryFailure_throws() async throws {
        let useCase = withDependencies {
            $0.groupRepository.createGroup = { _ in throw CreateGroupTestError.failed }
        } operation: {
            CreateGroupUseCase.liveValue
        }

        await #expect(throws: CreateGroupTestError.self) {
            _ = try await useCase.execute("우리 가족")
        }
    }
}

private enum CreateGroupTestError: Error {
    case failed
}
