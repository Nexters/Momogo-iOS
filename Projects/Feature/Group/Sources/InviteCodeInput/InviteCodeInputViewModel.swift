import Foundation

import Dependencies
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
    var errorMessage: String?

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
        errorMessage = nil

        Task {
            defer { isLoading = false }

            do {
                let groupInfo = try await checkGroupByCodeUseCase.execute(code)
                _ = try await joinGroupByCodeUseCase.execute(code)
                let joinConfirmViewModel = JoinConfirmViewModel(groupName: groupInfo.groupName, onFinish: onFinish)
                destination = .joinConfirm(joinConfirmViewModel)
            } catch {
                errorMessage = "잠시 후 다시 시도해주세요."
            }
        }
    }

    /// 한글(완성형/자모), 영문, 공백만 허용한다. 숫자·특수문자·이모지는 제외.
    /// 자소 결합 문자(이모지 대부분 포함)는 유니코드 스칼라가 2개 이상이므로 함께 제외된다.
    private static func isAllowedCodeCharacter(_ character: Character) -> Bool {
        guard character.unicodeScalars.count == 1, let scalar = character.unicodeScalars.first else {
            return false
        }
        if character.isASCII, character.isLetter {
            return true
        }
        if character == " " {
            return true
        }
        return hangulSyllables.contains(scalar.value) || hangulJamo.contains(scalar.value)
    }

    private static let hangulSyllables: ClosedRange<UInt32> = 0xAC00 ... 0xD7A3
    private static let hangulJamo: ClosedRange<UInt32> = 0x3131 ... 0x318E
}
