import Foundation

/// 그룹원이 선택 날짜에 올린 사진(`GroupMemberResponseDTO.photo`).
/// 서버 응답의 `latestReaction`은 이 화면(그룹상세)에서 쓰지 않아 매핑하지 않는다.
public struct GroupPhotoResponseDTO: Decodable, Sendable {
    public let photoId: Int
    public let downloadUrl: String
    public let contentType: String
    public let createdAt: String
    public let expiresAt: String
}
