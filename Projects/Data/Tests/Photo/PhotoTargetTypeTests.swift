import Foundation
import Moya
import Testing
@testable import Data

struct PhotoTargetTypeTests {
    @Test("createUploadSession은 POST /photos/upload-sessions, 인증 필요")
    func createUploadSession_hasCorrectRouting() {
        let target = PhotoTargetType.createUploadSession(CreateUploadSessionRequestDTO(contentType: "image/webp"))

        #expect(target.path == "/photos/upload-sessions")
        #expect(target.method == .post)
        #expect(target.requiresAuthorization == true)
    }

    @Test("confirm은 POST /photos, 인증 필요")
    func confirm_hasCorrectRouting() {
        let target = PhotoTargetType.confirm(ConfirmUploadRequestDTO(uploadSessionId: 3001))

        #expect(target.path == "/photos")
        #expect(target.method == .post)
        #expect(target.requiresAuthorization == true)
    }
}
