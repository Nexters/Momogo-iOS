import Dependencies

import DomainInterface

extension GetGroupsUseCase: DependencyKey {
    public static var liveValue: GetGroupsUseCase {
        @Dependency(\.groupRepository) var groupRepository

        return GetGroupsUseCase(
            execute: {
                try await groupRepository.getGroups()
            }
        )
    }
}
