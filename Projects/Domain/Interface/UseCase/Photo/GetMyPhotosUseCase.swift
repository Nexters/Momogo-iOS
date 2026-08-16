import Dependencies

/// 날짜별 내 사진을 조회하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct GetMyPhotosUseCase: Sendable {
    public var execute: @Sendable (GetMyPhotosRequest) async throws -> GetMyPhotosResponse

    public init(execute: @escaping @Sendable (GetMyPhotosRequest) async throws -> GetMyPhotosResponse) {
        self.execute = execute
    }
}

extension GetMyPhotosUseCase: TestDependencyKey {
    public static let testValue = GetMyPhotosUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var getMyPhotosUseCase: GetMyPhotosUseCase {
        get { self[GetMyPhotosUseCase.self] }
        set { self[GetMyPhotosUseCase.self] = newValue }
    }
}
