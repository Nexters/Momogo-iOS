import Foundation

import Dependencies
import DomainInterface
import SwiftUINavigation

@Observable
@MainActor
public final class InviteCodeInputViewModel {
    var code: String = ""
    var destination: Destination?

    @ObservationIgnored
    @Dependency(\.groupClient) private var groupClient

    private let onFinish: () -> Void

    public init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case joinConfirm(JoinConfirmViewModel)
    }

    func joinTapped() {
        Task {
            guard let info = try? await groupClient.fetchGroupInfo(code) else { return }
            guard await (try? groupClient.joinGroup(info.inviteCode)) != nil else { return }
            destination = .joinConfirm(JoinConfirmViewModel(onFinish: onFinish))
        }
    }
}
