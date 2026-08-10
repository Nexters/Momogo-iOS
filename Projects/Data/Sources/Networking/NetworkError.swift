import Foundation

public struct ProblemDetail: Decodable, Sendable {
    public let type: String?
    public let title: String
    public let status: Int
    public let detail: String
    public let instance: String?
    public let code: String?
}

public enum NetworkError: Error {
    case decodingFailed(Error)
    case unauthorized(problem: ProblemDetail?)
    case serverError(statusCode: Int, problem: ProblemDetail?)
    case underlying(Error)
}
