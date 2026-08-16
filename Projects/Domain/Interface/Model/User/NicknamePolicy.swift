import Foundation

/// 닉네임 입력 검증 규칙. 온보딩 가입과 설정 화면의 닉네임 변경이 동일한 규칙을 공유한다.
public enum NicknamePolicy {
    public static let characterLimit = 6
    public static let lengthErrorMessage = "닉네임은 최대 6자까지 입력할 수 있어요"

    /// 한글(완성형/자모), 영문, 숫자, 특수문자만 허용하고 이모지 등은 걸러낸다.
    /// 자소 결합 문자(이모지 대부분 포함)는 유니코드 스칼라가 2개 이상이므로 함께 제외된다.
    public static func sanitize(_ raw: String) -> String {
        String(raw.filter(isAllowedNicknameCharacter))
    }

    public static func isValid(_ nickname: String) -> Bool {
        (1 ... characterLimit).contains(nickname.count) &&
            !nickname.trimmingCharacters(in: .whitespaces).isEmpty
    }

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
