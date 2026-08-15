import CoreGraphics

/// 가상 멀티카메라 디바이스(트리플/듀얼와이드)의 실제 줌 배율 정보.
///
/// videoZoomFactor의 "1.0"(= minZoomFactor)은 초광각 렌즈의 최소값이지 광각이 아니다. 광각의
/// 실제 "1x" 지점은 virtualDeviceSwitchOverVideoZoomFactors의 첫 전환값(nativeZoomFactor)이며,
/// 이 값은 실기기에서 직접 읽어와야 한다(기종마다 다르고 하드코딩할 수 없다).
struct CameraZoomCapability: Equatable {
    let minZoomFactor: CGFloat
    let nativeZoomFactor: CGFloat
    let maxZoomFactor: CGFloat
}
