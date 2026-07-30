import Foundation

import Dependencies

public struct PhotoDataSource: Sendable {
    public var createUploadSession: @Sendable (CreateUploadSessionRequestDTO)
        async throws -> CreateUploadSessionResponseDTO
    public var confirm: @Sendable (ConfirmUploadRequestDTO) async throws -> ConfirmUploadResponseDTO

    public init(
        createUploadSession: @escaping @Sendable (CreateUploadSessionRequestDTO)
            async throws -> CreateUploadSessionResponseDTO,
        confirm: @escaping @Sendable (ConfirmUploadRequestDTO) async throws -> ConfirmUploadResponseDTO
    ) {
        self.createUploadSession = createUploadSession
        self.confirm = confirm
    }
}

public extension DependencyValues {
    var photoDataSource: PhotoDataSource {
        get { self[PhotoDataSource.self] }
        set { self[PhotoDataSource.self] = newValue }
    }
}
