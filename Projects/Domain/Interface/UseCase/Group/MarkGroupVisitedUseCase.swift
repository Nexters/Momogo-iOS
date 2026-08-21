import Dependencies

/// 그룹을 방문했음을 로컬에 기록하는 UseCase. ViewModel은 Repository/Store가 아닌 이 UseCase를 통해서만 호출한다.
public struct MarkGroupVisitedUseCase: Sendable {
    public var execute: @Sendable (Int, String?) -> Void

    public init(execute: @escaping @Sendable (Int, String?) -> Void) {
        self.execute = execute
    }
}

extension MarkGroupVisitedUseCase: TestDependencyKey {
    public static let testValue = MarkGroupVisitedUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var markGroupVisitedUseCase: MarkGroupVisitedUseCase {
        get { self[MarkGroupVisitedUseCase.self] }
        set { self[MarkGroupVisitedUseCase.self] = newValue }
    }
}
