import SwiftUI
import UIKit

/// `NavigationStack`의 push/pop은 같은 `UIHostingController`에 속한 다른 SwiftUI 콘텐츠까지
/// onAppear/onDisappear 사이클을 타게 만든다(실측 확인됨). SwiftUI 뷰 트리 안에 오버레이를 걸면,
/// 그 오버레이를 어디에 선언하든(NavigationStack 안쪽이든 최상위 RootView든) push/pop이 일어날 때마다
/// `.task(id:)`가 취소·재시작되어 토스트가 3초를 채우지 못하고 사라진다. 메인 윈도우와 완전히 분리된
/// 별도 `UIWindow`에 그려야 이 문제를 피할 수 있다. 앱의 모든 토스트가 이 경로 하나만 쓴다 —
/// ViewModel에 `toast: DSTopToastContent?` 같은 별도 상태를 두지 않고 여기로 직접 호출한다.
@MainActor
public final class DSTopToastWindowPresenter {
    public static let shared = DSTopToastWindowPresenter()

    /// 창은 최초 1회만 만들고 재사용한다. `show()`마다 새로 만들면 내용이 매번 새 뷰로 교체돼
    /// `.transition`/`.animation`이 비교할 "이전 상태"가 없어 하드컷으로 나타난다.
    private var window: UIWindow?
    private let store = ToastStore()
    private var dismissTask: Task<Void, Never>?

    private init() {}

    public func show(_ content: DSTopToastContent) {
        dismissTask?.cancel()
        guard ensureWindow() else { return }
        store.toast = content

        dismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled else { return }
            self?.dismiss()
        }
    }

    /// 다음 토스트를 띄우기 전에 기존 토스트를 즉시 치우고 싶을 때(예: 재시도 직전) 호출한다.
    public func dismiss() {
        dismissTask?.cancel()
        store.toast = nil
    }

    @discardableResult
    private func ensureWindow() -> Bool {
        if window != nil { return true }

        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return false }

        let hostingController = UIHostingController(rootView: ToastHostView(store: store))
        hostingController.view.backgroundColor = .clear

        let window = PassthroughWindow(windowScene: scene)
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        window.rootViewController = hostingController
        window.isHidden = false
        self.window = window
        return true
    }
}

@Observable
private final class ToastStore {
    var toast: DSTopToastContent?
}

/// 기존 `momogoTopToast(_:)`(현재는 제거됨)와 동일한 위치·애니메이션을 재현한다:
/// 좌우 16pt·상단 28pt 여백에, 위에서 슬라이드 + 페이드로 등장·소멸한다.
private struct ToastHostView: View {
    let store: ToastStore

    var body: some View {
        Group {
            if let value = store.toast {
                DSTopToast(value.message, tone: value.tone)
                    .padding(.horizontal, 16)
                    .padding(.top, 28)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        // maxHeight 없이 maxWidth만 채우면 프레임이 콘텐츠 높이만큼만 생겨서, 그 작은 프레임이
        // UIHostingController 전체 화면 안에서 기본값(가운데)으로 배치된다. 화면 전체를 프레임으로
        // 잡아야 `alignment: .top`이 콘텐츠를 화면 상단에 붙인다.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.default, value: store.toast)
    }
}

/// 토스트가 실제로 그려진 영역 밖의 터치는 아래(메인 윈도우) 화면으로 그대로 전달되어야 한다.
private final class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        return hitView == rootViewController?.view ? nil : hitView
    }
}
