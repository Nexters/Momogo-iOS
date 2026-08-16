import Foundation

public struct GroupSummaryDTO: Decodable, Sendable {
    public let groupId: Int
    public let groupName: String
    public let totalMemberCount: Int
    public let todayPhotoUploaderCount: Int
    public let members: [GroupMemberStatusDTO]
    public let todayPhotoUploaded: Bool
}
