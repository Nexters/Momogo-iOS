import AVFoundation
import Foundation

import Dependencies
import DesignSystem

@Observable
@MainActor
public final class CameraViewModel {
    public enum Stage: Equatable {
        case checking
        case granted
        case permissionDenied
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
            // 시스템 권한 다이얼로그를 처음 보고 거부한 직후에는 사용자가 이미 방금 그 의사를
            // 표현한 상태라 우리 알럿을 다시 띄우지 않고 조용히 닫는다. 알럿은 이미 거부된 상태로
            // "재진입"했을 때만(default 분기) 보여준다.
            let granted = await cameraPermissionClient.requestAccess()
            if granted {
                await startSession()
            } else {
                cancelTapped()
            }
        default:
            stage = .permissionDenied
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

        guard let data = await sessionManager.capturePhoto() else {
            showCaptureFailure()
            return
        }

        // 디코드 + 크롭 + JPEG 재인코딩은 12MP 기준 수백 ms짜리 CPU 작업이라, @MainActor인 이
        // ViewModel에서 그대로 실행하면 셔터를 누르는 순간 화면이 멈춘다. 순수 함수라 밖으로 뺀다.
        let cropped = await Task.detached(priority: .userInitiated) {
            CameraImageCropper.squareCroppedJPEGData(from: data)
        }.value

        guard let cropped else {
            showCaptureFailure()
            return
        }

        sessionManager.stopSession()
        onFinish(cropped)
    }

    /// 촬영이 실패하면 화면을 그대로 두고 다시 찍을 수 있게 하되, 셔터를 눌렀는데 아무 일도
    /// 일어나지 않은 것처럼 보이지 않도록 알린다.
    private func showCaptureFailure() {
        DSTopToastWindowPresenter.shared.show(
            DSTopToastContent(message: "사진을 찍지 못했어요. 다시 시도해주세요", tone: .error)
        )
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
