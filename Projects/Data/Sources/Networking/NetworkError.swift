import Foundation

public enum NetworkError: Error {
    case decodingFailed(Error)
    case requestFailed(Error)
}
