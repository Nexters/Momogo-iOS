import Foundation

import SwiftUINavigation

@Observable
@MainActor
public final class OnboardingViewModel {
    var destination: Destination?

    private let onFinish: () -> Void

    public init(onFinish: @escaping () -> Void = {}) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case nickname(NicknameViewModel)
    }

    func guestStartTapped() {
        destination = .nickname(NicknameViewModel(onFinish: onFinish))
    }
}
