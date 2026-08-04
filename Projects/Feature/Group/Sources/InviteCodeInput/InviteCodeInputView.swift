import SwiftUI

import DesignSystem
import SwiftUINavigation

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

            Button {
                viewModel.joinTapped()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("참여하기")
                }
            }
            .buttonStyle(.momogoButton(kind: .solid, tone: .primary, size: .xl, isFullWidth: true))
            .disabled(viewModel.isLoading || !viewModel.isJoinEnabled)
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $viewModel.destination.joinConfirm) { joinConfirmViewModel in
            JoinConfirmView(viewModel: joinConfirmViewModel)
        }
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
        viewModel.isLengthExceeded ? InviteCodeInputViewModel.codeLengthErrorMessage : viewModel.errorMessage
    }
}
