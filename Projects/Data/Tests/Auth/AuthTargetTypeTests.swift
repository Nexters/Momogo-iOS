import Foundation
import Moya
import Testing
@testable import Data

struct AuthTargetTypeTests {
    @Test("login은 POST /auth/login, 인증 불필요")
    func login_hasCorrectRouting() {
        let target = AuthTargetType.login(LoginRequestDTO(provider: .guest, providerToken: "t"))

        #expect(target.path == "/auth/login")
        #expect(target.method == .post)
        #expect(target.requiresAuthorization == false)
    }

    @Test("reissue는 POST /auth/reissue, 인증 불필요")
    func reissue_hasCorrectRouting() {
        let target = AuthTargetType.reissue(ReissueRequestDTO(refreshToken: "r"))

        #expect(target.path == "/auth/reissue")
        #expect(target.method == .post)
        #expect(target.requiresAuthorization == false)
    }

    @Test("logout은 DELETE /auth/logout, 인증 필요, JSON body 전송")
    func logout_hasCorrectRouting() {
        let target = AuthTargetType.logout(LogoutRequestDTO(refreshToken: "r"))

        #expect(target.path == "/auth/logout")
        #expect(target.method == .delete)
        #expect(target.requiresAuthorization == true)
        guard case .requestJSONEncodable = target.task else {
            Issue.record("requestJSONEncodable을 기대했지만 다른 task가 반환됨")
            return
        }
    }

    @Test("logout은 실제 Moya URLRequest 변환 시에도 DELETE + JSON body를 유지한다")
    func logout_realMoyaConversion_preservesBodyOnDelete() throws {
        let target = AuthTargetType.logout(LogoutRequestDTO(refreshToken: "refresh-token-value"))

        // NetworkConfiguration.baseURL은 Info.plist(API_BASE_URL)를 요구해 테스트 번들에서 크래시하므로,
        // target.baseURL을 거치지 않는 커스텀 endpointClosure로 더미 URL을 직접 구성한다.
        let provider = MoyaProvider<MultiTarget>(endpointClosure: { multiTarget in
            Endpoint(
                url: "https://example.com" + multiTarget.path,
                sampleResponseClosure: { .networkResponse(200, Foundation.Data()) },
                method: multiTarget.method,
                task: multiTarget.task,
                httpHeaderFields: multiTarget.headers
            )
        })

        let urlRequest = try provider.endpoint(MultiTarget(target)).urlRequest()

        #expect(urlRequest.httpMethod == "DELETE")

        let body = try #require(urlRequest.httpBody)
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: String])
        #expect(json["refreshToken"] == "refresh-token-value")
    }
}
