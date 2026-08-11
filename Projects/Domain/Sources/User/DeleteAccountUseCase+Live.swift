import Dependencies

import DomainInterface

extension DeleteAccountUseCase: @retroactive DependencyKey {
    public static var liveValue: DeleteAccountUseCase {
        @Dependency(\.userRepository) var userRepository
        @Dependency(\.authRepository) var authRepository

        return DeleteAccountUseCase(
            execute: {
                try await userRepository.deleteAccount()
                // UserDataSource가 access/refresh 토큰은 이미 지우지만 게스트 UUID는 남긴다.
                // 남기면 삭제된 계정 UUID로 재로그인을 시도하게 되므로 여기서 함께 정리한다.
                authRepository.clearLocalAuthState()
            }
        )
    }
}
