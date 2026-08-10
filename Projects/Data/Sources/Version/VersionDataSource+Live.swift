import Foundation

import Dependencies

extension VersionDataSource: DependencyKey {
    public static var liveValue: VersionDataSource {
        @Dependency(\.networkClient) var networkClient

        return VersionDataSource(
            check: {
                try await networkClient.requestDecodable(VersionTargetType.check)
            }
        )
    }

    public static let testValue = VersionDataSource(
        check: unimplemented("\(Self.self).check")
    )
}
