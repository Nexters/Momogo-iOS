import Foundation

import DesignSystem

@Observable
@MainActor
final class JoinConfirmViewModel {
    let groupName: String
    var toast: DSTopToastContent?

    private let onFinish: () -> Void

    init(groupName: String, onFinish: @escaping () -> Void) {
        self.groupName = groupName
        self.onFinish = onFinish
    }

    func screenAppeared() {
        toast = .joinCompleted
    }

    func startTapped() {
        onFinish()
    }
}
