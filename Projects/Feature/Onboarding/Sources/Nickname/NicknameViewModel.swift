import Foundation

import Dependencies
import DomainInterface
import FeatureGroup
import SwiftUINavigation

@Observable
@MainActor
final class NicknameViewModel {
    static let nicknameCharacterLimit = 6
    static let nicknameLengthErrorMessage = "닉네임은 최대 6자까지 입력할 수 있어요"

    var nickname: String = "" {
        didSet {
            let filtered = String(nickname.filter(Self.isAllowedNicknameCharacter))
            if filtered != nickname {
                nickname = filtered
            }
        }
    }

    var destination: Destination?
    var isLoading: Bool = false
    var errorMessage: String?

    @ObservationIgnored
    @Dependency(\.signUpUseCase) private var signUpUseCase

    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case groupSelect(GroupSelectViewModel)
    }

    var isLengthExceeded: Bool {
        nickname.count > Self.nicknameCharacterLimit
    }

    var isNextEnabled: Bool {
        (1 ... Self.nicknameCharacterLimit).contains(nickname.count) &&
            !nickname.trimmingCharacters(in: .whitespaces).isEmpty
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

    /// 한글(완성형/자모), 영문, 숫자, 특수문자만 허용하고 이모지 등은 걸러낸다.
    /// 자소 결합 문자(이모지 대부분 포함)는 유니코드 스칼라가 2개 이상이므로 함께 제외된다.
    private static func isAllowedNicknameCharacter(_ character: Character) -> Bool {
        guard character.unicodeScalars.count == 1, let scalar = character.unicodeScalars.first else {
            return false
        }
        if character.isASCII, character.isLetter || character.isNumber {
            return true
        }
        if allowedSpecialCharacters.contains(scalar) {
            return true
        }
        return hangulSyllables.contains(scalar.value) || hangulJamo.contains(scalar.value)
    }

    private static let hangulSyllables: ClosedRange<UInt32> = 0xAC00 ... 0xD7A3
    private static let hangulJamo: ClosedRange<UInt32> = 0x3131 ... 0x318E
    private static let allowedSpecialCharacters = CharacterSet(charactersIn: "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~ ")
}
