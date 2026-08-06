import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import Data

struct AuthRepositoryLiveTests {
    @Test("signUp은 요청을 RegisterRequestDTO로 변환하고, 응답 DTO를 도메인 모델로 매핑한다")
    func signUp_mapsRequestAndResponse() async throws {
        let capturedRequest = Locked<RegisterRequestDTO?>(nil)

        let repository = withDependencies {
            $0.userDataSource.register = { request in
                capturedRequest.set(request)
                return AuthSessionResponseDTO(
                    userId: 1,
                    nickname: "모모",
                    accessToken: "access",
                    refreshToken: "refresh"
                )
            }
        } operation: {
            AuthRepository.liveValue
        }

        let response = try await repository.signUp(
            SignUpRequest(provider: .guest, providerToken: "provider-token", nickname: "모모")
        )

        #expect(capturedRequest.get()?.provider == .guest)
        #expect(capturedRequest.get()?.providerToken == "provider-token")
        #expect(response.userId == 1)
        #expect(response.nickname == "모모")
        #expect(response.accessToken == "access")
        #expect(response.refreshToken == "refresh")
    }
}
