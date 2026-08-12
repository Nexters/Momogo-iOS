import SwiftUI

public extension View {
    /// 요청이 진행 중인 동안 화면 전체를 딤 처리해 상호작용(뒤로가기 탭 포함)을 막고 로딩 중임을 알린다.
    /// 사용자가 딤을 탭해 스스로 닫을 수 있는 상태가 아니므로 `Binding`이 아닌 단순 `Bool`을 받는다 —
    /// 요청이 끝나면(성공/실패 모두) 호출부가 `isPresented`를 false로 넘겨야 사라진다.
    ///
    /// - Note: 지금은 `ProgressView`로 임시 표시하지만, 추후 Lottie 애니메이션으로 교체될 예정이다.
    ///   호출부는 `momogoLoadingOverlay(isPresented:)` API만 사용하므로 교체 시 이 파일만 바뀐다.
    func momogoLoadingOverlay(isPresented: Bool) -> some View {
        overlay {
            if isPresented {
                ZStack {
                    DesignSystem.Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView()
                        .tint(DesignSystem.Color.gray50)
                }
                .transition(.opacity)
                .accessibilityAddTraits(.isModal)
            }
        }
        .animation(.default, value: isPresented)
    }
}
