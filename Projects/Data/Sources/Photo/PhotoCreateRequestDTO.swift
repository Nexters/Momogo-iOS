import Foundation

public struct PhotoCreateRequestDTO: Encodable, Sendable {
    public let objectKey: String
    public let groupIds: [Int]

    public init(objectKey: String, groupIds: [Int]) {
        self.objectKey = objectKey
        self.groupIds = groupIds
    }
}
