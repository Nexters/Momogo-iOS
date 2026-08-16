import Foundation

import Dependencies

public struct PhotoDataSource: Sendable {
    public var issueUploadURL: @Sendable (PhotoUploadUrlRequestDTO) async throws -> PhotoUploadUrlResponseDTO
    public var confirm: @Sendable (PhotoCreateRequestDTO) async throws -> PhotoCreateResponseDTO
    public var upload: @Sendable (_ url: URL, _ data: Data, _ contentType: String) async throws -> Void
    public var myPhotos: @Sendable (_ date: String?) async throws -> MyPhotosResponseDTO

    public init(
        issueUploadURL: @escaping @Sendable (PhotoUploadUrlRequestDTO) async throws -> PhotoUploadUrlResponseDTO,
        confirm: @escaping @Sendable (PhotoCreateRequestDTO) async throws -> PhotoCreateResponseDTO,
        upload: @escaping @Sendable (_ url: URL, _ data: Data, _ contentType: String) async throws -> Void,
        myPhotos: @escaping @Sendable (_ date: String?) async throws -> MyPhotosResponseDTO
    ) {
        self.issueUploadURL = issueUploadURL
        self.confirm = confirm
        self.upload = upload
        self.myPhotos = myPhotos
    }
}

public extension DependencyValues {
    var photoDataSource: PhotoDataSource {
        get { self[PhotoDataSource.self] }
        set { self[PhotoDataSource.self] = newValue }
    }
}
