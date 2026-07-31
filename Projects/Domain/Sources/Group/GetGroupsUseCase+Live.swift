import Dependencies

import DomainInterface

extension GetGroupsUseCase: DependencyKey {
    public static let liveValue = GetGroupsUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}
