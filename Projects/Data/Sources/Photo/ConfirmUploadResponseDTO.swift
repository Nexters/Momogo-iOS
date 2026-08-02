import Foundation

public struct ConfirmUploadResponseDTO: Decodable, Sendable {
    public let photoId: Int
    public let objectKey: String
    public let uploadDate: String
}
