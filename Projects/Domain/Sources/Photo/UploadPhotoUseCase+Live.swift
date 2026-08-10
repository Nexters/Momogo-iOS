import Dependencies

import DomainInterface

extension UploadPhotoUseCase: DependencyKey {
    public static var liveValue: UploadPhotoUseCase {
        @Dependency(\.photoRepository) var photoRepository

        return UploadPhotoUseCase(
            execute: { request in
                let issued = try await photoRepository.issueUploadURL(
                    IssuePhotoUploadURLRequest(contentType: request.contentType)
                )
                try await photoRepository.upload(issued.uploadURL, request.photoData, issued.contentType)
                let confirmed = try await photoRepository.confirm(
                    ConfirmPhotoUploadRequest(objectKey: issued.objectKey, groupIDs: request.groupIDs)
                )
                return UploadPhotoResponse(photoId: confirmed.photoId, objectKey: confirmed.objectKey)
            }
        )
    }
}
