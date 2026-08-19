import Dependencies

/// 사진 리액션 등록·조회 API를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
public struct ReactionRepository: Sendable {
    public var addReaction: @Sendable (AddReactionRequest) async throws -> Void
    public var fetchReactions: @Sendable (_ groupId: Int, _ photoId: Int) async throws -> [PhotoReaction]

    public init(
        addReaction: @escaping @Sendable (AddReactionRequest) async throws -> Void,
        fetchReactions: @escaping @Sendable (_ groupId: Int, _ photoId: Int) async throws -> [PhotoReaction]
    ) {
        self.addReaction = addReaction
        self.fetchReactions = fetchReactions
    }
}

extension ReactionRepository: TestDependencyKey {
    public static let testValue = ReactionRepository(
        addReaction: unimplemented("\(Self.self).addReaction"),
        fetchReactions: unimplemented("\(Self.self).fetchReactions", placeholder: [])
    )
}

public extension DependencyValues {
    var reactionRepository: ReactionRepository {
        get { self[ReactionRepository.self] }
        set { self[ReactionRepository.self] = newValue }
    }
}
