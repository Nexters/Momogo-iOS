import SwiftUI

import DesignSystem

/// 세션이 없을 때 진입하는 첫 화면. 게스트 토큰으로 로그인을 시도하고, 실패하면 `OnboardingView`가 닉네임 입력으로 이어간다.
struct LoginView: View {
    struct Constants {
        let logoAccessibilityLabel = "모모고"
        // logo.svg 원본 비율(5.28)에 맞춘 내부 프레임을 174×48 외부 프레임 중앙에 배치한다.
        let logoInnerWidth: CGFloat = 166
        let logoInnerHeight: CGFloat = 31
        let logoOuterWidth: CGFloat = 174
        let logoOuterHeight: CGFloat = 48
        let heading = "점심 한 장으로 마음을 전해요"
        let illustSize: CGFloat = 193
        let guestStartButtonTitle = "게스트로 시작하기"
        let logoHeadingSpacing: CGFloat = 8
        let headingIllustSpacing: CGFloat = 80
        let illustButtonSpacing: CGFloat = 40
        let topPadding: CGFloat = 126
        let horizontalPadding: CGFloat = 16
    }

    private let constants = Constants()

    let viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: constants.logoHeadingSpacing) {
                Image(asset: DesignSystemAsset.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: constants.logoInnerWidth, height: constants.logoInnerHeight)
                    .frame(width: constants.logoOuterWidth, height: constants.logoOuterHeight)
                    .accessibilityLabel(constants.logoAccessibilityLabel)

                Text(constants.heading)
                    .momogoTypography(.xlMedium)
                    .foregroundStyle(DesignSystem.Color.gray50)
                    .multilineTextAlignment(.center)
            }

            Image(asset: DesignSystemAsset.illustLogin)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: constants.illustSize, height: constants.illustSize)
                .padding(.top, constants.headingIllustSpacing)

            Button(action: viewModel.guestStartTapped) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text(constants.guestStartButtonTitle)
                }
            }
            .buttonStyle(.momogoButton(kind: .solid, tone: .gray, size: .xl))
            .disabled(viewModel.isLoading)
            .padding(.top, constants.illustButtonSpacing)
        }
        .padding(.top, constants.topPadding)
        .padding(.horizontal, constants.horizontalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
    }
}
