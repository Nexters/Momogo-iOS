import SwiftUI

import DesignSystem
import SwiftUINavigation

public struct GroupSelectView: View {
    @Bindable private var viewModel: GroupSelectViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: GroupSelectViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            DSTopNavigationBar(leading: {
                DSBackButton(action: { dismiss() })
            })

            VStack(alignment: .leading, spacing: 24) {
                Text("\(viewModel.nickname)님,\n어느 것부터 시작할까요?")
                    .momogoMultilineTypography(.heading26)
                    .foregroundStyle(DesignSystem.Color.gray50)

                VStack(spacing: 16) {
                    SelectionCard(
                        icon: createGroupIcon,
                        title: "그룹 만들기",
                        subtitle: "프라이빗 공간을 새로 만들기",
                        isSelected: viewModel.selection == .createGroup,
                        action: { viewModel.select(.createGroup) }
                    )

                    SelectionCard(
                        icon: joinWithCodeIcon,
                        title: "그룹 참여하기",
                        subtitle: "초대코드로 참여하기",
                        isSelected: viewModel.selection == .joinWithCode,
                        action: { viewModel.select(.joinWithCode) }
                    )
                }
            }
            .padding(16)

            Spacer()

            Button("다음으로", action: viewModel.nextTapped)
                .buttonStyle(.momogoButton(kind: .solid, tone: .primary, size: .xl, isFullWidth: true))
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $viewModel.destination.groupName) { groupNameViewModel in
            GroupNameView(viewModel: groupNameViewModel)
        }
        .navigationDestination(item: $viewModel.destination.inviteCode) { inviteCodeViewModel in
            InviteCodeInputView(viewModel: inviteCodeViewModel)
        }
    }

    private var createGroupIcon: DesignSystemImages {
        viewModel.selection == .createGroup ? DesignSystemAsset.iconPeopleActive : DesignSystemAsset.iconPeopleInactive
    }

    private var joinWithCodeIcon: DesignSystemImages {
        viewModel.selection == .joinWithCode ? DesignSystemAsset.iconLinkActive : DesignSystemAsset.iconLinkInactive
    }
}
