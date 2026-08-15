import Foundation

import DomainInterface

/// 실제 백엔드 연동 전까지 Example 앱에서 플로우를 확인하기 위한 Mock. 프로덕션 liveValue는 unimplemented로 유지한다.
extension GetMyPhotosUseCase {
    static let happyPath = GetMyPhotosUseCase { _ in
        try? await Task.sleep(for: .seconds(0.4))

        return GetMyPhotosResponse(
            date: "2026-08-15",
            photos: [
                MyPhoto(
                    photoId: 501,
                    downloadUrl: "https://picsum.photos/seed/momogo-501/300",
                    contentType: "image/webp",
                    createdAt: "2026-08-15T14:30:00.123456",
                    expiresAt: "2026-08-15T14:45:00.123456"
                )
            ]
        )
    }

    static let emptyPath = GetMyPhotosUseCase { _ in
        try? await Task.sleep(for: .seconds(0.4))
        return GetMyPhotosResponse(date: "2026-08-15", photos: [])
    }
}
