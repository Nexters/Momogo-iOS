import SwiftUI

import DesignSystem
import FeatureGroup
import SwiftUINavigation

struct GroupSelectView: View {
    @Bindable private var viewModel: GroupSelectViewModel

    init(viewModel: GroupSelectViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("모모님, 모부터\n시작할까?")
                .momogoTypography(.heading32)
                .foregroundStyle(DesignSystem.Color.gray50)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    viewModel.createGroupTapped()
                } label: {
                    Text("그룹 만들기")
                }
                .buttonStyle(.momogoButton(kind: .solid, tone: .primary, isFullWidth: true))

                Button {
                    viewModel.joinWithCodeTapped()
                } label: {
                    Text("초대코드로 참여하기")
                }
                .buttonStyle(.momogoButton(kind: .outlined, tone: .primary, isFullWidth: true))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 72)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .background(DesignSystem.Color.gray950.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $viewModel.destination.groupName) { groupNameViewModel in
            GroupNameView(viewModel: groupNameViewModel)
        }
        .navigationDestination(item: $viewModel.destination.inviteCode) { inviteCodeViewModel in
            InviteCodeInputView(viewModel: inviteCodeViewModel)
        }
    }
}
