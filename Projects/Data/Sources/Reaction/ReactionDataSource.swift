import Foundation

import Dependencies

public struct ReactionDataSource: Sendable {
    /// 응답을 파싱하지 않는다 — 클라이언트는 이미 등록할 문구를 알고 있고, 응답 스키마는 미확인이라
    /// 잘못 짐작해서 디코딩하면 "요청은 성공했는데 파싱 실패로 등록 실패로 둔갑"하는 게 더 나쁘다.
    public var add: @Sendable (_ groupId: Int, _ photoId: Int, AddReactionRequestDTO) async throws -> Void
    public var list: @Sendable (_ groupId: Int, _ photoId: Int) async throws -> GetReactionsResponseDTO

    public init(
        add: @escaping @Sendable (_ groupId: Int, _ photoId: Int, AddReactionRequestDTO) async throws -> Void,
        list: @escaping @Sendable (_ groupId: Int, _ photoId: Int) async throws -> GetReactionsResponseDTO
    ) {
        self.add = add
        self.list = list
    }
}

public extension DependencyValues {
    var reactionDataSource: ReactionDataSource {
        get { self[ReactionDataSource.self] }
        set { self[ReactionDataSource.self] = newValue }
    }
}
