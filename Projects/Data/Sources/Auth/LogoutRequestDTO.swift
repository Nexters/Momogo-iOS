import Foundation

public struct LogoutRequestDTO: Encodable, Sendable {
    public let refreshToken: String

    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}
