import Foundation
import UIKit

import DesignSystem
import DomainInterface

@Observable
@MainActor
final class InviteShareViewModel {
    private let response: CreateGroupResponse
    /// 그룹 상세로 바로 이동할 수 있도록, 완료 콜백에 생성된 그룹 정보를 함께 전달한다.
    private let onFinish: (CreateGroupResponse) -> Void

    var inviteCode: String { response.invitationCode }

    init(response: CreateGroupResponse, onFinish: @escaping (CreateGroupResponse) -> Void) {
        self.response = response
        self.onFinish = onFinish
    }

    func copyCodeTapped() {
        UIPasteboard.general.string = inviteCode
        DSTopToastWindowPresenter.shared.show(.copiedToClipboard)
    }

    func goToMainTapped() {
        onFinish(response)
    }
}
