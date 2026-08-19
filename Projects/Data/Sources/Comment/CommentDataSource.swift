import Foundation

import Dependencies

public struct CommentDataSource: Sendable {
    public var fetch: @Sendable () async throws -> CommentsResponseDTO

    public init(fetch: @escaping @Sendable () async throws -> CommentsResponseDTO) {
        self.fetch = fetch
    }
}

public extension DependencyValues {
    var commentDataSource: CommentDataSource {
        get { self[CommentDataSource.self] }
        set { self[CommentDataSource.self] = newValue }
    }
}
