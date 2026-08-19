import Dependencies

/// 로컬에 캐시된 리액션 문구 카탈로그에서 콘셉트×이모지 조합의 문구 후보를 동기로 조회하는 UseCase.
/// 캐시가 없거나 그 조합의 문구가 없으면 빈 배열을 반환한다 — 호출부(반응 화면)는 빈 배열을
/// "서버 문구 없음"으로 보고 자체 폴백 문구를 쓴다.
public struct GetCommentsUseCase: Sendable {
    public var execute: @Sendable (CommentConcept, CommentEmoji) -> [String]

    public init(execute: @escaping @Sendable (CommentConcept, CommentEmoji) -> [String]) {
        self.execute = execute
    }
}

extension GetCommentsUseCase: TestDependencyKey {
    public static let testValue = GetCommentsUseCase(
        execute: unimplemented("\(Self.self).execute", placeholder: [])
    )
}

public extension DependencyValues {
    var getCommentsUseCase: GetCommentsUseCase {
        get { self[GetCommentsUseCase.self] }
        set { self[GetCommentsUseCase.self] = newValue }
    }
}
