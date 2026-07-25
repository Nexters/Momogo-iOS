import Foundation

import SwiftUINavigation

@Observable
@MainActor
public final class OnboardingViewModel {
    var destination: Destination?

    public init() {}

    @CasePathable
    enum Destination {
        case nickname(NicknameViewModel)
    }

    func guestStartTapped() {
        destination = .nickname(NicknameViewModel(onFinish: {}))
    }
}
