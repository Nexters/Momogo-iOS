import Foundation

import SwiftUINavigation

@Observable
@MainActor
public final class GroupSelectViewModel {
    var destination: Destination?

    private let onFinish: () -> Void

    public init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case groupName(GroupNameViewModel)
        case inviteCode(InviteCodeInputViewModel)
    }

    func createGroupTapped() {
        destination = .groupName(GroupNameViewModel(onFinish: onFinish))
    }

    func joinWithCodeTapped() {
        destination = .inviteCode(InviteCodeInputViewModel(onFinish: onFinish))
    }
}
