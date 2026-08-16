import Foundation

import DomainInterface
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

    private let onFinish: (CreateGroupResponse?) -> Void

    public init(nickname: String, onFinish: @escaping (CreateGroupResponse?) -> Void) {
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
            destination = .groupName(GroupNameViewModel(onFinish: { [weak self] response in self?.onFinish(response) }))
        case .joinWithCode:
            destination = .inviteCode(InviteCodeInputViewModel(onFinish: { [weak self] in self?.onFinish(nil) }))
        }
    }
}
