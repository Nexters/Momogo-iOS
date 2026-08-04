import SwiftUI

import DesignSystem

/// 세션이 없을 때 진입하는 첫 화면. 게스트 토큰으로 로그인을 시도하고, 실패하면 `OnboardingView`가 닉네임 입력으로 이어간다.
struct LoginView: View {
    let viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 72) {
            VStack(spacing: 14) {
                Image(asset: DesignSystemAsset.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 175, height: 48)
                    .accessibilityLabel("모모고")

                Text("점심 한 장으로\n마음을 전해요")
                    .momogoTypography(.heading26)
                    .foregroundStyle(DesignSystem.Color.gray50)
                    .multilineTextAlignment(.center)
            }

            Image(asset: DesignSystemAsset.mascot)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140, height: 140)

            Button(action: viewModel.guestStartTapped) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("게스트로 시작하기")
                }
            }
            .buttonStyle(.momogoButton(kind: .solid, tone: .gray, size: .xl))
            .disabled(viewModel.isLoading)
        }
        .padding(.top, 128)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
    }
}
