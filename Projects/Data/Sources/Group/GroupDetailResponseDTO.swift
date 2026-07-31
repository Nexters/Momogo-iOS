import Foundation

public struct GroupDetailResponseDTO: Decodable, Sendable {
    public let date: String
    public let todayVerifiedCount: Int
    public let totalMemberCount: Int
    public let invitationCode: String
    public let members: [GroupMemberStatusDTO]
}
