import Foundation

public struct UpdateUserRequestDTO: Encodable, Sendable {
    public let nickname: String

    public init(nickname: String) {
        self.nickname = nickname
    }
}
