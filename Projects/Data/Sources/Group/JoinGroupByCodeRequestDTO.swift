import Foundation

public struct JoinGroupByCodeRequestDTO: Encodable, Sendable {
    public let code: String

    public init(code: String) {
        self.code = code
    }
}
