import Foundation

public struct CreateGroupRequestDTO: Encodable, Sendable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}
