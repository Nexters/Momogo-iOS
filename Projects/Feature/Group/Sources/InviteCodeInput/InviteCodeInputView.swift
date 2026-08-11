import SwiftUI

import DesignSystem

public struct InviteCodeInputView: View {
    @Bindable private var viewModel: InviteCodeInputViewModel
    @FocusState private var isCodeFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: InviteCodeInputViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            DSTopNavigationBar(leading: {
                DSBackButton(action: { dismiss() })
            })

            VStack(alignment: .leading, spacing: 32) {
                Text("초대코드를 입력해주세요")
                    .momogoTypography(.heading26)
                    .foregroundStyle(DesignSystem.Color.gray50)

                DSTextField(
                    "초대코드 입력",
                    text: $viewModel.code,
                    comment: fieldComment,
                    characterLimit: InviteCodeInputViewModel.codeLength,
                    state: textFieldState,
                    isFocused: $isCodeFieldFocused
                )
            }
            .padding(16)

            Spacer()

            Button("참여하기", action: viewModel.joinTapped)
                .buttonStyle(.momogoButton(kind: .solid, tone: .primary, size: .xl, isFullWidth: true))
                .disabled(viewModel.isLoading || !viewModel.isJoinEnabled)
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .momogoLoadingOverlay(isPresented: viewModel.isLoading)
        // 로딩 오버레이가 화면을 덮어 탭은 막지만, 인터랙티브 스와이프 백 제스처는 별개로 계속 동작하므로 같이 막는다.
        .navigationBarBackButtonHidden(viewModel.isLoading)
        .momogoTopToast($viewModel.toast)
    }

    private var textFieldState: DSTextField.State {
        if viewModel.isLengthExceeded {
            .error
        } else if isCodeFieldFocused {
            .focused
        } else if !viewModel.code.isEmpty {
            .filled
        } else {
            .normal
        }
    }

    private var fieldComment: String? {
        viewModel.isLengthExceeded ? InviteCodeInputViewModel.codeLengthErrorMessage : nil
    }
}
