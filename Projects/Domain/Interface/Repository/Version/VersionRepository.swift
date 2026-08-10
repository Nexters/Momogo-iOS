import Dependencies

/// 앱 버전 체크 API를 추상화한 포트. 실제(혹은 Mock) 구현은 Data 모듈에서 제공한다.
public struct VersionRepository: Sendable {
    public var checkAppVersion: @Sendable () async throws -> AppVersionCheckResult

    public init(checkAppVersion: @escaping @Sendable () async throws -> AppVersionCheckResult) {
        self.checkAppVersion = checkAppVersion
    }
}

extension VersionRepository: TestDependencyKey {
    public static let testValue = VersionRepository(
        checkAppVersion: unimplemented("\(Self.self).checkAppVersion")
    )
}

public extension DependencyValues {
    var versionRepository: VersionRepository {
        get { self[VersionRepository.self] }
        set { self[VersionRepository.self] = newValue }
    }
}
