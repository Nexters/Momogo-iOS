import Dependencies

/// 특정 그룹의 상세(그룹원 닉네임 포함)를 조회하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct GetGroupDetailUseCase: Sendable {
    public var execute: @Sendable (GetGroupDetailRequest) async throws -> GetGroupDetailResponse

    public init(execute: @escaping @Sendable (GetGroupDetailRequest) async throws -> GetGroupDetailResponse) {
        self.execute = execute
    }
}

extension GetGroupDetailUseCase: TestDependencyKey {
    public static let testValue = GetGroupDetailUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var getGroupDetailUseCase: GetGroupDetailUseCase {
        get { self[GetGroupDetailUseCase.self] }
        set { self[GetGroupDetailUseCase.self] = newValue }
    }
}
