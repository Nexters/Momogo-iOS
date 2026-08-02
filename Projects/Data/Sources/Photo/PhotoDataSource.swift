import Foundation

import Dependencies

public struct PhotoDataSource: Sendable {
    public var createUploadSession: @Sendable (CreateUploadSessionRequestDTO)
        async throws -> CreateUploadSessionResponseDTO
    public var confirm: @Sendable (ConfirmUploadRequestDTO) async throws -> ConfirmUploadResponseDTO
    public var upload: @Sendable (_ url: URL, _ data: Data, _ contentType: String) async throws -> Void

    public init(
        createUploadSession: @escaping @Sendable (CreateUploadSessionRequestDTO)
            async throws -> CreateUploadSessionResponseDTO,
        confirm: @escaping @Sendable (ConfirmUploadRequestDTO) async throws -> ConfirmUploadResponseDTO,
        upload: @escaping @Sendable (_ url: URL, _ data: Data, _ contentType: String) async throws -> Void
    ) {
        self.createUploadSession = createUploadSession
        self.confirm = confirm
        self.upload = upload
    }
}

public extension DependencyValues {
    var photoDataSource: PhotoDataSource {
        get { self[PhotoDataSource.self] }
        set { self[PhotoDataSource.self] = newValue }
    }
}
