import Dependencies

import DomainInterface

extension ReportPhotoUseCase: DependencyKey {
    public static var liveValue: ReportPhotoUseCase {
        @Dependency(\.groupRepository) var groupRepository

        return ReportPhotoUseCase(
            execute: { request in
                try await groupRepository.reportPhoto(request)
            }
        )
    }
}
