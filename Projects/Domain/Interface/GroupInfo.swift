import Foundation

public struct GroupInfo: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let inviteCode: String

    public init(id: String, name: String, inviteCode: String) {
        self.id = id
        self.name = name
        self.inviteCode = inviteCode
    }
}
