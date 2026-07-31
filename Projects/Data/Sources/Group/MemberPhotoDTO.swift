import Foundation

public struct MemberPhotoDTO: Decodable, Sendable {
    public let photoId: Int
    public let url: String
}
