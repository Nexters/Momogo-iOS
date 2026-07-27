import Foundation

@Observable
@MainActor
final class JoinConfirmViewModel {
    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    func startTapped() {
        onFinish()
    }
}
