import SwiftUI

import DesignSystem

struct InviteShareView: View {
    private let viewModel: InviteShareViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: InviteShareViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            DSTopNavigationBar(leading: {
                DSBackButton(action: { dismiss() })
            })

            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    Text("점심 메이트에게\n초대코드를 공유해주세요")
                        .momogoMultilineTypography(.heading26)
                        .foregroundStyle(DesignSystem.Color.gray50)
                        .multilineTextAlignment(.center)

                    Text("초대코드 하나로 최대 8명까지 모을 수 있어요")
                        .momogoTypography(.mdMedium)
                        .foregroundStyle(DesignSystem.Color.gray400)
                }

                Button {
                    viewModel.copyCodeTapped()
                } label: {
                    HStack(spacing: 6) {
                        Text(viewModel.inviteCode)
                        Image(asset: DesignSystemAsset.copy)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                .buttonStyle(.momogoButton(kind: .outlined, tone: .gray, size: .large))
            }
            .padding(16)
            .frame(maxWidth: .infinity)

            Image(asset: DesignSystemAsset.illustInviteShare)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 16)
                .padding(.top, 56)
                .accessibilityHidden(true)

            Spacer()

            Button("모모고 시작하기", action: viewModel.goToMainTapped)
                .buttonStyle(.momogoButton(kind: .solid, tone: .primary, size: .xl, isFullWidth: true))
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}
