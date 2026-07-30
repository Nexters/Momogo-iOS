import Foundation
import Testing
import Moya
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
}
