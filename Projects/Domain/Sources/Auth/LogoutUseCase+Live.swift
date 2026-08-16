import Dependencies

import DomainInterface

extension LogoutUseCase: @retroactive DependencyKey {
    public static var liveValue: LogoutUseCase {
        @Dependency(\.authRepository) var authRepository

        return LogoutUseCase(
            execute: {
                await authRepository.logout()
            }
        )
    }
}
