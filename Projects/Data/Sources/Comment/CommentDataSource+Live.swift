import Foundation

import Dependencies

extension CommentDataSource: DependencyKey {
    public static var liveValue: CommentDataSource {
        @Dependency(\.networkClient) var networkClient

        return CommentDataSource(
            fetch: {
                try await networkClient.requestDecodable(CommentTargetType.fetch)
            }
        )
    }

    public static let testValue = CommentDataSource(
        fetch: unimplemented("\(Self.self).fetch")
    )
}
