import Foundation

public struct ReactionCountDTO: Decodable, Sendable {
    public let type: String
    public let count: Int
}
