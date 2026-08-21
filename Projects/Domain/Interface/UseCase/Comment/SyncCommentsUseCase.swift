import Dependencies

/// 리액션 문구 카탈로그를 서버에서 받아 로컬 캐시에 반영하는 UseCase. ViewModel은 Repository/Store가
/// 아닌 이 UseCase를 통해서만 호출한다. 저장 정책(언제 덮어쓸지)은 liveValue 안에 있다.
public struct SyncCommentsUseCase: Sendable {
    public var execute: @Sendable () async throws -> Void

    public init(execute: @escaping @Sendable () async throws -> Void) {
        self.execute = execute
    }
}

extension SyncCommentsUseCase: TestDependencyKey {
    public static let testValue = SyncCommentsUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var syncCommentsUseCase: SyncCommentsUseCase {
        get { self[SyncCommentsUseCase.self] }
        set { self[SyncCommentsUseCase.self] = newValue }
    }
}
