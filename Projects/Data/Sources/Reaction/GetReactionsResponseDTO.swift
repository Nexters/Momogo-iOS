import Foundation

/// `GET .../reactions` 응답. 필드명은 실제 문서로 확인됐다.
public struct GetReactionsResponseDTO: Decodable, Sendable {
    public let photoId: Int
    public let groupId: Int
    public let reactions: [ReactionEntryDTO]
}
