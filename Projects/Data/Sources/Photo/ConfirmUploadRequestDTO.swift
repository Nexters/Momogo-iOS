import Foundation

public struct ConfirmUploadRequestDTO: Encodable, Sendable {
    public let uploadSessionId: Int

    public init(uploadSessionId: Int) {
        self.uploadSessionId = uploadSessionId
    }
}
