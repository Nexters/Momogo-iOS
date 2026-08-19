import Foundation

/// 필드명은 실제 요청으로 확인됐다 (`concept`/`emoji`/`comment`).
public struct AddReactionRequestDTO: Encodable, Sendable {
    public let concept: String
    public let emoji: String
    public let comment: String

    public init(concept: String, emoji: String, comment: String) {
        self.concept = concept
        self.emoji = emoji
        self.comment = comment
    }
}
