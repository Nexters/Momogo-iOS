import Dependencies

import DomainInterface

extension CheckGroupByCodeUseCase: DependencyKey {
    public static let liveValue = CheckGroupByCodeUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}
