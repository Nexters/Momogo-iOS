import Foundation

public struct MyPhotoDTO: Decodable, Sendable {
    public let photoId: Int
    public let downloadUrl: String
    public let contentType: String
    public let createdAt: String
    public let expiresAt: String
}

public struct MyPhotosResponseDTO: Decodable, Sendable {
    public let date: String
    public let photos: [MyPhotoDTO]
}
