import Foundation

public struct AppVersionResponseDTO: Decodable, Sendable {
    public let latestVersion: String
    public let minSupportedVersion: String
    public let forceUpdate: Bool
    public let updateUrl: String
}
