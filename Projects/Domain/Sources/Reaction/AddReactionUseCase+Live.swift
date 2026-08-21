import Dependencies

import DomainInterface

extension AddReactionUseCase: DependencyKey {
    public static var liveValue: AddReactionUseCase {
        @Dependency(\.reactionRepository) var reactionRepository

        return AddReactionUseCase(
            execute: { request in
                try await reactionRepository.addReaction(request)
            }
        )
    }
}
