import Dependencies

/// 사진에 리액션을 등록하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct AddReactionUseCase: Sendable {
    public var execute: @Sendable (AddReactionRequest) async throws -> Void

    public init(execute: @escaping @Sendable (AddReactionRequest) async throws -> Void) {
        self.execute = execute
    }
}

extension AddReactionUseCase: TestDependencyKey {
    public static let testValue = AddReactionUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var addReactionUseCase: AddReactionUseCase {
        get { self[AddReactionUseCase.self] }
        set { self[AddReactionUseCase.self] = newValue }
    }
}
