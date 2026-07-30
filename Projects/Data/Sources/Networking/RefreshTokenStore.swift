import Foundation

import Dependencies

/// 현재 로그인 세션의 리프레시 토큰을 들고 있는 저장소. `AccessTokenStore`와 동일한 lock 기반 패턴.
/// `/auth/reissue`는 rotation이라 재발급마다 값이 갱신된다.
public final class RefreshTokenStore: @unchecked Sendable {
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

extension RefreshTokenStore: DependencyKey {
    public static let liveValue = RefreshTokenStore()
    public static let testValue = RefreshTokenStore()
}

public extension DependencyValues {
    var refreshTokenStore: RefreshTokenStore {
        get { self[RefreshTokenStore.self] }
        set { self[RefreshTokenStore.self] = newValue }
    }
}
