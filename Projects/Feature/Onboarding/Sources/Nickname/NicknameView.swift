import SwiftUI

import DesignSystem
import FeatureGroup
import SwiftUINavigation

struct NicknameView: View {
    @Bindable private var viewModel: NicknameViewModel
    @FocusState private var isNicknameFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(viewModel: NicknameViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            DSTopNavigationBar(leading: {
                DSBackButton(action: { dismiss() })
            })

            VStack(alignment: .leading, spacing: 24) {
                Text("어떤 닉네임으로\n불러드릴까요?")
                    .momogoMultilineTypography(.heading26)
                    .foregroundStyle(DesignSystem.Color.gray50)

                DSTextField(
                    "닉네임 입력",
                    text: $viewModel.nickname,
                    comment: fieldComment,
                    characterLimit: NicknameViewModel.nicknameCharacterLimit,
                    state: textFieldState,
                    isFocused: $isNicknameFieldFocused
                )
            }
            .padding(16)

            Spacer()

            Button {
                viewModel.nextTapped()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("다음으로")
                }
            }
            .buttonStyle(.momogoButton(kind: .solid, tone: .primary, size: .xl, isFullWidth: true))
            .disabled(viewModel.isLoading || !viewModel.isNextEnabled)
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $viewModel.destination.groupSelect) { groupSelectViewModel in
            GroupSelectView(viewModel: groupSelectViewModel)
        }
    }

    private var textFieldState: DSTextField.State {
        if viewModel.isLengthExceeded {
            .error
        } else if isNicknameFieldFocused {
            .focused
        } else if !viewModel.nickname.isEmpty {
            .filled
        } else {
            .normal
        }
    }

    private var fieldComment: String? {
        viewModel.isLengthExceeded ? NicknameViewModel.nicknameLengthErrorMessage : viewModel.errorMessage
    }
}
