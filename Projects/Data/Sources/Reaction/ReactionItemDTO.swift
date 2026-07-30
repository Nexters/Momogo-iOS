import Foundation

public struct ReactionItemDTO: Decodable, Sendable {
    public let type: String
    public let comment: String?
    public let memberId: Int
    public let nickname: String
}
