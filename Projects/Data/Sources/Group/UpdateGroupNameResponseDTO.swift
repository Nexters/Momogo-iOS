import Foundation

public struct UpdateGroupNameResponseDTO: Decodable, Sendable {
    public let groupId: Int
    public let groupName: String
}
