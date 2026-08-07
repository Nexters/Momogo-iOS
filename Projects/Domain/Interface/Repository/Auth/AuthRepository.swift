import Dependencies

/// 인증/회원가입 API를 추상화한 포트. 실제(혹은 Mock) 구현은 Data 모듈에서 제공한다.
public struct AuthRepository: Sendable {
    public var signUp: @Sendable (_ request: SignUpRequest) async throws -> SignUpResponse
    /// 로컬 refreshToken으로 세션을 갱신한다. refreshToken 조회/저장/삭제는 Data 레이어 내부에 캡슐화되어 있어 유효 여부(Bool)만 반환한다.
    public var refreshSession: @Sendable () async -> Bool
    /// 로컬에 저장된(또는 새로 발급한) 게스트 토큰으로 로그인을 시도한다. 성공/실패만 반환하고 토큰 저장은 Data 레이어가 담당한다.
    public var login: @Sendable () async -> Bool
    /// 현재 세션을 서버에서 로그아웃 처리한다. 세션이 없으면 즉시 성공으로 취급한다.
    public var logout: @Sendable () async -> Bool
    /// 서버 호출 없이 로컬에 저장된 accessToken/refreshToken/게스트 UUID를 전부 지운다. 완전히 새 유저 상태를 재현하기 위한 디버그용.
    public var clearLocalAuthState: @Sendable () -> Void

    public init(
        signUp: @escaping @Sendable (_ request: SignUpRequest) async throws -> SignUpResponse,
        refreshSession: @escaping @Sendable () async -> Bool,
        login: @escaping @Sendable () async -> Bool,
        logout: @escaping @Sendable () async -> Bool,
        clearLocalAuthState: @escaping @Sendable () -> Void
    ) {
        self.signUp = signUp
        self.refreshSession = refreshSession
        self.login = login
        self.logout = logout
        self.clearLocalAuthState = clearLocalAuthState
    }
}

extension AuthRepository: TestDependencyKey {
    public static let testValue = AuthRepository(
        signUp: unimplemented("\(Self.self).signUp"),
        refreshSession: unimplemented("\(Self.self).refreshSession", placeholder: false),
        login: unimplemented("\(Self.self).login", placeholder: false),
        logout: unimplemented("\(Self.self).logout", placeholder: false),
        clearLocalAuthState: unimplemented("\(Self.self).clearLocalAuthState")
    )
}

public extension DependencyValues {
    var authRepository: AuthRepository {
        get { self[AuthRepository.self] }
        set { self[AuthRepository.self] = newValue }
    }
}
