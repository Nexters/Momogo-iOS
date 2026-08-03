import Foundation

import Dependencies

/// 게스트 회원가입 시 사용할 providerToken을 만들고 영속화하는 로컬 저장소 포트. 실제 구현은 Data 모듈에서 제공한다.
/// 로그인(`/auth/login`)은 이전에 발급한 providerToken을 재사용해 같은 계정으로 돌아가야 하므로 `fetchOrCreate`를 쓰고,
/// 회원가입은 매번 새 계정이어야 하므로 `clear`로 기존 값을 지운 뒤 `fetchOrCreate`를 호출해 새로 발급받는다.
public struct GuestTokenStore: Sendable {
    public var fetchOrCreate: @Sendable () -> String
    public var clear: @Sendable () -> Void

    public init(
        fetchOrCreate: @escaping @Sendable () -> String,
        clear: @escaping @Sendable () -> Void
    ) {
        self.fetchOrCreate = fetchOrCreate
        self.clear = clear
    }
}

extension GuestTokenStore: TestDependencyKey {
    public static let testValue = GuestTokenStore(
        fetchOrCreate: unimplemented("\(Self.self).fetchOrCreate", placeholder: UUID().uuidString),
        clear: unimplemented("\(Self.self).clear")
    )
}

public extension DependencyValues {
    var guestTokenStore: GuestTokenStore {
        get { self[GuestTokenStore.self] }
        set { self[GuestTokenStore.self] = newValue }
    }
}
