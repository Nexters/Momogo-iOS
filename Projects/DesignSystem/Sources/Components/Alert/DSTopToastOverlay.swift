import SwiftUI

/// 화면 상단에 토스트를 얹는 overlay 전용 뷰. `.animation(value:)`를 이 뷰 자신에게만
/// 적용해, 토스트 등장·소멸 애니메이션이 호출부 화면 전체로 새어나가지 않게 한다.
private struct DSTopToastOverlay: View {
    @Binding var toast: DSTopToastContent?

    var body: some View {
        Group {
            if let value = toast {
                DSTopToast(value.message, tone: value.tone)
                    .padding(.horizontal, 16)
                    .padding(.top, 28)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task(id: value.id) {
                        try? await Task.sleep(for: .seconds(3))
                        toast = nil
                    }
            }
        }
        .animation(.default, value: toast)
    }
}

public extension View {
    /// Figma 스펙: 화면 상단에 표시되고 3초 후 자동으로 사라진다.
    func momogoTopToast(_ toast: Binding<DSTopToastContent?>) -> some View {
        overlay(alignment: .top) {
            DSTopToastOverlay(toast: toast)
        }
    }
}
