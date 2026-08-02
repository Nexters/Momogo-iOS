import Foundation

public struct GroupPhotoDTO: Decodable, Sendable {
    public let photoId: Int
    public let memberId: Int
    public let url: String
}
