import Foundation

public enum MediaUploadError: Error {
    case invalidResponse
    case uploadFailed(statusCode: Int?)
}
