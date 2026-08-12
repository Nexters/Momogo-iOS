import Foundation
import Moya
import Testing
@testable import Data

struct PhotoTargetTypeTests {
    @Test("issueUploadURL은 POST /photos/upload-urls, 인증 필요")
    func issueUploadURL_hasCorrectRouting() {
        let target = PhotoTargetType.issueUploadURL(PhotoUploadUrlRequestDTO(contentType: "image/webp"))

        #expect(target.path == "/photos/upload-urls")
        #expect(target.method == .post)
        #expect(target.requiresAuthorization == true)
    }

    @Test("confirm은 POST /photos, 인증 필요")
    func confirm_hasCorrectRouting() {
        let target = PhotoTargetType.confirm(PhotoCreateRequestDTO(objectKey: "users/1/9f8b.webp", groupIds: [10, 20]))

        #expect(target.path == "/photos")
        #expect(target.method == .post)
        #expect(target.requiresAuthorization == true)
    }
}
