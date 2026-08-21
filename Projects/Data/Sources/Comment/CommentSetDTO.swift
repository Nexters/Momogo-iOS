import Foundation

/// concept/emoji는 서버 enum 원시값을 그대로 받는 String이다(`ReactionItemDTO.type`과 동일한 관례).
/// 알 수 없는 값이 와도 디코딩 전체가 실패하지 않도록 Repository 매핑에서 걸러낸다.
public struct CommentSetDTO: Decodable, Sendable {
    public let concept: String
    public let emoji: String
    public let contents: [String]?
}
