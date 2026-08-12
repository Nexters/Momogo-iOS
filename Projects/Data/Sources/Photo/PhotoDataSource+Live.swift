import Foundation

import Dependencies

extension PhotoDataSource: DependencyKey {
    public static var liveValue: PhotoDataSource {
        @Dependency(\.networkClient) var networkClient
        @Dependency(\.mediaUploadClient) var mediaUploadClient

        return PhotoDataSource(
            issueUploadURL: { request in
                try await networkClient.requestDecodable(PhotoTargetType.issueUploadURL(request))
            },
            confirm: { request in
                try await networkClient.requestDecodable(PhotoTargetType.confirm(request))
            },
            upload: { url, data, contentType in
                try await mediaUploadClient.upload(url, data, contentType)
            }
        )
    }

    public static let testValue = PhotoDataSource(
        issueUploadURL: unimplemented("\(Self.self).issueUploadURL"),
        confirm: unimplemented("\(Self.self).confirm"),
        upload: unimplemented("\(Self.self).upload")
    )
}
