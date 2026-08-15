import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Domain

struct DeletePhotoUseCaseTests {
    @Test("요청을 그대로 Repository에 전달하고, 성공하면 에러 없이 완료된다")
    func execute_success_completesWithoutThrowing() async throws {
        let useCase = withDependencies {
            $0.groupRepository.deletePhoto = { request in
                #expect(request.groupId == 10)
                #expect(request.photoId == 501)
            }
        } operation: {
            DeletePhotoUseCase.liveValue
        }

        try await useCase.execute(DeletePhotoRequest(groupId: 10, photoId: 501))
    }

    @Test("Repository가 실패하면 에러를 그대로 던진다")
    func execute_repositoryFailure_throws() async throws {
        let useCase = withDependencies {
            $0.groupRepository.deletePhoto = { _ in throw DeletePhotoTestError.failed }
        } operation: {
            DeletePhotoUseCase.liveValue
        }

        await #expect(throws: DeletePhotoTestError.self) {
            try await useCase.execute(DeletePhotoRequest(groupId: 10, photoId: 501))
        }
    }
}

private enum DeletePhotoTestError: Error {
    case failed
}
