import Dependencies

import DomainInterface

extension DeletePhotoUseCase: DependencyKey {
    public static var liveValue: DeletePhotoUseCase {
        @Dependency(\.groupRepository) var groupRepository

        return DeletePhotoUseCase(
            execute: { request in
                try await groupRepository.deletePhoto(request)
            }
        )
    }
}
