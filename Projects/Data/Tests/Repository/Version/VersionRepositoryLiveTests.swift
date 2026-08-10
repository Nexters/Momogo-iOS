import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Data

struct VersionRepositoryLiveTests {
    @Test("forceUpdate: true와 유효한 updateUrl을 도메인 모델로 매핑한다")
    func checkAppVersion_forceUpdateWithValidURL_mapsToNonNilURL() async throws {
        let repository = withDependencies {
            $0.versionDataSource.check = {
                AppVersionResponseDTO(
                    latestVersion: "1.1.0",
                    minSupportedVersion: "1.1.0",
                    forceUpdate: true,
                    updateUrl: "https://apps.apple.com/app/id000000000"
                )
            }
        } operation: {
            VersionRepository.liveValue
        }

        let result = try await repository.checkAppVersion()

        #expect(result.isForceUpdateRequired == true)
        #expect(result.updateURL?.absoluteString == "https://apps.apple.com/app/id000000000")
    }

    @Test("forceUpdate: false면 updateUrl과 무관하게 차단이 필요 없다고 매핑한다")
    func checkAppVersion_noForceUpdate_mapsToFalse() async throws {
        let repository = withDependencies {
            $0.versionDataSource.check = {
                AppVersionResponseDTO(
                    latestVersion: "1.0.0",
                    minSupportedVersion: "1.0.0",
                    forceUpdate: false,
                    updateUrl: "https://apps.apple.com/app/id000000000"
                )
            }
        } operation: {
            VersionRepository.liveValue
        }

        let result = try await repository.checkAppVersion()

        #expect(result.isForceUpdateRequired == false)
    }

    @Test("updateUrl이 빈 문자열이면 updateURL은 nil로 매핑된다")
    func checkAppVersion_emptyUpdateUrl_mapsToNilURL() async throws {
        let repository = withDependencies {
            $0.versionDataSource.check = {
                AppVersionResponseDTO(
                    latestVersion: "1.1.0",
                    minSupportedVersion: "1.1.0",
                    forceUpdate: true,
                    updateUrl: ""
                )
            }
        } operation: {
            VersionRepository.liveValue
        }

        let result = try await repository.checkAppVersion()

        #expect(result.isForceUpdateRequired == true)
        #expect(result.updateURL == nil)
    }

    @Test("DataSource가 실패하면 에러를 그대로 던진다")
    func checkAppVersion_dataSourceFailure_throws() async throws {
        let repository = withDependencies {
            $0.versionDataSource.check = { throw VersionRepositoryTestError.failed }
        } operation: {
            VersionRepository.liveValue
        }

        await #expect(throws: VersionRepositoryTestError.self) {
            _ = try await repository.checkAppVersion()
        }
    }
}

private enum VersionRepositoryTestError: Error {
    case failed
}
