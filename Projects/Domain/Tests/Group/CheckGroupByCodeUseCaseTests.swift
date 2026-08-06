import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Domain

struct CheckGroupByCodeUseCaseTests {
    @Test("참여 코드를 요청으로 감싸 Repository에 전달하고, 응답을 그대로 반환한다")
    func execute_success_forwardsRequestAndReturnsResponse() async throws {
        let capturedRequest = Locked<CheckGroupByCodeRequest?>(nil)

        let useCase = withDependencies {
            $0.groupRepository.checkGroupByCode = { request in
                capturedRequest.set(request)
                return CheckGroupByCodeResponse(
                    groupId: 10,
                    groupName: "우리 가족",
                    totalMemberCount: 4,
                    participated: false
                )
            }
        } operation: {
            CheckGroupByCodeUseCase.liveValue
        }

        let response = try await useCase.execute("ABC123")

        #expect(capturedRequest.get()?.code == "ABC123")
        #expect(response.groupId == 10)
        #expect(response.participated == false)
    }

    @Test("Repository가 실패하면 에러를 그대로 던진다")
    func execute_repositoryFailure_throws() async throws {
        let useCase = withDependencies {
            $0.groupRepository.checkGroupByCode = { _ in throw CheckGroupByCodeTestError.failed }
        } operation: {
            CheckGroupByCodeUseCase.liveValue
        }

        await #expect(throws: CheckGroupByCodeTestError.self) {
            _ = try await useCase.execute("ABC123")
        }
    }
}

private enum CheckGroupByCodeTestError: Error {
    case failed
}
