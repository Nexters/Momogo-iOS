import Foundation

import Dependencies
import DomainInterface
import SwiftUINavigation

@Observable
@MainActor
public final class GroupNameViewModel {
    var groupName: String = ""
    var destination: Destination?
    var isLoading: Bool = false
    var errorMessage: String?

    @ObservationIgnored
    @Dependency(\.createGroupUseCase) private var createGroupUseCase

    private let onFinish: () -> Void

    public init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case inviteShare(InviteShareViewModel)
    }

    func createGroupTapped() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }

            do {
                let response = try await createGroupUseCase.execute(groupName)
                let inviteShareViewModel = InviteShareViewModel(inviteCode: response.invitationCode, onFinish: onFinish)
                destination = .inviteShare(inviteShareViewModel)
            } catch {
                errorMessage = "잠시 후 다시 시도해주세요."
            }
        }
    }
}
