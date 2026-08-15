import Dependencies

/// 사진을 신고하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct ReportPhotoUseCase: Sendable {
    public var execute: @Sendable (ReportPhotoRequest) async throws -> Void

    public init(execute: @escaping @Sendable (ReportPhotoRequest) async throws -> Void) {
        self.execute = execute
    }
}

extension ReportPhotoUseCase: TestDependencyKey {
    public static let testValue = ReportPhotoUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var reportPhotoUseCase: ReportPhotoUseCase {
        get { self[ReportPhotoUseCase.self] }
        set { self[ReportPhotoUseCase.self] = newValue }
    }
}
