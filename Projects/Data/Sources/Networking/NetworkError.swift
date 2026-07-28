import Foundation

public enum NetworkError: Error {
    case decodingFailed(Error)
    case unauthorized
    case serverError(statusCode: Int)
    case underlying(Error)
}
