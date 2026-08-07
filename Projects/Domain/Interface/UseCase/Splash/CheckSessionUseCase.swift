import Dependencies

/// 세션 유효 여부를 확인해 스플래시 다음 화면을 결정하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct CheckSessionUseCase: Sendable {
    public var execute: @Sendable () async -> SplashDestination

    public init(execute: @escaping @Sendable () async -> SplashDestination) {
        self.execute = execute
    }
}

extension CheckSessionUseCase: TestDependencyKey {
    public static let testValue = CheckSessionUseCase(
        execute: unimplemented("\(Self.self).execute", placeholder: .onboarding)
    )
}

public extension DependencyValues {
    var checkSessionUseCase: CheckSessionUseCase {
        get { self[CheckSessionUseCase.self] }
        set { self[CheckSessionUseCase.self] = newValue }
    }
}
