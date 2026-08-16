import Dependencies

import DomainInterface

extension CreateGroupUseCase: DependencyKey {
    public static var liveValue: CreateGroupUseCase {
        @Dependency(\.groupRepository) var groupRepository

        return CreateGroupUseCase(
            execute: { groupName in
                try await groupRepository.createGroup(CreateGroupRequest(groupName: groupName))
            }
        )
    }
}
