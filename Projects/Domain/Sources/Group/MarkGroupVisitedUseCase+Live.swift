import Dependencies

import DomainInterface

extension MarkGroupVisitedUseCase: @retroactive DependencyKey {
    public static var liveValue: MarkGroupVisitedUseCase {
        @Dependency(\.groupVisitStore) var groupVisitStore

        return MarkGroupVisitedUseCase(
            execute: { groupId, latestUploadAt in
                groupVisitStore.markSeen(groupId, latestUploadAt)
            }
        )
    }
}
