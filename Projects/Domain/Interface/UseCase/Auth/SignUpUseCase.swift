import Dependencies

/// 닉네임 입력 후 회원가입을 수행하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct SignUpUseCase: Sendable {
    public var execute: @Sendable (_ nickname: String) async throws -> SignUpResponse

    public init(execute: @escaping @Sendable (_ nickname: String) async throws -> SignUpResponse) {
        self.execute = execute
    }
}

extension SignUpUseCase: TestDependencyKey {
    public static let testValue = SignUpUseCase(
        execute: unimplemented("\(Self.self).execute")
    )
}

public extension DependencyValues {
    var signUpUseCase: SignUpUseCase {
        get { self[SignUpUseCase.self] }
        set { self[SignUpUseCase.self] = newValue }
    }
}
