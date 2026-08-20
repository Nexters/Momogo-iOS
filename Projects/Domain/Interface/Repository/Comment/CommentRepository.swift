import Dependencies

/// 리액션 문구 카탈로그 조회 API를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
public struct CommentRepository: Sendable {
    public var fetchCatalog: @Sendable () async throws -> CommentCatalog

    public init(fetchCatalog: @escaping @Sendable () async throws -> CommentCatalog) {
        self.fetchCatalog = fetchCatalog
    }
}

extension CommentRepository: TestDependencyKey {
    public static let testValue = CommentRepository(
        fetchCatalog: unimplemented("\(Self.self).fetchCatalog")
    )
}

public extension DependencyValues {
    var commentRepository: CommentRepository {
        get { self[CommentRepository.self] }
        set { self[CommentRepository.self] = newValue }
    }
}
