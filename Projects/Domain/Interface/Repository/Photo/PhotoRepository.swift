import Foundation

import Dependencies

/// 사진 업로드 API를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
public struct PhotoRepository: Sendable {
    public typealias IssueUploadURL = @Sendable (IssuePhotoUploadURLRequest) async throws -> IssuePhotoUploadURLResponse
    public typealias Upload = @Sendable (_ url: URL, _ data: Data, _ contentType: String) async throws -> Void
    public typealias Confirm = @Sendable (ConfirmPhotoUploadRequest) async throws -> ConfirmPhotoUploadResponse
    public typealias GetMyPhotos = @Sendable (GetMyPhotosRequest) async throws -> GetMyPhotosResponse

    public var issueUploadURL: IssueUploadURL
    public var upload: Upload
    public var confirm: Confirm
    public var getMyPhotos: GetMyPhotos

    public init(
        issueUploadURL: @escaping IssueUploadURL,
        upload: @escaping Upload,
        confirm: @escaping Confirm,
        getMyPhotos: @escaping GetMyPhotos
    ) {
        self.issueUploadURL = issueUploadURL
        self.upload = upload
        self.confirm = confirm
        self.getMyPhotos = getMyPhotos
    }
}

extension PhotoRepository: TestDependencyKey {
    public static let testValue = PhotoRepository(
        issueUploadURL: unimplemented("\(Self.self).issueUploadURL"),
        upload: unimplemented("\(Self.self).upload"),
        confirm: unimplemented("\(Self.self).confirm"),
        getMyPhotos: unimplemented("\(Self.self).getMyPhotos")
    )
}

public extension DependencyValues {
    var photoRepository: PhotoRepository {
        get { self[PhotoRepository.self] }
        set { self[PhotoRepository.self] = newValue }
    }
}
