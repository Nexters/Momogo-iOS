import Foundation

import Dependencies
import DomainInterface
import FeatureGroup
import SwiftUINavigation

@Observable
@MainActor
final class NicknameViewModel {
    var nickname: String = ""
    var destination: Destination?
    var isLoading: Bool = false
    var errorMessage: String?

    @ObservationIgnored
    @Dependency(\.signUpUseCase) private var signUpUseCase

    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case groupSelect(GroupSelectViewModel)
    }

    func nextTapped() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }

            do {
                _ = try await signUpUseCase.execute(nickname)
                destination = .groupSelect(GroupSelectViewModel(onFinish: onFinish))
            } catch {
                errorMessage = "잠시 후 다시 시도해주세요."
            }
        }
    }
}
