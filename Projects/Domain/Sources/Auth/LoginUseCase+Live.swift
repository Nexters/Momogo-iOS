import Dependencies

import DomainInterface

extension LoginUseCase: DependencyKey {
    public static var liveValue: LoginUseCase {
        @Dependency(\.authRepository) var authRepository

        return LoginUseCase(
            execute: {
                await authRepository.login()
            }
        )
    }
}
