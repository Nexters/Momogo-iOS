import Foundation

import Dependencies
import DomainInterface
import SwiftUINavigation

@Observable
@MainActor
public final class GroupNameViewModel {
    var groupName: String = ""
    var destination: Destination?

    @ObservationIgnored
    @Dependency(\.groupClient) private var groupClient

    private let onFinish: () -> Void

    public init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case inviteShare(InviteShareViewModel)
    }

    func createGroupTapped() {
        Task {
            guard let group = try? await groupClient.createGroup(groupName) else { return }
            destination = .inviteShare(InviteShareViewModel(inviteCode: group.inviteCode, onFinish: onFinish))
        }
    }
}
