import Dependencies

import DomainInterface

extension CreateGroupUseCase: DependencyKey {
    public static let liveValue = CreateGroupUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}
