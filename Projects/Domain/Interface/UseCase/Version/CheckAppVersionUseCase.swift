import Dependencies

/// 앱 버전이 강제 업데이트 대상인지 확인하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct CheckAppVersionUseCase: Sendable {
    public var execute: @Sendable () async throws -> AppVersionCheckResult

    public init(execute: @escaping @Sendable () async throws -> AppVersionCheckResult) {
        self.execute = execute
    }
}

extension CheckAppVersionUseCase: TestDependencyKey {
    public static let testValue = CheckAppVersionUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var checkAppVersionUseCase: CheckAppVersionUseCase {
        get { self[CheckAppVersionUseCase.self] }
        set { self[CheckAppVersionUseCase.self] = newValue }
    }
}
