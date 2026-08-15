import Dependencies
import DomainInterface
import FeatureGroup
import SwiftUINavigation
import SwiftUI

@Observable
@MainActor
final class NicknameViewModel {
    var nickname: String = "" {
        didSet {
            let sanitized = NicknamePolicy.sanitize(nickname)
            if sanitized != nickname {
                nickname = sanitized
            }
        }
    }

    var destination: Destination?
    var isLoading: Bool = false
    var errorMessage: String?

    @ObservationIgnored
    @Dependency(\.signUpUseCase) private var signUpUseCase

    private let onFinish: (CreateGroupResponse?) -> Void

    init(onFinish: @escaping (CreateGroupResponse?) -> Void) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case groupSelect(GroupSelectViewModel)
    }

    var isLengthExceeded: Bool {
        nickname.count > NicknamePolicy.characterLimit
    }

    var isNextEnabled: Bool {
        NicknamePolicy.isValid(nickname)
    }

    func nextTapped() {
        guard !isLoading, isNextEnabled else { return }

        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }

            do {
                _ = try await signUpUseCase.execute(nickname)
                destination = .groupSelect(GroupSelectViewModel(nickname: nickname, onFinish: onFinish))
            } catch {
                errorMessage = "잠시 후 다시 시도해주세요."
            }
        }
    }
}
