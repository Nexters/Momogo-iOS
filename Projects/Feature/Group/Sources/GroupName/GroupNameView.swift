import SwiftUI

import DesignSystem
import SwiftUINavigation

public struct GroupNameView: View {
    @Bindable private var viewModel: GroupNameViewModel
    @FocusState private var isGroupNameFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: GroupNameViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            DSTopNavigationBar(leading: {
                DSBackButton(action: { dismiss() })
            })

            VStack(alignment: .leading, spacing: 24) {
                Text("그룹명을 정해주세요")
                    .momogoTypography(.heading26)
                    .foregroundStyle(DesignSystem.Color.gray50)

                DSTextField(
                    "그룹명 입력",
                    text: $viewModel.groupName,
                    comment: fieldComment,
                    characterLimit: GroupNameViewModel.groupNameCharacterLimit,
                    state: textFieldState,
                    isFocused: $isGroupNameFieldFocused
                )
            }
            .padding(16)

            Spacer()

            Button {
                viewModel.createGroupTapped()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("그룹 만들기")
                }
            }
            .buttonStyle(.momogoButton(kind: .solid, tone: .primary, size: .xl, isFullWidth: true))
            .disabled(viewModel.isLoading || !viewModel.isCreateEnabled)
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $viewModel.destination.inviteShare) { inviteShareViewModel in
            InviteShareView(viewModel: inviteShareViewModel)
        }
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
        viewModel.isLengthExceeded ? GroupNameViewModel.groupNameLengthErrorMessage : viewModel.errorMessage
    }
}
