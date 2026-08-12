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
        // 활성 scene을 못 찾은 시점에도, 이전에 붙여둔 window가 아직 유효하다면(예: 일시적으로
        // 백그라운드 상태) 그대로 재사용한다 — 여기서 nil을 반환하면 store.toast가 갱신되지 않아
        // 앱이 다시 foreground로 돌아와도 토스트가 표시되지 않는다.
        guard let scene = Self.currentScene() else { return window != nil }

        // window가 이미 같은 scene에 붙어 있으면 재사용한다. scene이 disconnect되고 새 scene이
        // 생긴 경우(iPad 멀티 윈도우 등)에는 window != nil만으로 재사용 여부를 판단할 수 없으므로,
        // 매 호출마다 현재 scene과 비교해 필요할 때만 새로 만든다.
        if let window, window.windowScene === scene { return true }

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

    /// `.foregroundActive` scene을 우선하되, 시스템 알림·전화 배너 등으로 일시적으로
    /// `.foregroundInactive`가 된 경우에도 창을 만들 수 있도록 차선책으로 허용한다.
    private static func currentScene() -> UIWindowScene? {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return windowScenes.first { $0.activationState == .foregroundActive }
            ?? windowScenes.first { $0.activationState == .foregroundInactive }
    }
}
