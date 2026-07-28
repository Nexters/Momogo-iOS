import SwiftUI

import DesignSystem
import SwiftUINavigation

public struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    public init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    Image(asset: DesignSystemAsset.mascot)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 93, height: 133)

                    Image(asset: DesignSystemAsset.wordmark)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 146, height: 46)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("모모고")

                Spacer()

                VStack(spacing: 12) {
                    Button("게스트로 시작하기", action: viewModel.guestStartTapped)
                        .momogoTypography(.smMedium)
                        .foregroundStyle(DesignSystem.Color.gray50)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 54)
                        .background(DesignSystem.Color.gray900)
                        .clipShape(.rect(cornerRadius: 8))

                    Text("회원가입 없이 바로 사용할 수 있어요")
                        .momogoTypography(.xsMedium)
                        .foregroundStyle(DesignSystem.Color.gray100)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 80)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
            .background(DesignSystem.Color.gray950.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $viewModel.destination.nickname) { nicknameViewModel in
                NicknameView(viewModel: nicknameViewModel)
            }
        }
    }
}
