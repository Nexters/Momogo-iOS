import SwiftUI

import DesignSystem

struct InviteShareView: View {
    @Bindable private var viewModel: InviteShareViewModel

    private let memberColors: [Color] = [
        DesignSystem.Color.systemRed500,
        DesignSystem.Color.systemGreen500,
        DesignSystem.Color.systemBlue500
    ]

    init(viewModel: InviteShareViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(DesignSystem.Color.primary500)
                    .frame(width: 66, height: 66)
                    .background(DesignSystem.Color.gray900)
                    .overlay {
                        Circle()
                            .strokeBorder(DesignSystem.Color.primary500, style: StrokeStyle(lineWidth: 2, dash: [4]))
                    }
                    .clipShape(.circle)
                    .accessibilityHidden(true)

                Text("가까운 사람을\n초대해보세요")
                    .momogoTypography(.mdMedium)
                    .foregroundStyle(DesignSystem.Color.gray50)
                    .multilineTextAlignment(.center)

                HStack(spacing: -8) {
                    ForEach(memberColors.indices, id: \.self) { index in
                        Circle()
                            .fill(memberColors[index])
                            .frame(width: 28, height: 28)
                            .overlay {
                                Circle().strokeBorder(DesignSystem.Color.gray950, lineWidth: 2)
                            }
                    }
                }
                .accessibilityHidden(true)

                Text(viewModel.inviteCode)
                    .momogoTypography(.smMedium)
                    .tracking(3)
                    .foregroundStyle(DesignSystem.Color.primary500)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(DesignSystem.Color.gray900)
                    .overlay {
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.r10)
                            .strokeBorder(DesignSystem.Color.primary500, style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                    }
                    .clipShape(.rect(cornerRadius: DesignSystem.Radius.r10))
            }

            Spacer()

            Button("메인 화면으로 가기", action: viewModel.goToMainTapped)
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
