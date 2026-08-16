import Dependencies

/// 사진을 촬영 후 선택한 그룹에 업로드하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
/// 내부적으로 업로드 URL 발급 → 직접 업로드 → 확정의 3단계를 순서대로 수행한다.
public struct UploadPhotoUseCase: Sendable {
    public var execute: @Sendable (UploadPhotoRequest) async throws -> UploadPhotoResponse

    public init(execute: @escaping @Sendable (UploadPhotoRequest) async throws -> UploadPhotoResponse) {
        self.execute = execute
    }
}

extension UploadPhotoUseCase: TestDependencyKey {
    public static let testValue = UploadPhotoUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var uploadPhotoUseCase: UploadPhotoUseCase {
        get { self[UploadPhotoUseCase.self] }
        set { self[UploadPhotoUseCase.self] = newValue }
    }
}
