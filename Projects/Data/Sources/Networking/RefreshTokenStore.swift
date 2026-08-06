import Foundation

import Dependencies

/// 현재 로그인 세션의 리프레시 토큰을 들고 있는 저장소. `AccessTokenStore`와 동일한 lock 기반 패턴.
/// `/auth/reissue`는 rotation이라 재발급마다 값이 갱신된다.
/// `onUpdate`는 `liveValue`에서만 Keychain write-through에 쓰이고, 테스트에서 만드는 인스턴스는
/// 기본값(nil)이라 순수 메모리로만 동작해 실제 Keychain을 건드리지 않는다.
public final class RefreshTokenStore: @unchecked Sendable {
    private let lock = NSLock()
    private var token: String?
    private let onUpdate: (@Sendable (String?) -> Void)?

    public init(token: String? = nil, onUpdate: (@Sendable (String?) -> Void)? = nil) {
        self.token = token
        self.onUpdate = onUpdate
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
        onUpdate?(token)
    }
}

/// Keychain에 리프레시 토큰을 저장한다. 앱을 껐다 켜도 세션을 복구할 수 있어야 하므로 영속화가 필요하다.
private enum RefreshTokenKeychain {
    static let service = "com.momogo.refreshToken"
    static let account = "refreshToken"

    static func read() -> String? {
        KeychainStore.read(service: service, account: account)
    }

    static func save(_ token: String) {
        KeychainStore.save(token, service: service, account: account)
    }

    static func delete() {
        KeychainStore.delete(service: service, account: account)
    }
}

extension RefreshTokenStore: DependencyKey {
    public static var liveValue: RefreshTokenStore {
        RefreshTokenStore(
            token: RefreshTokenKeychain.read(),
            onUpdate: { token in
                if let token {
                    RefreshTokenKeychain.save(token)
                } else {
                    RefreshTokenKeychain.delete()
                }
            }
        )
    }

    public static let testValue = RefreshTokenStore()
}

public extension DependencyValues {
    var refreshTokenStore: RefreshTokenStore {
        get { self[RefreshTokenStore.self] }
        set { self[RefreshTokenStore.self] = newValue }
    }
}
