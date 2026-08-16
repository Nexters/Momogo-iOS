import Foundation

public struct RegisterRequestDTO: Encodable, Sendable {
    public let provider: AuthProvider
    public let providerToken: String
    public let nickname: String

    public init(provider: AuthProvider, providerToken: String, nickname: String) {
        self.provider = provider
        self.providerToken = providerToken
        self.nickname = nickname
    }
}
