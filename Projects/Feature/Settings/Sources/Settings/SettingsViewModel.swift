import Foundation

import Dependencies
import DesignSystem
import DomainInterface
import SwiftUINavigation

@Observable
@MainActor
public final class SettingsViewModel {
    var destination: Destination?
    var showsWithdrawConfirm = false
    var isWithdrawing = false
    var toast: DSTopToastContent?

    @ObservationIgnored
    @Dependency(\.deleteAccountUseCase) private var deleteAccountUseCase

    /// 탈퇴가 완료됐을 때 상위(Home)에 알린다.
    private let onSessionEnded: () -> Void

    public init(onSessionEnded: @escaping () -> Void = {}) {
        self.onSessionEnded = onSessionEnded
    }

    @CasePathable
    enum Destination {
        case nicknameEdit(NicknameEditViewModel)
    }

    func nicknameTapped() {
        // 저장 성공 시 destination을 정리해 편집 화면을 되돌린다 (dismiss()가 아닌 navigationDestination 해제로 pop).
        destination = .nicknameEdit(NicknameEditViewModel(onFinish: { [weak self] in
            self?.destination = nil
            self?.toast = DSTopToastContent(message: "닉네임이 저장되었어요", tone: .success)
        }))
    }

    func deleteAccountTapped() {
        showsWithdrawConfirm = true
    }

    func withdrawCancelled() {
        showsWithdrawConfirm = false
    }

    func withdrawConfirmed() {
        guard !isWithdrawing else { return }
        isWithdrawing = true
        // 삭제 여부를 다시 묻지 않도록 모달을 먼저 닫는다. 실패해도 모달을 다시 띄우지 않고 토스트로만 알린다.
        showsWithdrawConfirm = false

        Task {
            defer { isWithdrawing = false }

            do {
                try await deleteAccountUseCase.execute()
                onSessionEnded()
            } catch {
                toast = DSTopToastContent(message: "계정 삭제에 실패했어요. 잠시 후 다시 시도해주세요", tone: .error)
            }
        }
    }
}
