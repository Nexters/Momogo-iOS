import Dependencies

/// 리액션 문구 카탈로그를 로컬(디스크)에 저장하는 포트. 실제 구현은 Data 모듈에서 제공한다.
/// `GroupVisitStore`와 동일한 형태 — 저장 정책(언제 덮어쓸지)은 UseCase가 결정하고, 이 포트는
/// 순수 I/O만 담당한다.
public struct CommentCatalogStore: Sendable {
    /// 캐시가 없거나 읽기에 실패하면 nil.
    public var load: @Sendable () -> CommentCatalog?
    /// 유효성 검사(빈 카탈로그 덮어쓰기 방지 등)는 호출부 책임이다. 이 클로저는 그대로 저장만 한다.
    public var save: @Sendable (CommentCatalog) -> Void

    public init(
        load: @escaping @Sendable () -> CommentCatalog?,
        save: @escaping @Sendable (CommentCatalog) -> Void
    ) {
        self.load = load
        self.save = save
    }
}

extension CommentCatalogStore: TestDependencyKey {
    public static let testValue = CommentCatalogStore(
        load: unimplemented("\(Self.self).load", placeholder: nil),
        save: unimplemented("\(Self.self).save")
    )
}

public extension DependencyValues {
    var commentCatalogStore: CommentCatalogStore {
        get { self[CommentCatalogStore.self] }
        set { self[CommentCatalogStore.self] = newValue }
    }
}
