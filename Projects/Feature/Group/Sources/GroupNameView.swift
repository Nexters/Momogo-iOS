import SwiftUI

import DesignSystem
import SwiftUINavigation

public struct GroupNameView: View {
    @Bindable private var viewModel: GroupNameViewModel

    public init(viewModel: GroupNameViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("그룹 이름을\n지어주라모")
                .momogoTypography(.heading32)
                .foregroundStyle(DesignSystem.Color.gray50)

            Spacer()

            VStack(spacing: 12) {
                DSTextField(
                    "그룹명 입력",
                    text: $viewModel.groupName,
                    state: viewModel.groupName.isEmpty ? .normal : .filled
                )

                Button("그룹 만들기", action: viewModel.createGroupTapped)
                    .buttonStyle(.momogoButton(kind: .solid, tone: .primary, isFullWidth: true))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 72)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .background(DesignSystem.Color.gray950.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $viewModel.destination.inviteShare) { inviteShareViewModel in
            InviteShareView(viewModel: inviteShareViewModel)
        }
    }
}
