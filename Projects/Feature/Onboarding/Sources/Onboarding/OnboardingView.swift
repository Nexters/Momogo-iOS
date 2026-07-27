import SwiftUI

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

                VStack(spacing: 12) {
                    Button {
                        viewModel.guestStartTapped()
                    } label: {
                        Text("게스트로 시작하기")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 54)
                            .background(OnboardingColor.guestButtonBackground)
                            .clipShape(.rect(cornerRadius: 8))
                    }

                    Text("회원가입 없이 바로 사용할 수 있어요")
                        .font(.caption)
                        .foregroundStyle(OnboardingColor.secondaryText)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 80)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
            .background(OnboardingColor.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $viewModel.destination.nickname) { nicknameViewModel in
                NicknameView(viewModel: nicknameViewModel)
            }
        }
    }
}
