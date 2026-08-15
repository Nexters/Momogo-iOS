import Dependencies

import DomainInterface

extension GetMyPhotosUseCase: DependencyKey {
    public static var liveValue: GetMyPhotosUseCase {
        @Dependency(\.photoRepository) var photoRepository

        return GetMyPhotosUseCase(
            execute: { request in
                try await photoRepository.getMyPhotos(request)
            }
        )
    }
}
