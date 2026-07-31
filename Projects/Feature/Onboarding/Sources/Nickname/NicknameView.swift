import SwiftUI

import DesignSystem
import SwiftUINavigation

struct NicknameView: View {
    @Bindable private var viewModel: NicknameViewModel

    init(viewModel: NicknameViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("모라고\n불러줄까?")
                .momogoTypography(.heading32)
                .foregroundStyle(DesignSystem.Color.gray50)

            Spacer()

            VStack(spacing: 12) {
                DSTextField(
                    "닉네임 입력",
                    text: $viewModel.nickname,
                    state: viewModel.nickname.isEmpty ? .normal : .filled
                )

                Button("다음", action: viewModel.nextTapped)
                    .buttonStyle(.momogoButton(kind: .solid, tone: .primary, size: .medium, isFullWidth: true))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 72)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .background(DesignSystem.Color.gray950.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $viewModel.destination.groupSelect) { groupSelectViewModel in
            GroupSelectView(viewModel: groupSelectViewModel)
        }
    }
}
