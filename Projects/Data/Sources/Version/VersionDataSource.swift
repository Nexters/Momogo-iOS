import Foundation

import Dependencies

public struct VersionDataSource: Sendable {
    public var check: @Sendable () async throws -> AppVersionResponseDTO

    public init(check: @escaping @Sendable () async throws -> AppVersionResponseDTO) {
        self.check = check
    }
}

public extension DependencyValues {
    var versionDataSource: VersionDataSource {
        get { self[VersionDataSource.self] }
        set { self[VersionDataSource.self] = newValue }
    }
}
