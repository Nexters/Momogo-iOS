import Foundation

@Observable
@MainActor
final class InviteShareViewModel {
    let inviteCode: String

    private let onFinish: () -> Void

    init(inviteCode: String, onFinish: @escaping () -> Void) {
        self.inviteCode = inviteCode
        self.onFinish = onFinish
    }

    func goToMainTapped() {
        onFinish()
    }
}
