import Foundation

public struct UpdateGroupNameRequestDTO: Encodable, Sendable {
    public let groupName: String

    enum CodingKeys: String, CodingKey {
        case groupName = "name"
    }

    public init(groupName: String) {
        self.groupName = groupName
    }
}
