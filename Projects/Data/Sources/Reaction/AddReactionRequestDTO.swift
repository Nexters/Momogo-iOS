import Foundation

public struct AddReactionRequestDTO: Encodable, Sendable {
    public let type: String
    public let comment: String?
    public let date: String

    public init(type: String, comment: String?, date: String) {
        self.type = type
        self.comment = comment
        self.date = date
    }
}
