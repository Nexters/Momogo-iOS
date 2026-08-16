import Foundation
import Moya
import Testing
@testable import Data

struct UserTargetTypeTests {
    @Test("register는 POST /user/register, 인증 불필요")
    func register_hasCorrectRouting() {
        let target = UserTargetType.register(RegisterRequestDTO(provider: .guest, providerToken: "t", nickname: "모모"))

        #expect(target.path == "/user/register")
        #expect(target.method == .post)
        #expect(target.requiresAuthorization == false)
    }

    @Test("update는 PATCH /user, 인증 필요")
    func update_hasCorrectRouting() {
        let target = UserTargetType.update(UpdateUserRequestDTO(nickname: "모모"))

        #expect(target.path == "/user")
        #expect(target.method == .patch)
        #expect(target.requiresAuthorization == true)
    }

    @Test("delete는 DELETE /user, requestPlain, 인증 필요")
    func delete_hasCorrectRouting() {
        let target = UserTargetType.delete

        #expect(target.path == "/user")
        #expect(target.method == .delete)
        #expect(target.requiresAuthorization == true)
        guard case .requestPlain = target.task else {
            Issue.record("requestPlain을 기대했지만 다른 task가 반환됨")
            return
        }
    }
}
