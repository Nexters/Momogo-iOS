import Foundation
import UIKit

@Observable
@MainActor
final class InviteShareViewModel {
    let inviteCode: String
    var showsCopiedToast: Bool = false

    private let onFinish: () -> Void

    init(inviteCode: String, onFinish: @escaping () -> Void) {
        self.inviteCode = inviteCode
        self.onFinish = onFinish
    }

    func copyCodeTapped() {
        UIPasteboard.general.string = inviteCode
        showsCopiedToast = true
    }

    func goToMainTapped() {
        onFinish()
    }
}
