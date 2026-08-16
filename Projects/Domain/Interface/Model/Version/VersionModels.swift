import Foundation

/// 앱 버전 체크 결과. `updateURL`은 서버 응답의 `updateUrl`이 유효한 URL일 때만 채워진다.
public struct AppVersionCheckResult: Sendable, Equatable {
    public let isForceUpdateRequired: Bool
    public let updateURL: URL?

    public init(isForceUpdateRequired: Bool, updateURL: URL?) {
        self.isForceUpdateRequired = isForceUpdateRequired
        self.updateURL = updateURL
    }
}
