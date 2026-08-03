import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Domain

struct JoinGroupByCodeUseCaseTests {
    @Test("참여 코드를 요청으로 감싸 Repository에 전달하고, 응답을 그대로 반환한다")
    func execute_success_forwardsRequestAndReturnsResponse() async throws {
        let capturedRequest = Locked<JoinGroupByCodeRequest?>(nil)

        let useCase = withDependencies {
            $0.groupRepository.joinGroupByCode = { request in
                capturedRequest.set(request)
                return JoinGroupByCodeResponse(groupId: 10, code: request.code)
            }
        } operation: {
            JoinGroupByCodeUseCase.liveValue
        }

        let response = try await useCase.execute("ABC123")

        #expect(capturedRequest.get()?.code == "ABC123")
        #expect(response.groupId == 10)
        #expect(response.code == "ABC123")
    }

    @Test("Repository가 실패하면 에러를 그대로 던진다")
    func execute_repositoryFailure_throws() async throws {
        let useCase = withDependencies {
            $0.groupRepository.joinGroupByCode = { _ in throw JoinGroupByCodeTestError.failed }
        } operation: {
            JoinGroupByCodeUseCase.liveValue
        }

        await #expect(throws: JoinGroupByCodeTestError.self) {
            _ = try await useCase.execute("ABC123")
        }
    }
}

private enum JoinGroupByCodeTestError: Error {
    case failed
}
