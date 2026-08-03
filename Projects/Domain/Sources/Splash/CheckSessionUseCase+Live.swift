import Dependencies

import DomainInterface

extension CheckSessionUseCase: DependencyKey {
    public static let liveValue = CheckSessionUseCase(
        execute: unimplemented("\(Self.self).execute", placeholder: .onboarding)
    )
}
