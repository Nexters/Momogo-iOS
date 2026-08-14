import SwiftUI

import DesignSystem

/// `NicknameEditView`(FeatureSettings)와 동일한 구조를 따르는 그룹명 변경 화면.
struct GroupRenameView: View {
    struct Constants {
        let heading = "그룹명을 정해주세요"
        let placeholder = "그룹명 입력"
        let lengthErrorMessage = "그룹명은 최대 16자까지 입력할 수 있어요"
        let saveButtonTitle = "변경하기"
        let contentSpacing: CGFloat = 24
        let contentPadding: CGFloat = 16
        let saveButtonBottomPadding: CGFloat = 32
    }

    private let constants = Constants()

    @Bindable private var viewModel: GroupRenameViewModel
    @FocusState private var isGroupNameFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(viewModel: GroupRenameViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            DSTopNavigationBar(leading: {
                DSBackButton(action: { dismiss() })
            })

            VStack(alignment: .leading, spacing: constants.contentSpacing) {
                Text(constants.heading)
                    .momogoTypography(.heading26)
                    .foregroundStyle(DesignSystem.Color.gray50)

                DSTextField(
                    constants.placeholder,
                    text: $viewModel.groupName,
                    comment: fieldComment,
                    characterLimit: GroupRenameViewModel.characterLimit,
                    state: textFieldState,
                    isFocused: $isGroupNameFieldFocused
                )
            }
            .padding(constants.contentPadding)

            Spacer()

            Button {
                viewModel.saveTapped()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text(constants.saveButtonTitle)
                }
            }
            .buttonStyle(.momogoButton(kind: .solid, tone: .primary, size: .xl, isFullWidth: true))
            .disabled(viewModel.isLoading || !viewModel.isSaveEnabled)
            .padding(.horizontal, constants.contentPadding)
            .padding(.bottom, constants.saveButtonBottomPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var textFieldState: DSTextField.State {
        if viewModel.isLengthExceeded {
            .error
        } else if isGroupNameFieldFocused {
            .focused
        } else if !viewModel.groupName.isEmpty {
            .filled
        } else {
            .normal
        }
    }

    private var fieldComment: String? {
        viewModel.isLengthExceeded ? constants.lengthErrorMessage : viewModel.errorMessage
    }
}
