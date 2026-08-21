import Foundation

import Dependencies

import DomainInterface

extension ReactionRepository: DependencyKey {
    public static var liveValue: ReactionRepository {
        @Dependency(\.reactionDataSource) var reactionDataSource

        return ReactionRepository(
            addReaction: { request in
                try await reactionDataSource.add(
                    request.groupId,
                    request.photoId,
                    AddReactionRequestDTO(
                        concept: request.concept.rawValue,
                        emoji: request.emoji.rawValue,
                        comment: request.comment
                    )
                )
            },
            fetchReactions: { groupId, photoId in
                let dto = try await reactionDataSource.list(groupId, photoId)
                return dto.reactions.compactMap { entry -> PhotoReaction? in
                    guard
                        let concept = CommentConcept(rawValue: entry.concept),
                        let emoji = CommentEmoji(rawValue: entry.emoji)
                    else { return nil } // 클라이언트가 모르는 콘셉트·이모지 값이 오면 그 항목만 조용히 드롭
                    return PhotoReaction(
                        reactionId: entry.reactionId,
                        userId: entry.userId,
                        nickname: entry.nickname,
                        concept: concept,
                        emoji: emoji,
                        comment: entry.comment,
                        createdAt: entry.createdAt,
                        isMine: entry.mine
                    )
                }
            }
        )
    }
}
