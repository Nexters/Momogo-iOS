import Foundation

/// `GET /init/comments` 응답. `revision`은 등록된 문구가 없으면 null이고, `comments`도 스펙상
/// 빈 배열이 기본이지만 방어적으로 Optional로 받는다(non-optional이면 `"comments": null`에서
/// 디코딩 전체가 실패한다).
public struct CommentsResponseDTO: Decodable, Sendable {
    public let revision: String?
    public let comments: [CommentSetDTO]?
}
