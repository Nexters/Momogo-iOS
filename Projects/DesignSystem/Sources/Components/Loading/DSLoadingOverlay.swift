import SwiftUI

public extension View {
    /// 요청이 진행 중인 동안 화면 전체를 딤 처리해 상호작용(뒤로가기 탭 포함)을 막고 로딩 중임을 알린다.
    /// 사용자가 딤을 탭해 스스로 닫을 수 있는 상태가 아니므로 `Binding`이 아닌 단순 `Bool`을 받는다 —
    /// 요청이 끝나면(성공/실패 모두) 호출부가 `isPresented`를 false로 넘겨야 사라진다.
    func momogoLoadingOverlay(isPresented: Bool) -> some View {
        overlay {
            if isPresented {
                ZStack {
                    DesignSystem.Color.black.opacity(0.4).ignoresSafeArea()
                    DSProgressView()
                }
                .transition(.opacity)
                .accessibilityAddTraits(.isModal)
            }
        }
        .animation(.default, value: isPresented)
    }
}
