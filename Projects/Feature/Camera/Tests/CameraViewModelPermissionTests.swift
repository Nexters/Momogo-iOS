import Foundation

import Dependencies
import Testing
@testable import FeatureCamera

/// 세션/줌 관련 로직은 실기기 카메라 하드웨어에 의존해 실행 환경마다 결과가 달라지므로
/// 여기서는 카메라 접근 없이 결정적으로 검증 가능한 권한 분기만 다룬다.
@Suite("CameraViewModel 권한 분기")
@MainActor
struct CameraViewModelPermissionTests {
    @Test("이미 거부된 상태로 진입하면 onFinish(nil)을 호출한다")
    func deniedStatus_callsOnFinishWithNil() async {
        var callCount = 0
        var lastValue: Data?
        let viewModel = withDependencies {
            $0.cameraPermissionClient = CameraPermissionClient(
                authorizationStatus: { .denied },
                requestAccess: { true }
            )
        } operation: {
            CameraViewModel(onFinish: { data in
                callCount += 1
                lastValue = data
            })
        }

        await viewModel.onAppear()

        #expect(callCount == 1)
        #expect(lastValue == nil)
    }

    @Test("notDetermined 상태에서 요청이 거부되면 onFinish(nil)을 호출한다")
    func notDetermined_requestDenied_callsOnFinishWithNil() async {
        var callCount = 0
        var lastValue: Data?
        let viewModel = withDependencies {
            $0.cameraPermissionClient = CameraPermissionClient(
                authorizationStatus: { .notDetermined },
                requestAccess: { false }
            )
        } operation: {
            CameraViewModel(onFinish: { data in
                callCount += 1
                lastValue = data
            })
        }

        await viewModel.onAppear()

        #expect(callCount == 1)
        #expect(lastValue == nil)
    }
}
