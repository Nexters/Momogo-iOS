import Foundation

import Dependencies
import DomainInterface

@Observable
@MainActor
final class GroupRenameViewModel {
    static let characterLimit = 16

    var groupName: String
    var isLoading: Bool = false
    var errorMessage: String?

    @ObservationIgnored
    @Dependency(\.updateGroupNameUseCase) private var updateGroupNameUseCase

    private let groupId: Int
    /// 저장 성공 시 상위(GroupDetailViewModel)에 변경된 그룹명을 전달하고 화면을 되돌린다.
    private let onFinish: (String) -> Void

    init(groupId: Int, currentName: String, onFinish: @escaping (String) -> Void) {
        self.groupId = groupId
        groupName = currentName
        self.onFinish = onFinish
    }

    var isLengthExceeded: Bool {
        groupName.count > Self.characterLimit
    }

    var isSaveEnabled: Bool {
        (1 ... Self.characterLimit).contains(groupName.count)
    }

    func saveTapped() {
        guard !isLoading, isSaveEnabled else { return }

        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }

            do {
                let response = try await updateGroupNameUseCase.execute(groupId, groupName)
                onFinish(response.groupName)
            } catch {
                errorMessage = "잠시 후 다시 시도해주세요."
            }
        }
    }
}
