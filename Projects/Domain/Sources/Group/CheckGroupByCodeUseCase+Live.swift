import Dependencies

import DomainInterface

extension CheckGroupByCodeUseCase: DependencyKey {
    public static var liveValue: CheckGroupByCodeUseCase {
        @Dependency(\.groupRepository) var groupRepository

        return CheckGroupByCodeUseCase(
            execute: { code in
                try await groupRepository.checkGroupByCode(CheckGroupByCodeRequest(code: code))
            }
        )
    }
}
