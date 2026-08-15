import Dependencies

/// 그룹에서 사진을 내리는(삭제하는) UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct DeletePhotoUseCase: Sendable {
    public var execute: @Sendable (DeletePhotoRequest) async throws -> Void

    public init(execute: @escaping @Sendable (DeletePhotoRequest) async throws -> Void) {
        self.execute = execute
    }
}

extension DeletePhotoUseCase: TestDependencyKey {
    public static let testValue = DeletePhotoUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var deletePhotoUseCase: DeletePhotoUseCase {
        get { self[DeletePhotoUseCase.self] }
        set { self[DeletePhotoUseCase.self] = newValue }
    }
}
