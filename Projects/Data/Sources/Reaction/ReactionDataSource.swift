import Foundation

import Dependencies

public struct ReactionDataSource: Sendable {
    public var add: @Sendable (Int, Int, AddReactionRequestDTO) async throws -> AddReactionResponseDTO
    public var page: @Sendable (Int, Int, String?) async throws -> AddReactionResponseDTO

    public init(
        add: @escaping @Sendable (Int, Int, AddReactionRequestDTO) async throws -> AddReactionResponseDTO,
        page: @escaping @Sendable (Int, Int, String?) async throws -> AddReactionResponseDTO
    ) {
        self.add = add
        self.page = page
    }
}

public extension DependencyValues {
    var reactionDataSource: ReactionDataSource {
        get { self[ReactionDataSource.self] }
        set { self[ReactionDataSource.self] = newValue }
    }
}
