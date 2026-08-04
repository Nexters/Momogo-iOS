import Foundation

import Dependencies
import DomainInterface
import SwiftUINavigation

@Observable
@MainActor
public final class OnboardingViewModel {
    var destination: Destination?
    var isLoading: Bool = false

    @ObservationIgnored
    @Dependency(\.loginUseCase) private var loginUseCase

    private let onFinish: () -> Void

    public init(onFinish: @escaping () -> Void = {}) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case nickname(NicknameViewModel)
    }

    func guestStartTapped() {
        guard !isLoading else { return }

        isLoading = true

        Task {
            defer { isLoading = false }

            if await loginUseCase.execute() {
                onFinish()
            } else {
                destination = .nickname(NicknameViewModel(onFinish: onFinish))
            }
        }
    }
}
