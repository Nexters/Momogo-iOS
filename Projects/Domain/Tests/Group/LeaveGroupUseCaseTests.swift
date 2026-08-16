import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Domain

struct LeaveGroupUseCaseTests {
    @Test("Repository가 성공하면 에러 없이 완료된다")
    func execute_success_completesWithoutThrowing() async throws {
        let useCase = withDependencies {
            $0.groupRepository.leaveGroup = { _ in }
        } operation: {
            LeaveGroupUseCase.liveValue
        }

        try await useCase.execute(10)
    }

    @Test("Repository가 실패하면 에러를 그대로 던진다")
    func execute_repositoryFailure_throws() async throws {
        let useCase = withDependencies {
            $0.groupRepository.leaveGroup = { _ in throw LeaveGroupTestError.failed }
        } operation: {
            LeaveGroupUseCase.liveValue
        }

        await #expect(throws: LeaveGroupTestError.self) {
            try await useCase.execute(10)
        }
    }
}

private enum LeaveGroupTestError: Error {
    case failed
}
