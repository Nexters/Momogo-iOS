import Dependencies

import DomainInterface

extension GetCommentsUseCase: DependencyKey {
    public static var liveValue: GetCommentsUseCase {
        @Dependency(\.commentCatalogStore) var commentCatalogStore

        return GetCommentsUseCase(
            execute: { concept, emoji in
                commentCatalogStore.load()?.contents(concept: concept, emoji: emoji) ?? []
            }
        )
    }
}
