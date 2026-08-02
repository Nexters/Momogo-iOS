import Foundation

public struct ReissueResponseDTO: Decodable, Sendable {
    public let accessToken: String
    public let refreshToken: String
}
