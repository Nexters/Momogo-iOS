import Dependencies

/// 유저 정보 관련 API를 추상화한 포트. 실제(혹은 Mock) 구현은 Data 모듈에서 제공한다.
/// 로컬 인증 상태(토큰/게스트 UUID) 정리는 이 Repository의 책임이 아니다 — AuthRepository가 담당한다.
public struct UserRepository: Sendable {
    public var updateNickname: @Sendable (_ nickname: String) async throws -> Void
    public var deleteAccount: @Sendable () async throws -> Void

    public init(
        updateNickname: @escaping @Sendable (_ nickname: String) async throws -> Void,
        deleteAccount: @escaping @Sendable () async throws -> Void
    ) {
        self.updateNickname = updateNickname
        self.deleteAccount = deleteAccount
    }
}

extension UserRepository: TestDependencyKey {
    public static let testValue = UserRepository(
        updateNickname: unimplemented("\(Self.self).updateNickname"),
        deleteAccount: unimplemented("\(Self.self).deleteAccount")
    )
}

public extension DependencyValues {
    var userRepository: UserRepository {
        get { self[UserRepository.self] }
        set { self[UserRepository.self] = newValue }
    }
}
