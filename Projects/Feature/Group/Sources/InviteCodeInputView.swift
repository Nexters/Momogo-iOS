import SwiftUI

import DesignSystem
import SwiftUINavigation

public struct InviteCodeInputView: View {
    @Bindable private var viewModel: InviteCodeInputViewModel

    public init(viewModel: InviteCodeInputViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("초대코드를\n입력해주라모")
                .momogoTypography(.heading32)
                .foregroundStyle(DesignSystem.Color.gray50)

            Spacer()

            VStack(spacing: 12) {
                DSTextField(
                    "코드 입력",
                    text: $viewModel.code,
                    state: viewModel.code.isEmpty ? .normal : .filled
                )

                Button {
                    viewModel.joinTapped()
                } label: {
                    Text("참여하기")
                }
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
        .navigationDestination(item: $viewModel.destination.joinConfirm) { joinConfirmViewModel in
            JoinConfirmView(viewModel: joinConfirmViewModel)
        }
    }
}
