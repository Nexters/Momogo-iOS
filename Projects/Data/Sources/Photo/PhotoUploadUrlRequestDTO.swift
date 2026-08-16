import Foundation

public struct PhotoUploadUrlRequestDTO: Encodable, Sendable {
    public let contentType: String

    public init(contentType: String) {
        self.contentType = contentType
    }
}
