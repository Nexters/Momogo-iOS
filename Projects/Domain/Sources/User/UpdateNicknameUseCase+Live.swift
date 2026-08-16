import Dependencies

import DomainInterface

extension UpdateNicknameUseCase: @retroactive DependencyKey {
    public static var liveValue: UpdateNicknameUseCase {
        @Dependency(\.userRepository) var userRepository

        return UpdateNicknameUseCase(
            execute: { nickname in
                try await userRepository.updateNickname(nickname)
            }
        )
    }
}
