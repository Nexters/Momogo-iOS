import Foundation

public struct LoginRequestDTO: Encodable, Sendable {
    public let provider: AuthProvider
    public let providerToken: String

    public init(provider: AuthProvider, providerToken: String) {
        self.provider = provider
        self.providerToken = providerToken
    }
}
