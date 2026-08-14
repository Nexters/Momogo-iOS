import Foundation

public struct GroupMemberStatusDTO: Decodable, Sendable {
    public let userId: Int
    public let nickname: String
    public let mine: Bool
    public let photo: GroupPhotoResponseDTO?
}
