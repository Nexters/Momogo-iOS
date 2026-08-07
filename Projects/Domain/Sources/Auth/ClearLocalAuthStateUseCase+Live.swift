import Dependencies

import DomainInterface

extension ClearLocalAuthStateUseCase: @retroactive DependencyKey {
    public static var liveValue: ClearLocalAuthStateUseCase {
        @Dependency(\.authRepository) var authRepository

        return ClearLocalAuthStateUseCase(
            execute: {
                authRepository.clearLocalAuthState()
            }
        )
    }
}
