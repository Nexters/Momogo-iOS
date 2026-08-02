import Foundation

public struct CreateUploadSessionRequestDTO: Encodable, Sendable {
    public let contentType: String

    public init(contentType: String) {
        self.contentType = contentType
    }
}
