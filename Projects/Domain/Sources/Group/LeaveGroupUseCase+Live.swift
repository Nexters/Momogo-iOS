import Dependencies

import DomainInterface

extension LeaveGroupUseCase: DependencyKey {
    public static var liveValue: LeaveGroupUseCase {
        @Dependency(\.groupRepository) var groupRepository

        return LeaveGroupUseCase(
            execute: { groupId in
                try await groupRepository.leaveGroup(LeaveGroupRequest(groupId: groupId))
            }
        )
    }
}
