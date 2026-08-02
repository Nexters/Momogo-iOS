import Foundation

public struct CreateGroupRequestDTO: Encodable, Sendable {
    public let groupName: String

    public init(groupName: String) {
        self.groupName = groupName
    }
}
