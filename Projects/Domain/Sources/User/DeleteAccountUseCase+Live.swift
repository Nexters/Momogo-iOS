import Dependencies

import DomainInterface

extension DeleteAccountUseCase: @retroactive DependencyKey {
    public static var liveValue: DeleteAccountUseCase {
        @Dependency(\.userRepository) var userRepository
        @Dependency(\.authRepository) var authRepository

        return DeleteAccountUseCase(
            execute: {
                try await userRepository.deleteAccount()
                authRepository.clearLocalAuthState()
            }
        )
    }
}
