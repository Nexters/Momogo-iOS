import Dependencies

/// 로컬에 저장된 그룹별 방문 스냅샷(마지막으로 봤을 때의 latestUploadAt)을 조회하는 UseCase.
/// ViewModel은 Repository/Store가 아닌 이 UseCase를 통해서만 호출한다.
public struct GetGroupVisitsUseCase: Sendable {
    public var execute: @Sendable () -> [Int: String]

    public init(execute: @escaping @Sendable () -> [Int: String]) {
        self.execute = execute
    }
}

extension GetGroupVisitsUseCase: TestDependencyKey {
    public static let testValue = GetGroupVisitsUseCase(
        execute: unimplemented("\(Self.self).execute", placeholder: [:])
    )
}

public extension DependencyValues {
    var getGroupVisitsUseCase: GetGroupVisitsUseCase {
        get { self[GetGroupVisitsUseCase.self] }
        set { self[GetGroupVisitsUseCase.self] = newValue }
    }
}
