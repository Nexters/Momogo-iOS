import Dependencies

import DomainInterface

extension JoinGroupByCodeUseCase: DependencyKey {
    public static var liveValue: JoinGroupByCodeUseCase {
        @Dependency(\.groupRepository) var groupRepository

        return JoinGroupByCodeUseCase(
            execute: { code in
                try await groupRepository.joinGroupByCode(JoinGroupByCodeRequest(code: code))
            }
        )
    }
}
