import Foundation

public struct GroupDetailResponseDTO: Decodable, Sendable {
    public let groupId: Int
    public let groupName: String
    public let members: [GroupMemberStatusDTO]
}
