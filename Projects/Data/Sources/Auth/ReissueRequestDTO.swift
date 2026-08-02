import Foundation

public struct ReissueRequestDTO: Encodable, Sendable {
    public let refreshToken: String

    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}
