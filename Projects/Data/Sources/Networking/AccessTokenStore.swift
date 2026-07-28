import Foundation

import Dependencies

/// 현재 로그인 세션의 액세스 토큰을 들고 있는 저장소.
/// Moya 플러그인 호출은 동기라서 actor 대신 락 기반으로 구현한다.
/// 로그인 기능이 붙기 전까지는 아무도 값을 채우지 않으므로 인증 불필요한 API만 있는 지금 상태와 호환된다.
public final class AccessTokenStore: @unchecked Sendable {
    private let lock = NSLock()
    private var token: String?

    public init(token: String? = nil) {
        self.token = token
    }

    public func current() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return token
    }

    public func update(_ token: String?) {
        lock.lock()
        defer { lock.unlock() }
        self.token = token
    }
}

extension AccessTokenStore: DependencyKey {
    public static let liveValue = AccessTokenStore()
    public static let testValue = AccessTokenStore()
}

public extension DependencyValues {
    var accessTokenStore: AccessTokenStore {
        get { self[AccessTokenStore.self] }
        set { self[AccessTokenStore.self] = newValue }
    }
}
