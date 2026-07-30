import Foundation

import Dependencies

extension PhotoDataSource: DependencyKey {
    public static var liveValue: PhotoDataSource {
        @Dependency(\.networkClient) var networkClient

        return PhotoDataSource(
            createUploadSession: { request in
                try await networkClient.requestDecodable(PhotoTargetType.createUploadSession(request))
            },
            confirm: { request in
                try await networkClient.requestDecodable(PhotoTargetType.confirm(request))
            }
        )
    }

    public static let testValue = PhotoDataSource(
        createUploadSession: unimplemented("\(Self.self).createUploadSession"),
        confirm: unimplemented("\(Self.self).confirm")
    )
}
