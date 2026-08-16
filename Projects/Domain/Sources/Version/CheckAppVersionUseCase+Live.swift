import Dependencies

import DomainInterface

extension CheckAppVersionUseCase: DependencyKey {
    public static var liveValue: CheckAppVersionUseCase {
        @Dependency(\.versionRepository) var versionRepository

        return CheckAppVersionUseCase(
            execute: {
                try await versionRepository.checkAppVersion()
            }
        )
    }
}
