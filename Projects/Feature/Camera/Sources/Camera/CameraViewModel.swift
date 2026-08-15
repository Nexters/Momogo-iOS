import AVFoundation
import Foundation

import Dependencies

@Observable
@MainActor
public final class CameraViewModel {
    public enum Stage: Equatable {
        case checking
        case granted
    }

    private(set) var stage: Stage = .checking
    private(set) var zoomLevel: CameraZoomLevel = .x1
    private(set) var isCapturing = false

    let session: AVCaptureSession

    private var zoomCapability: CameraZoomCapability?
    private let sessionManager = CameraSessionManager()
    private let onFinish: (Data?) -> Void

    @ObservationIgnored
    @Dependency(\.cameraPermissionClient) private var cameraPermissionClient

    public init(onFinish: @escaping (Data?) -> Void) {
        self.onFinish = onFinish
        session = sessionManager.session
    }

    func onAppear() async {
        switch cameraPermissionClient.authorizationStatus() {
        case .authorized:
            await startSession()
        case .notDetermined:
            let granted = await cameraPermissionClient.requestAccess()
            if granted {
                await startSession()
            } else {
                cancelTapped()
            }
        default:
            cancelTapped()
        }
    }

    func isZoomLevelAvailable(_ level: CameraZoomLevel) -> Bool {
        guard let zoomCapability else { return false }
        return level.isAvailable(for: zoomCapability)
    }

    func zoomTapped(_ level: CameraZoomLevel) {
        guard let zoomCapability, level.isAvailable(for: zoomCapability) else { return }
        zoomLevel = level
        sessionManager.setZoom(level.rawZoomFactor(for: zoomCapability))
    }

    func shutterTapped() async {
        guard !isCapturing else { return }
        isCapturing = true
        defer { isCapturing = false }

        guard
            let data = await sessionManager.capturePhoto(),
            let cropped = CameraImageCropper.squareCroppedJPEGData(from: data)
        else { return }

        sessionManager.stopSession()
        onFinish(cropped)
    }

    func cancelTapped() {
        sessionManager.stopSession()
        onFinish(nil)
    }

    func stopSessionOnDisappear() {
        sessionManager.stopSession()
    }

    private func startSession() async {
        guard let capability = await sessionManager.configureSession() else {
            cancelTapped()
            return
        }
        zoomCapability = capability
        // 실제 1배 적용은 CameraSessionManager가 세션 큐 안에서 세션 구성과 함께 동기적으로
        // 처리한다(별도로 dispatch하면 타이밍에 따라 적용 전 상태를 보게 될 수 있다).
        sessionManager.startSession()
        stage = .granted
    }
}
