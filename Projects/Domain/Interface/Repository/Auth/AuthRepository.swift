import Dependencies

/// 인증/회원가입 API를 추상화한 포트. 실제(혹은 Mock) 구현은 Data 모듈에서 제공한다.
public struct AuthRepository: Sendable {
    public var signUp: @Sendable (_ request: SignUpRequest) async throws -> SignUpResponse
    /// 로컬 refreshToken으로 세션을 갱신한다. refreshToken 조회/저장/삭제는 Data 레이어 내부에 캡슐화되어 있어 유효 여부(Bool)만 반환한다.
    public var refreshSession: @Sendable () async -> Bool

    public init(
        signUp: @escaping @Sendable (_ request: SignUpRequest) async throws -> SignUpResponse,
        refreshSession: @escaping @Sendable () async -> Bool
    ) {
        self.signUp = signUp
        self.refreshSession = refreshSession
    }
}

extension AuthRepository: TestDependencyKey {
    public static let testValue = AuthRepository(
        signUp: unimplemented("\(Self.self).signUp"),
        refreshSession: unimplemented("\(Self.self).refreshSession", placeholder: false)
    )
}

public extension DependencyValues {
    var authRepository: AuthRepository {
        get { self[AuthRepository.self] }
        set { self[AuthRepository.self] = newValue }
    }
}
