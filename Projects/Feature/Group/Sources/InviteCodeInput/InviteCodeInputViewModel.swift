import Foundation

import Dependencies
import DesignSystem
import DomainInterface
import SwiftUINavigation

@Observable
@MainActor
public final class InviteCodeInputViewModel {
    static let codeLength = 6
    static let codeLengthErrorMessage = "초대코드는 6자만 입력해주세요"

    var code: String = "" {
        didSet {
            let filtered = String(code.filter(Self.isAllowedCodeCharacter))
            if filtered != code {
                code = filtered
            }
        }
    }

    var destination: Destination?
    var isLoading: Bool = false
    var toast: DSTopToastContent?

    @ObservationIgnored
    @Dependency(\.checkGroupByCodeUseCase) private var checkGroupByCodeUseCase
    @ObservationIgnored
    @Dependency(\.joinGroupByCodeUseCase) private var joinGroupByCodeUseCase

    private let onFinish: () -> Void

    public init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case joinConfirm(JoinConfirmViewModel)
    }

    var isLengthExceeded: Bool {
        code.count > Self.codeLength
    }

    var isJoinEnabled: Bool {
        code.count == Self.codeLength
    }

    func joinTapped() {
        guard !isLoading, isJoinEnabled else { return }

        isLoading = true
        toast = nil

        Task {
            defer { isLoading = false }

            do {
                let groupInfo = try await checkGroupByCodeUseCase.execute(code)
                _ = try await joinGroupByCodeUseCase.execute(code)
                let joinConfirmViewModel = JoinConfirmViewModel(groupName: groupInfo.groupName, onFinish: onFinish)
                destination = .joinConfirm(joinConfirmViewModel)
            } catch let error as GroupJoinError {
                toast = DSTopToastContent(error)
            } catch {
                toast = .fallback
            }
        }
    }

    /// 영문, 숫자, 공백만 허용한다. 한글·특수문자·이모지는 제외.
    /// 실제 발급되는 초대코드가 영문+숫자 조합이므로 그에 맞춘 규칙이다.
    private static func isAllowedCodeCharacter(_ character: Character) -> Bool {
        guard character.unicodeScalars.count == 1 else {
            return false
        }
        if character.isASCII, character.isLetter || character.isNumber {
            return true
        }
        return character == " "
    }
}
