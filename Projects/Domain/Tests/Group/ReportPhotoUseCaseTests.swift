import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Domain

struct ReportPhotoUseCaseTests {
    @Test("요청을 그대로 Repository에 전달하고, 성공하면 에러 없이 완료된다")
    func execute_success_completesWithoutThrowing() async throws {
        let useCase = withDependencies {
            $0.groupRepository.reportPhoto = { request in
                #expect(request.groupId == 10)
                #expect(request.photoId == 501)
                #expect(request.reason == "부적절한 사진이 포함되어 있습니다.")
            }
        } operation: {
            ReportPhotoUseCase.liveValue
        }

        try await useCase.execute(
            ReportPhotoRequest(groupId: 10, photoId: 501, reason: "부적절한 사진이 포함되어 있습니다.")
        )
    }

    @Test("Repository가 실패하면 에러를 그대로 던진다")
    func execute_repositoryFailure_throws() async throws {
        let useCase = withDependencies {
            $0.groupRepository.reportPhoto = { _ in throw ReportPhotoTestError.failed }
        } operation: {
            ReportPhotoUseCase.liveValue
        }

        await #expect(throws: ReportPhotoTestError.self) {
            try await useCase.execute(ReportPhotoRequest(groupId: 10, photoId: 501, reason: "사유"))
        }
    }
}

private enum ReportPhotoTestError: Error {
    case failed
}
