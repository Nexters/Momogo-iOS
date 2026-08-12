import Foundation

public struct PhotoUploadUrlResponseDTO: Decodable, Sendable {
    public let uploadUrl: String
    public let objectKey: String
    public let contentType: String
    public let expiresAt: String
}
