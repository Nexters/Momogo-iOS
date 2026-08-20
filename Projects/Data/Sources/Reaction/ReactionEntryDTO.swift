import Foundation

/// 사진에 달린 리액션 하나. `mine`은 Swift 관례상 어색하지만 JSON 키(`mine`) 그대로 둔다 —
/// Domain 매핑에서 `isMine`으로 이름을 바꾼다.
public struct ReactionEntryDTO: Decodable, Sendable {
    public let reactionId: Int
    public let userId: Int
    public let nickname: String
    public let concept: String
    public let emoji: String
    public let comment: String
    public let createdAt: String
    public let mine: Bool
}
