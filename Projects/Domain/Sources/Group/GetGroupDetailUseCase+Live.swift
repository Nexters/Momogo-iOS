import Dependencies

import DomainInterface

extension GetGroupDetailUseCase: DependencyKey {
    public static var liveValue: GetGroupDetailUseCase {
        @Dependency(\.groupRepository) var groupRepository

        return GetGroupDetailUseCase(
            execute: { request in
                try await groupRepository.getGroupDetail(request)
            }
        )
    }
}
