import Dependencies

import DomainInterface

extension UpdateGroupNameUseCase: DependencyKey {
    public static var liveValue: UpdateGroupNameUseCase {
        @Dependency(\.groupRepository) var groupRepository

        return UpdateGroupNameUseCase(
            execute: { groupId, groupName in
                try await groupRepository.updateGroupName(
                    UpdateGroupNameRequest(groupId: groupId, groupName: groupName)
                )
            }
        )
    }
}
