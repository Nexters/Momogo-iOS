import Dependencies

import DomainInterface

extension GetGroupVisitsUseCase: @retroactive DependencyKey {
    public static var liveValue: GetGroupVisitsUseCase {
        @Dependency(\.groupVisitStore) var groupVisitStore

        return GetGroupVisitsUseCase(
            execute: {
                groupVisitStore.lastSeenUploadAt()
            }
        )
    }
}
