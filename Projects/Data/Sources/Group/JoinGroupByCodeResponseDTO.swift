import Foundation

public struct JoinGroupByCodeResponseDTO: Decodable, Sendable {
    public let groupId: Int
    public let code: String
}
