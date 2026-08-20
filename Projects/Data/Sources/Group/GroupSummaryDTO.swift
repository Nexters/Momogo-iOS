import Foundation

public struct GroupSummaryDTO: Decodable, Sendable {
    public let groupId: Int
    public let groupName: String
    public let totalMemberCount: Int
    public let todayPhotoUploaderCount: Int
    public let members: [GroupMemberStatusDTO]
    public let todayPhotoUploaded: Bool
    /// 나를 제외한 다른 그룹원이 올린 활성 사진의 최신 등록 시각(Asia/Seoul, 타임존 표기 없음). 없으면 nil.
    public let latestUploadAt: String?
    /// 그룹 생성 시각(Asia/Seoul, 타임존 표기 없음). 서버가 항상 내려주는 필수 필드.
    public let createdAt: String
}
