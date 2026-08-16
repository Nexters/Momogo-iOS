import Foundation

import Dependencies

extension MediaUploadClient: DependencyKey {
    public static let liveValue = MediaUploadClient(upload: performUpload)

    public static let testValue = MediaUploadClient(
        upload: unimplemented("\(Self.self).upload")
    )

    /// SwiftUI 프리뷰에서 실제 네트워크를 타지 않도록 아무 것도 하지 않는다.
    public static let previewValue = MediaUploadClient(upload: { _, _, _ in })
}

@Sendable
private func performUpload(url: URL, data: Data, contentType: String) async throws {
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue(contentType, forHTTPHeaderField: "Content-Type")

    let (_, response) = try await URLSession.shared.upload(for: request, from: data)

    guard let httpResponse = response as? HTTPURLResponse else {
        throw MediaUploadError.invalidResponse
    }
    guard (200 ..< 300).contains(httpResponse.statusCode) else {
        throw MediaUploadError.uploadFailed(statusCode: httpResponse.statusCode)
    }
}
