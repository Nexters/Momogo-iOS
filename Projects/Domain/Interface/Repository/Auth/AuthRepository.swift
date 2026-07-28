import Dependencies

/// 인증/회원가입 API를 추상화한 포트. 실제(혹은 Mock) 구현은 Data 모듈에서 제공한다.
public struct AuthRepository: Sendable {
    public var signUp: @Sendable (_ request: SignUpRequest) async throws -> SignUpResponse

    public init(signUp: @escaping @Sendable (_ request: SignUpRequest) async throws -> SignUpResponse) {
        self.signUp = signUp
    }
}

extension AuthRepository: TestDependencyKey {
    public static let testValue = AuthRepository(
        signUp: unimplemented("\(Self.self).signUp")
    )
}

public extension DependencyValues {
    var authRepository: AuthRepository {
        get { self[AuthRepository.self] }
        set { self[AuthRepository.self] = newValue }
    }
}
