import Foundation

import Dependencies

import DomainInterface

extension VersionRepository: @retroactive DependencyKey {
    public static var liveValue: VersionRepository {
        @Dependency(\.versionDataSource) var versionDataSource

        return VersionRepository(
            checkAppVersion: {
                let response = try await versionDataSource.check()
                return AppVersionCheckResult(
                    isForceUpdateRequired: response.forceUpdate,
                    updateURL: URL(string: response.updateUrl)
                )
            }
        )
    }
}
