import Foundation

import Dependencies
import DomainInterface

@Observable
@MainActor
public final class NicknameEditViewModel {
    var nickname: String = "" {
        didSet {
            let sanitized = NicknamePolicy.sanitize(nickname)
            if sanitized != nickname {
                nickname = sanitized
            }
        }
    }

    var isLoading: Bool = false
    var errorMessage: String?

    @ObservationIgnored
    @Dependency(\.updateNicknameUseCase) private var updateNicknameUseCase

    /// 저장 성공 시 상위(SettingsViewModel)의 destination을 정리해 화면을 되돌린다.
    private let onFinish: () -> Void

    public init(onFinish: @escaping () -> Void = {}) {
        self.onFinish = onFinish
    }

    var isLengthExceeded: Bool {
        nickname.count > NicknamePolicy.characterLimit
    }

    var isSaveEnabled: Bool {
        NicknamePolicy.isValid(nickname)
    }

    func saveTapped() {
        guard !isLoading, isSaveEnabled else { return }

        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }

            do {
                try await updateNicknameUseCase.execute(nickname)
                onFinish()
            } catch {
                errorMessage = "잠시 후 다시 시도해주세요."
            }
        }
    }
}
