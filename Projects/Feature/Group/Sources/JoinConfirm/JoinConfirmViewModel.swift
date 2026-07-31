import Foundation

@Observable
@MainActor
final class JoinConfirmViewModel {
    let groupName: String

    private let onFinish: () -> Void

    init(groupName: String, onFinish: @escaping () -> Void) {
        self.groupName = groupName
        self.onFinish = onFinish
    }

    func startTapped() {
        onFinish()
    }
}
