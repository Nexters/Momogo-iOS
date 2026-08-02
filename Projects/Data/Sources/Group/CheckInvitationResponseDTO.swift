import Foundation

public struct CheckInvitationResponseDTO: Decodable, Sendable {
    public let groupId: Int
    public let groupName: String
    public let totalMemberCount: Int
    public let participated: Bool
}
