import Foundation

public struct GroupSummaryDTO: Decodable, Sendable {
    public let groupId: Int
    public let groupName: String
    public let invitationCode: String
    public let participateMemberCount: Int
    public let totalMemberCount: Int
    public let joinedDate: String
    public let photos: [GroupPhotoDTO]
}
