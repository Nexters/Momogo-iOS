import Dependencies

import DomainInterface

extension SignUpUseCase: DependencyKey {
    public static var liveValue: SignUpUseCase {
        @Dependency(\.authRepository) var authRepository
        @Dependency(\.guestTokenStore) var guestTokenStore

        return SignUpUseCase(
            execute: { nickname in
                guestTokenStore.clear()
                let request = SignUpRequest(
                    provider: .guest,
                    providerToken: guestTokenStore.fetchOrCreate(),
                    nickname: nickname
                )
                return try await authRepository.signUp(request)
            }
        )
    }
}
