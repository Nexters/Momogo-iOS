import Foundation

public struct UpdateGroupNameRequestDTO: Encodable, Sendable {
    public let groupName: String

    public init(groupName: String) {
        self.groupName = groupName
    }
}
