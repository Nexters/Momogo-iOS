import Foundation

import Dependencies

/// presigned URL(임의 호스트)로 바이너리를 직접 PUT하는 포트. Moya/baseURL을 쓰지 않는다.
public struct MediaUploadClient: Sendable {
    public var upload: @Sendable (_ url: URL, _ data: Data, _ contentType: String) async throws -> Void

    public init(upload: @escaping @Sendable (_ url: URL, _ data: Data, _ contentType: String) async throws -> Void) {
        self.upload = upload
    }
}

public extension DependencyValues {
    var mediaUploadClient: MediaUploadClient {
        get { self[MediaUploadClient.self] }
        set { self[MediaUploadClient.self] = newValue }
    }
}
