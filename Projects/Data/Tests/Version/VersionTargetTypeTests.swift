import Foundation
import Moya
import Testing
@testable import Data

struct VersionTargetTypeTests {
    @Test("check는 GET /init/versions, 인증 불필요")
    func check_hasCorrectRouting() {
        let target = VersionTargetType.check

        #expect(target.path == "/init/versions")
        #expect(target.method == .get)
        #expect(target.requiresAuthorization == false)
    }

    // target.baseURL(→ NetworkConfiguration.rootURL)과 target.task(→ NetworkConfiguration.appVersion)는
    // 둘 다 Bundle.main의 Info.plist 키(API_BASE_URL/CFBundleShortVersionString)를 요구해 테스트 번들에서
    // preconditionFailure로 크래시할 수 있다 (AuthTargetTypeTests의 baseURL 회피와 동일한 이유).
    // 그래서 여기서는 건드리지 않는다.
}
