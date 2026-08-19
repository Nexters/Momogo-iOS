import Dependencies

/// 사진 하나에 달린 리액션 목록을 조회하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를
/// 통해서만 호출한다.
public struct GetReactionsUseCase: Sendable {
    public var execute: @Sendable (_ groupId: Int, _ photoId: Int) async throws -> [PhotoReaction]

    public init(execute: @escaping @Sendable (_ groupId: Int, _ photoId: Int) async throws -> [PhotoReaction]) {
        self.execute = execute
    }
}

extension GetReactionsUseCase: TestDependencyKey {
    public static let testValue = GetReactionsUseCase(
        execute: unimplemented("\(Self.self).execute", placeholder: [])
    )
}

public extension DependencyValues {
    var getReactionsUseCase: GetReactionsUseCase {
        get { self[GetReactionsUseCase.self] }
        set { self[GetReactionsUseCase.self] = newValue }
    }
}
