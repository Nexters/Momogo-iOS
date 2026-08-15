import Foundation

public struct PhotoReportRequestDTO: Encodable, Sendable {
    public let reason: String

    public init(reason: String) {
        self.reason = reason
    }
}
