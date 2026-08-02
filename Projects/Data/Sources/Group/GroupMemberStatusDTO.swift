import Foundation

public struct GroupMemberStatusDTO: Decodable, Sendable {
    public let memberId: Int
    public let nickname: String
    public let photo: MemberPhotoDTO?
    public let reactions: [ReactionItemDTO]
}
