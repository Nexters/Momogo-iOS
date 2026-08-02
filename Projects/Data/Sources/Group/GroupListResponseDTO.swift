import Foundation

public struct GroupListResponseDTO: Decodable, Sendable {
    public let groups: [GroupSummaryDTO]
}
