import SwiftUI

import DesignSystem

/// 세션이 없을 때 진입하는 첫 화면. 게스트 토큰으로 로그인을 시도하고, 실패하면 `OnboardingView`가 닉네임 입력으로 이어간다.
struct LoginView: View {
    struct Constants {
        let logoAccessibilityLabel = "모모고"
        let logoWidth: CGFloat = 175
        let logoHeight: CGFloat = 48
        let heading = "점심 한 장으로\n마음을 전해요"
        let mascotSize: CGFloat = 140
        let guestStartButtonTitle = "게스트로 시작하기"
        let sectionSpacing: CGFloat = 72
        let logoHeadingSpacing: CGFloat = 14
        let topPadding: CGFloat = 128
        let horizontalPadding: CGFloat = 16
    }

    private let constants = Constants()

    let viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: constants.sectionSpacing) {
            VStack(spacing: constants.logoHeadingSpacing) {
                Image(asset: DesignSystemAsset.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: constants.logoWidth, height: constants.logoHeight)
                    .accessibilityLabel(constants.logoAccessibilityLabel)

                Text(constants.heading)
                    .momogoTypography(.heading26)
                    .foregroundStyle(DesignSystem.Color.gray50)
                    .multilineTextAlignment(.center)
            }

            Image(asset: DesignSystemAsset.mascot)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: constants.mascotSize, height: constants.mascotSize)

            Button(action: viewModel.guestStartTapped) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text(constants.guestStartButtonTitle)
                }
            }
            .buttonStyle(.momogoButton(kind: .solid, tone: .gray, size: .xl))
            .disabled(viewModel.isLoading)
        }
        .padding(.top, constants.topPadding)
        .padding(.horizontal, constants.horizontalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
    }
}
