import SwiftUI
import Foundation

import DesignSystem
import SwiftUINavigation

public struct SettingsView: View {
    private enum SettingsLink {
        static let terms = URL(string: "https://momogo-web.vercel.app/terms")
    }

    @Bindable private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            DSTopNavigationBar(
                title: "설정",
                alignment: .center,
                leading: { DSBackButton(action: { dismiss() }) }
            )

            DSMenuListRow(icon: DesignSystemAsset.profile, title: "닉네임 변경", action: viewModel.nicknameTapped)
            DSMenuListRow(icon: DesignSystemAsset.document, title: "약관", action: openTermsTapped)

            Button(action: viewModel.deleteAccountTapped, label: {
                Text("계정 삭제")
                    .underline()
                    .momogoTypography(.smMedium)
                    .foregroundStyle(DesignSystem.Color.gray400)
                    .padding(16)
            })
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .trailing)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $viewModel.destination.nicknameEdit) { nicknameEditViewModel in
            NicknameEditView(viewModel: nicknameEditViewModel)
        }
        .momogoModalOverlay(isPresented: $viewModel.showsWithdrawConfirm) {
            DSModal(
                title: "정말 떠나시겠어요?",
                description: "삭제한 계정은 다시 복구할 수 없어요",
                primaryTitle: "취소",
                primaryAction: viewModel.withdrawCancelled,
                secondaryTitle: "떠나기",
                secondaryAction: viewModel.withdrawConfirmed
            )
        }
    }

    private func openTermsTapped() {
        guard let url = SettingsLink.terms else { return }
        openURL(url)
    }
}
