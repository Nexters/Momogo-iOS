import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Domain

struct CheckAppVersionUseCaseTests {
    @Test("Repository의 버전 체크 결과를 그대로 반환한다")
    func execute_success_returnsResult() async throws {
        let useCase = withDependencies {
            $0.versionRepository.checkAppVersion = {
                AppVersionCheckResult(
                    isForceUpdateRequired: true,
                    updateURL: URL(string: "https://apps.apple.com/app/id000000000")
                )
            }
        } operation: {
            CheckAppVersionUseCase.liveValue
        }

        let result = try await useCase.execute()

        #expect(result.isForceUpdateRequired == true)
        #expect(result.updateURL != nil)
    }

    @Test("Repository가 실패하면 에러를 그대로 던진다")
    func execute_repositoryFailure_throws() async throws {
        let useCase = withDependencies {
            $0.versionRepository.checkAppVersion = { throw CheckAppVersionTestError.failed }
        } operation: {
            CheckAppVersionUseCase.liveValue
        }

        await #expect(throws: CheckAppVersionTestError.self) {
            _ = try await useCase.execute()
        }
    }
}

private enum CheckAppVersionTestError: Error {
    case failed
}
