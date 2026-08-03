import Foundation

public struct CreateGroupResponseDTO: Decodable, Sendable {
    public let groupId: Int
    public let groupName: String
    public let inviteCode: String
}
