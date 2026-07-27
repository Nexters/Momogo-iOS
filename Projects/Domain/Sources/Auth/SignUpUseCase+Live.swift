import Dependencies

import DomainInterface

extension SignUpUseCase: DependencyKey {
    public static let liveValue = SignUpUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}
