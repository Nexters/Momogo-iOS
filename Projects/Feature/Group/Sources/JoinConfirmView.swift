import SwiftUI

import DesignSystem

struct JoinConfirmView: View {
    @Bindable private var viewModel: JoinConfirmViewModel

    init(viewModel: JoinConfirmViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Color.systemGreen500)
                        .frame(width: 70, height: 70)

                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(DesignSystem.Color.gray50)
                }
                .accessibilityHidden(true)

                Text("그룹에 참여했다모")
                    .momogoTypography(.heading32Medium)
                    .foregroundStyle(DesignSystem.Color.gray50)

                Text("우리 가족에 합류했다모")
                    .momogoTypography(.xsMedium)
                    .foregroundStyle(DesignSystem.Color.gray400)
            }

            Spacer()

            Button("시작하기", action: viewModel.startTapped)
                .buttonStyle(.momogoButton(kind: .solid, tone: .primary, size: .medium, isFullWidth: true))
        }
        .padding(.horizontal, 24)
        .padding(.top, 72)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .background(DesignSystem.Color.gray950.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}
