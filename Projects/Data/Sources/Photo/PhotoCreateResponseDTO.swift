import Foundation

public struct PhotoCreateResponseDTO: Decodable, Sendable {
    public let photoId: Int
    public let objectKey: String
    public let createdAt: String
}
