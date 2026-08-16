import Foundation

public struct AddReactionResponseDTO: Decodable, Sendable {
    public let groupId: Int
    public let member: ReactionMemberDTO
    public let reactions: [ReactionItemDTO]
    public let reactionCounts: [ReactionCountDTO]
}
