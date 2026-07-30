import Foundation

public struct UpdateUserResponseDTO: Decodable, Sendable {
    public let userId: Int
    public let nickname: String
}
