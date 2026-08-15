import AVFoundation
import Dependencies

extension CameraPermissionClient: DependencyKey {
    public static let liveValue = CameraPermissionClient(
        authorizationStatus: { AVCaptureDevice.authorizationStatus(for: .video) },
        requestAccess: {
            await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
    )

    public static let testValue = CameraPermissionClient(
        authorizationStatus: unimplemented("\(Self.self).authorizationStatus", placeholder: .notDetermined),
        requestAccess: unimplemented("\(Self.self).requestAccess", placeholder: false)
    )

    /// SwiftUI 프리뷰/Example 앱에서 실제 시스템 권한 다이얼로그를 띄우지 않도록 승인 상태로 고정한다.
    public static let previewValue = CameraPermissionClient(
        authorizationStatus: { .authorized },
        requestAccess: { true }
    )
}
