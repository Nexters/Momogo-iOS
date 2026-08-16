import AVFoundation
import Dependencies

public struct CameraPermissionClient: Sendable {
    public var authorizationStatus: @Sendable () -> AVAuthorizationStatus
    public var requestAccess: @Sendable () async -> Bool

    public init(
        authorizationStatus: @escaping @Sendable () -> AVAuthorizationStatus,
        requestAccess: @escaping @Sendable () async -> Bool
    ) {
        self.authorizationStatus = authorizationStatus
        self.requestAccess = requestAccess
    }
}

public extension DependencyValues {
    var cameraPermissionClient: CameraPermissionClient {
        get { self[CameraPermissionClient.self] }
        set { self[CameraPermissionClient.self] = newValue }
    }
}
