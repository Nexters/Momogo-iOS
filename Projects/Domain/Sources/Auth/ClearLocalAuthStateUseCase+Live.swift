import Dependencies

import DomainInterface

extension ClearLocalAuthStateUseCase: DependencyKey {
    public static var liveValue: ClearLocalAuthStateUseCase {
        @Dependency(\.authRepository) var authRepository

        return ClearLocalAuthStateUseCase(
            execute: {
                authRepository.clearLocalAuthState()
            }
        )
    }
}
