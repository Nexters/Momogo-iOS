import Foundation

import SwiftUINavigation

@Observable
@MainActor
public final class GroupNameViewModel {
    var groupName: String = ""
    var destination: Destination?

    private let onFinish: () -> Void

    public init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case inviteShare(InviteShareViewModel)
    }

    func createGroupTapped() {
        let inviteCode = String(UUID().uuidString.prefix(6)).uppercased()
        destination = .inviteShare(InviteShareViewModel(inviteCode: inviteCode, onFinish: onFinish))
    }
}
