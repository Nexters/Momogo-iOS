import SwiftUI

import DesignSystem

public struct SplashView: View {
    struct Constants {
        let logoAccessibilityLabel = "모모고"
        let logoWidth: CGFloat = 175
        let logoHeight: CGFloat = 48
    }

    private let constants = Constants()

    @State private var viewModel: SplashViewModel

    public init(viewModel: SplashViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        VStack {
            Image(asset: DesignSystemAsset.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: constants.logoWidth, height: constants.logoHeight)
                .accessibilityLabel(constants.logoAccessibilityLabel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
        .task {
            await viewModel.start()
        }
        // 강제 업데이트 모달은 사용자가 닫을 수 없으므로 되돌릴 바인딩이 필요 없다.
        .momogoModalOverlay(isPresented: .constant(viewModel.forceUpdateStoreURL != nil)) {
            DSModal(
                title: "최신 버전 업데이트",
                description: "최신 버전 업데이트가 있어요.\n스토어로 이동하시겠어요?",
                primaryTitle: "확인",
                primaryAction: { viewModel.updateConfirmTapped() }
            )
        }
    }
}
