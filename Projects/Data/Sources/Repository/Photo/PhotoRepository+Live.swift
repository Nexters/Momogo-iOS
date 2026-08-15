import Foundation

import Dependencies

import DomainInterface

extension PhotoRepository: DependencyKey {
    public static var liveValue: PhotoRepository {
        @Dependency(\.photoDataSource) var photoDataSource

        return PhotoRepository(
            issueUploadURL: { request in
                let dto = try await photoDataSource.issueUploadURL(
                    PhotoUploadUrlRequestDTO(contentType: request.contentType)
                )
                guard let uploadURL = URL(string: dto.uploadUrl) else {
                    throw PhotoRepositoryError.invalidUploadURL
                }
                return IssuePhotoUploadURLResponse(
                    uploadURL: uploadURL,
                    objectKey: dto.objectKey,
                    contentType: dto.contentType
                )
            },
            upload: { url, data, contentType in
                try await photoDataSource.upload(url, data, contentType)
            },
            confirm: { request in
                let dto = try await photoDataSource.confirm(
                    PhotoCreateRequestDTO(objectKey: request.objectKey, groupIds: request.groupIDs)
                )
                return ConfirmPhotoUploadResponse(photoId: dto.photoId, objectKey: dto.objectKey)
            },
            getMyPhotos: { request in
                let dto = try await photoDataSource.myPhotos(request.date)
                return GetMyPhotosResponse(
                    date: dto.date,
                    photos: dto.photos.map { photo in
                        MyPhoto(
                            photoId: photo.photoId,
                            downloadUrl: photo.downloadUrl,
                            contentType: photo.contentType,
                            createdAt: photo.createdAt,
                            expiresAt: photo.expiresAt
                        )
                    }
                )
            }
        )
    }
}
