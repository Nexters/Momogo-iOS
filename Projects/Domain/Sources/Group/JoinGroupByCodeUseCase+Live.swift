import Dependencies

import DomainInterface

extension JoinGroupByCodeUseCase: DependencyKey {
    public static let liveValue = JoinGroupByCodeUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}
