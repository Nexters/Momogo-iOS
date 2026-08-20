import Dependencies
import DesignSystem
import DomainInterface
import FeatureGroup
import SwiftUI
import SwiftUINavigation

@Observable
@MainActor
public final class NicknameViewModel {
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

    @ObservationIgnored
    @Dependency(\.signUpUseCase) private var signUpUseCase

    private let onFinish: (CreateGroupResponse?) -> Void

    public init(onFinish: @escaping (CreateGroupResponse?) -> Void) {
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
        DSTopToastWindowPresenter.shared.dismiss()

        Task {
            defer { isLoading = false }

            do {
                _ = try await signUpUseCase.execute(nickname)
                destination = .groupSelect(GroupSelectViewModel(nickname: nickname, onFinish: onFinish))
            } catch {
                DSTopToastWindowPresenter.shared.show(
                    DSTopToastContent(message: "잠시 후 다시 시도해주세요.", tone: .error)
                )
            }
        }
    }
}
