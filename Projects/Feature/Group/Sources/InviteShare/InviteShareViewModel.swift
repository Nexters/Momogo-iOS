import Foundation
import UIKit

import DesignSystem

@Observable
@MainActor
final class InviteShareViewModel {
    let inviteCode: String

    private let onFinish: () -> Void

    init(inviteCode: String, onFinish: @escaping () -> Void) {
        self.inviteCode = inviteCode
        self.onFinish = onFinish
    }

    func copyCodeTapped() {
        UIPasteboard.general.string = inviteCode
        DSTopToastWindowPresenter.shared.show(.copiedToClipboard)
    }

    func goToMainTapped() {
        onFinish()
    }
}
