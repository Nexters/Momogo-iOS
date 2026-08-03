import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Domain

struct SignUpUseCaseTests {
    @Test("회원가입 시 기존 게스트 토큰을 지운 뒤 새로 발급받아 요청하고, Repository 응답을 그대로 반환한다")
    func execute_success_clearsTokenBeforeIssuingAndReturnsResponse() async throws {
        let callOrder = Locked<[String]>([])
        let capturedRequest = Locked<SignUpRequest?>(nil)

        let useCase = withDependencies {
            $0.guestTokenStore = GuestTokenStore(
                fetchOrCreate: {
                    callOrder.mutate { $0.append("fetchOrCreate") }
                    return "new-guest-token"
                },
                clear: {
                    callOrder.mutate { $0.append("clear") }
                }
            )
            $0.authRepository = AuthRepository(
                signUp: { request in
                    capturedRequest.set(request)
                    return SignUpResponse(
                        userId: 1,
                        nickname: request.nickname,
                        accessToken: "access-token",
                        refreshToken: "refresh-token"
                    )
                }
            )
        } operation: {
            SignUpUseCase.liveValue
        }

        let response = try await useCase.execute("모모")

        #expect(callOrder.get() == ["clear", "fetchOrCreate"])
        #expect(capturedRequest.get()?.provider == .guest)
        #expect(capturedRequest.get()?.providerToken == "new-guest-token")
        #expect(capturedRequest.get()?.nickname == "모모")
        #expect(response.nickname == "모모")
        #expect(response.accessToken == "access-token")
        #expect(response.refreshToken == "refresh-token")
    }

    @Test("Repository가 실패하면 에러를 그대로 던진다")
    func execute_repositoryFailure_throws() async throws {
        let useCase = withDependencies {
            $0.guestTokenStore = GuestTokenStore(fetchOrCreate: { "token" }, clear: {})
            $0.authRepository = AuthRepository(signUp: { _ in throw SignUpTestError.failed })
        } operation: {
            SignUpUseCase.liveValue
        }

        await #expect(throws: SignUpTestError.self) {
            _ = try await useCase.execute("모모")
        }
    }
}

private enum SignUpTestError: Error {
    case failed
}
