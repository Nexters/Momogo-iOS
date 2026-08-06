import Foundation

import SwiftUINavigation

@Observable
@MainActor
public final class GroupSelectViewModel {
    enum Selection {
        case createGroup
        case joinWithCode
    }

    let nickname: String
    var selection: Selection = .createGroup
    var destination: Destination?

    private let onFinish: () -> Void

    public init(nickname: String, onFinish: @escaping () -> Void) {
        self.nickname = nickname
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case groupName(GroupNameViewModel)
        case inviteCode(InviteCodeInputViewModel)
    }

    func select(_ selection: Selection) {
        self.selection = selection
    }

    func nextTapped() {
        switch selection {
        case .createGroup:
            destination = .groupName(GroupNameViewModel(onFinish: onFinish))
        case .joinWithCode:
            destination = .inviteCode(InviteCodeInputViewModel(onFinish: onFinish))
        }
    }
}
