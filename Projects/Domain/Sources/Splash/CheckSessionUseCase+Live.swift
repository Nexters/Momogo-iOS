import Dependencies

import DomainInterface

extension CheckSessionUseCase: @retroactive DependencyKey {
    public static var liveValue: CheckSessionUseCase {
        @Dependency(\.authRepository) var authRepository

        return CheckSessionUseCase(
            execute: {
                let isSessionValid = await authRepository.refreshSession()
                return isSessionValid ? .home : .onboarding
            }
        )
    }
}
