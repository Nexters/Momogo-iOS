import UIKit

/// 토스트가 실제로 그려진 영역 밖의 터치는 아래(메인 윈도우) 화면으로 그대로 전달되어야 한다.
final class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        return hitView == rootViewController?.view ? nil : hitView
    }
}
