import Foundation

import Dependencies
import DomainInterface
import SwiftUINavigation

@Observable
@MainActor
public final class GroupNameViewModel {
    static let groupNameCharacterLimit = 16
    static let groupNameLengthErrorMessage = "그룹명은 최대 16자까지 입력할 수 있어요"

    var groupName: String = "" {
        didSet {
            let filtered = String(groupName.filter(Self.isAllowedGroupNameCharacter))
            if filtered != groupName {
                groupName = filtered
            }
        }
    }

    var destination: Destination?
    var isLoading: Bool = false
    var errorMessage: String?

    @ObservationIgnored
    @Dependency(\.createGroupUseCase) private var createGroupUseCase

    /// 그룹 생성 완료 후 상위(Home)가 그룹 상세로 바로 이동할 수 있도록 생성 결과를 함께 전달한다.
    private let onFinish: (CreateGroupResponse) -> Void

    public init(onFinish: @escaping (CreateGroupResponse) -> Void) {
        self.onFinish = onFinish
    }

    @CasePathable
    enum Destination {
        case inviteShare(InviteShareViewModel)
    }

    var isLengthExceeded: Bool {
        groupName.count > Self.groupNameCharacterLimit
    }

    var isCreateEnabled: Bool {
        (1 ... Self.groupNameCharacterLimit).contains(groupName.count)
    }

    func createGroupTapped() {
        guard !isLoading, isCreateEnabled else { return }

        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }

            do {
                let response = try await createGroupUseCase.execute(groupName)
                let inviteShareViewModel = InviteShareViewModel(response: response, onFinish: onFinish)
                destination = .inviteShare(inviteShareViewModel)
            } catch {
                errorMessage = "잠시 후 다시 시도해주세요."
            }
        }
    }

    /// 한글(완성형/자모), 영문, 숫자, 특수문자만 허용하고 이모지 등은 걸러낸다.
    /// 자소 결합 문자(이모지 대부분 포함)는 유니코드 스칼라가 2개 이상이므로 함께 제외된다.
    private static func isAllowedGroupNameCharacter(_ character: Character) -> Bool {
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
