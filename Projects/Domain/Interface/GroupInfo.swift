import Foundation

// TODO: Response 확정되면 변경 및 제거
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
