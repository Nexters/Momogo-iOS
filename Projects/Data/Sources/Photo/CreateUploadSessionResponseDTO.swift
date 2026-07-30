import Foundation

public struct CreateUploadSessionResponseDTO: Decodable, Sendable {
    public let uploadSessionId: Int
    public let uploadUrl: String
    public let objectKey: String
    public let expiresAt: String
}
