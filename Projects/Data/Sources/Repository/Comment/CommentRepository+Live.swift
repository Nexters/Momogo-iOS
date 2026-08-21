import Foundation

import Dependencies

import DomainInterface

extension CommentRepository: DependencyKey {
    public static var liveValue: CommentRepository {
        @Dependency(\.commentDataSource) var commentDataSource

        return CommentRepository(
            fetchCatalog: {
                let dto = try await commentDataSource.fetch()

                // 서버가 아는 콘셉트/이모지가 클라이언트에 아직 없는 케이스(또는 문구가 빈 조합)는
                // 조용히 걸러낸다. 이 조합만 없을 뿐 응답 전체를 실패시키지 않는다.
                let sets = (dto.comments ?? []).compactMap { setDTO -> CommentSet? in
                    guard
                        let concept = CommentConcept(rawValue: setDTO.concept),
                        let emoji = CommentEmoji(rawValue: setDTO.emoji),
                        let contents = setDTO.contents,
                        !contents.isEmpty
                    else { return nil }
                    return CommentSet(concept: concept, emoji: emoji, contents: contents)
                }

                return CommentCatalog(revision: dto.revision, sets: sets)
            }
        )
    }
}
