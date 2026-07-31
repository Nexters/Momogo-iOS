import Foundation

import Dependencies
import DomainInterface
import SwiftUINavigation

@Observable
@MainActor
public final class InviteCodeInputViewModel {
    var code: String = ""
    var destination: Destination?
    var isLoading: Bool = false
    var errorMessage: String?

    @ObservationIgnored
    @Dependency(\.checkGroupByCodeUseCase) private var checkGroupByCodeUseCase
    @ObservationIgnored
    @Dependency(\.joinGroupByCodeUseCase) private var joinGroupByCodeUseCase

    private let onFinish: () -> Void

    public init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case joinConfirm(JoinConfirmViewModel)
    }

    func joinTapped() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }

            do {
                let groupInfo = try await checkGroupByCodeUseCase.execute(code)
                _ = try await joinGroupByCodeUseCase.execute(code)
                let joinConfirmViewModel = JoinConfirmViewModel(groupName: groupInfo.groupName, onFinish: onFinish)
                destination = .joinConfirm(joinConfirmViewModel)
            } catch {
                errorMessage = "잠시 후 다시 시도해주세요."
            }
        }
    }
}
