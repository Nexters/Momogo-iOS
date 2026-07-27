import Foundation

import FeatureGroup
import SwiftUINavigation

@Observable
@MainActor
final class NicknameViewModel {
    var nickname: String = ""
    var destination: Destination?

    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case groupSelect(GroupSelectViewModel)
    }

    func nextTapped() {
        destination = .groupSelect(GroupSelectViewModel(onFinish: onFinish))
    }
}
