import Dependencies

import DomainInterface

extension LogoutUseCase: DependencyKey {
    public static var liveValue: LogoutUseCase {
        @Dependency(\.authRepository) var authRepository

        return LogoutUseCase(
            execute: {
                await authRepository.logout()
            }
        )
    }
}
