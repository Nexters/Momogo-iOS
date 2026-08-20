import Foundation

/// 사진 리액션 등록 요청. `concept`/`emoji` 필드명과 값 어휘는 실제 요청으로 확인됐다
/// (`concept: "YOUNG_CREATOR_CREW"`, `emoji: "DELICIOUS"`). 카탈로그 조회(`/init/comments`)와
/// 같은 어휘를 그대로 쓰는 것으로 확인돼 `CommentConcept`/`CommentEmoji`를 재사용한다.
public struct AddReactionRequest: Sendable, Equatable {
    public let groupId: Int
    public let photoId: Int
    public let concept: CommentConcept
    public let emoji: CommentEmoji
    public let comment: String

    public init(groupId: Int, photoId: Int, concept: CommentConcept, emoji: CommentEmoji, comment: String) {
        self.groupId = groupId
        self.photoId = photoId
        self.concept = concept
        self.emoji = emoji
        self.comment = comment
    }
}

/// 사진에 달린 리액션 하나. `GET .../reactions` 응답 필드는 실제 문서로 확인됐다.
public struct PhotoReaction: Sendable, Equatable {
    public let reactionId: Int
    public let userId: Int
    public let nickname: String
    public let concept: CommentConcept
    public let emoji: CommentEmoji
    public let comment: String
    public let createdAt: String
    /// 서버가 직접 계산해서 내려주는 값 — 클라이언트가 "내 userId"를 따로 알 필요가 없다.
    public let isMine: Bool

    public init(
        reactionId: Int,
        userId: Int,
        nickname: String,
        concept: CommentConcept,
        emoji: CommentEmoji,
        comment: String,
        createdAt: String,
        isMine: Bool
    ) {
        self.reactionId = reactionId
        self.userId = userId
        self.nickname = nickname
        self.concept = concept
        self.emoji = emoji
        self.comment = comment
        self.createdAt = createdAt
        self.isMine = isMine
    }
}
