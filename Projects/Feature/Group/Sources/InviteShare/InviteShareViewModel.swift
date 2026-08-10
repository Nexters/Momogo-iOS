import Foundation
import UIKit

import DesignSystem

@Observable
@MainActor
final class InviteShareViewModel {
    let inviteCode: String
    var toast: DSTopToastContent?

    private let onFinish: () -> Void

    init(inviteCode: String, onFinish: @escaping () -> Void) {
        self.inviteCode = inviteCode
        self.onFinish = onFinish
    }

    func copyCodeTapped() {
        UIPasteboard.general.string = inviteCode
        toast = .copiedToClipboard
    }

    func goToMainTapped() {
        onFinish()
    }
}
