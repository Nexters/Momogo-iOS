import AVFoundation

/// AVCaptureSession은 반드시 전용 큐에서 다뤄야 해서, @MainActor인 CameraViewModel과 분리된
/// 별도 클래스로 둔다. 모든 하드웨어 설정은 sessionQueue에서만 일어난다.
final class CameraSessionManager: NSObject, @unchecked Sendable {
    let session = AVCaptureSession()

    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.momogo.camera.session")
    private var currentInput: AVCaptureDeviceInput?
    private var captureContinuation: CheckedContinuation<Data?, Never>?

    /// 성공하면 디바이스의 실제 줌 배율 정보를, 카메라를 찾지 못하면 nil을 반환한다.
    func configureSession() async -> CameraZoomCapability? {
        await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                continuation.resume(returning: self?.configureSessionOnQueue())
            }
        }
    }

    func startSession() {
        sessionQueue.async { [session] in
            if !session.isRunning { session.startRunning() }
        }
    }

    func stopSession() {
        sessionQueue.async { [session] in
            if session.isRunning { session.stopRunning() }
        }
    }

    func setZoom(_ factor: CGFloat) {
        sessionQueue.async { [weak self] in
            guard let device = self?.currentInput?.device else { return }
            let clamped = min(max(factor, device.minAvailableVideoZoomFactor), device.maxAvailableVideoZoomFactor)

            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            // 트리플/듀얼와이드 가상 디바이스에서 1.0 미만(초광각 전환 구간)으로 videoZoomFactor를
            // 직접 대입하면 실기기에서 불안정할 수 있어(FigCaptureSourceRemote), ramp로 전환한다.
            device.ramp(toVideoZoomFactor: clamped, withRate: 6)
            device.unlockForConfiguration()
        }
    }

    func capturePhoto() async -> Data? {
        await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard
                    let self,
                    captureContinuation == nil,
                    let connection = photoOutput.connection(with: .video),
                    connection.isActive,
                    connection.isEnabled
                else {
                    continuation.resume(returning: nil)
                    return
                }
                captureContinuation = continuation
                photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            }
        }
    }

    /// zoom factor 정보(특히 1.0 미만 초광각 구간, 광각 전환 지점)는 세션이 실제로 커밋·구동되기
    /// 전까지는 정확하지 않을 수 있어, commitConfiguration + startRunning까지 마친 뒤에 읽는다.
    private func configureSessionOnQueue() -> CameraZoomCapability? {
        session.beginConfiguration()
        session.sessionPreset = .photo

        if let currentInput {
            session.removeInput(currentInput)
        }

        guard let (device, input) = resolveBackCameraInput() else {
            session.commitConfiguration()
            return nil
        }

        session.addInput(input)
        currentInput = input

        if session.outputs.isEmpty, session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        // 앱이 세로 화면 전용이라 캡처 결과가 항상 정사각형 프리뷰와 동일한 방향이 되도록 고정하고,
        // 손떨림 보정을 끈다. 기본 손떨림 보정 모드는 안정화를 위해 프레임 가장자리를 크롭해서,
        // 실제 1배보다 확대돼 보이는 원인 중 하나로 지목된다(Apple 개발자 포럼). photoOutput뿐
        // 아니라 세션에 연결된 모든 커넥션(프리뷰 포함)에 적용해야 화면과 결과물이 일치한다.
        for connection in session.connections {
            if connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .off
            }
        }

        session.commitConfiguration()

        if !session.isRunning {
            session.startRunning()
        }

        let capability = CameraZoomCapability(
            minZoomFactor: device.minAvailableVideoZoomFactor,
            // 초광각→광각 전환 지점(=실제 1배)을 실기기에서 읽는다. 값이 없는 기종(단일 렌즈 등)은
            // 전환이 없으므로 최소값을 그대로 1배 취급한다.
            nativeZoomFactor: device.virtualDeviceSwitchOverVideoZoomFactors.first
                .map { CGFloat(truncating: $0) } ?? device.minAvailableVideoZoomFactor,
            maxZoomFactor: device.maxAvailableVideoZoomFactor
        )

        // 하드웨어 기본값은 raw 1.0(=초광각 최대 화각=실제 0.5배)이라, 화면 표시 기본값인 1배와
        // 어긋난다. setZoom()의 ramp를 별도로 dispatch하지 않고, 같은 세션 큐 블록 안에서
        // 동기적으로 직접 대입한다 — 외부에서 별도로 dispatch할 경우 타이밍에 따라 적용 전 상태를
        // 보게 될 수 있기 때문이다.
        applyZoomFactor(capability.nativeZoomFactor, on: device)

        #if DEBUG
            print(
                "[Camera] device=\(device.localizedName) type=\(device.deviceType.rawValue)"
                    + " min=\(capability.minZoomFactor) native=\(capability.nativeZoomFactor)"
                    + " max=\(capability.maxZoomFactor)"
            )
        #endif

        return capability
    }

    private func applyZoomFactor(_ factor: CGFloat, on device: AVCaptureDevice) {
        let clamped = min(max(factor, device.minAvailableVideoZoomFactor), device.maxAvailableVideoZoomFactor)
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = clamped
            device.unlockForConfiguration()
        } catch {}
    }

    /// 정확히 어느 단계에서 실패하는지 실기기 로그로 확인하기 위해, try?로 에러를 삼키지 않고
    /// 단계별로 나눠 로그를 남긴다.
    private func resolveBackCameraInput() -> (device: AVCaptureDevice, input: AVCaptureDeviceInput)? {
        let device = Self.discoverBackCameraDevice()
        #if DEBUG
            print("[Camera] checkpoint: device discovery -> \(device?.localizedName ?? "nil")")
        #endif

        guard let device else { return nil }

        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            #if DEBUG
                print("[Camera] checkpoint: AVCaptureDeviceInput 생성 실패 error=\(error)")
            #endif
            return nil
        }

        guard session.canAddInput(input) else {
            #if DEBUG
                print(
                    "[Camera] checkpoint: canAddInput == false"
                        + " existingInputs=\(session.inputs.map(\.description))"
                )
            #endif
            return nil
        }

        return (device, input)
    }

    private static func discoverBackCameraDevice() -> AVCaptureDevice? {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInWideAngleCamera
        ]
        for deviceType in deviceTypes {
            if let device = AVCaptureDevice.default(deviceType, for: .video, position: .back) {
                return device
            }
        }
        return nil
    }
}

extension CameraSessionManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        sessionQueue.async { [weak self] in
            let data = error == nil ? photo.fileDataRepresentation() : nil
            self?.captureContinuation?.resume(returning: data)
            self?.captureContinuation = nil
        }
    }
}
