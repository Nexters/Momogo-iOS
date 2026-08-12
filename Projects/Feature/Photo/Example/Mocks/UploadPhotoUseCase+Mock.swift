import Foundation

import DomainInterface

/// 실제 백엔드 연동 전까지 Example 앱에서 업로드 완료 플로우를 확인하기 위한 Mock.
extension UploadPhotoUseCase {
    static let happyPath = UploadPhotoUseCase { _ in
        try? await Task.sleep(for: .seconds(0.6))
        return UploadPhotoResponse(photoId: 501, objectKey: "dev/users/1/mock.webp")
    }
}
