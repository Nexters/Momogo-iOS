import SwiftUI

/// 기존 `momogoTopToast(_:)`(현재는 제거됨)와 동일한 위치·애니메이션을 재현한다:
/// 좌우 16pt·상단 28pt 여백에, 위에서 슬라이드 + 페이드로 등장·소멸한다.
struct ToastHostView: View {
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
