import Dependencies

import DomainInterface

extension GetReactionsUseCase: DependencyKey {
    public static var liveValue: GetReactionsUseCase {
        @Dependency(\.reactionRepository) var reactionRepository

        return GetReactionsUseCase(
            execute: { groupId, photoId in
                try await reactionRepository.fetchReactions(groupId, photoId)
            }
        )
    }
}
