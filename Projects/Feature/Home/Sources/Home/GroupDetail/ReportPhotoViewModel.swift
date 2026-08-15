import Foundation

import Dependencies
import DesignSystem
import DomainInterface

@Observable
@MainActor
final class ReportPhotoViewModel {
    /// Figma 스펙(신고하기_사유선택): 고정 사유 5개 + 직접 작성.
    enum Reason: CaseIterable {
        case duplicate
        case sexual
        case violent
        case commercial
        case defamatory
        case custom

        var title: String {
            switch self {
            case .duplicate: "중복/도배성 게시물"
            case .sexual: "선정적인 게시물"
            case .violent: "폭력적/위험한 게시물"
            case .commercial: "상업적 홍보/광고 게시물"
            case .defamatory: "타인을 비방하는 게시물"
            case .custom: "직접 작성"
            }
        }
    }

    static let customReasonCharacterLimit = 20

    let photoTitle: String
    let dateText: String
    let downloadUrl: String?

    var selectedReason: Reason = .duplicate
    var customReason: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    @ObservationIgnored
    @Dependency(\.reportPhotoUseCase) private var reportPhotoUseCase

    private let groupId: Int
    private let photoId: Int
    /// 신고 완료 시 상위(GroupDetailViewModel)에 알려 화면을 되돌린다.
    private let onFinish: () -> Void

    init(groupId: Int, member: GroupMember, dateText: String, onFinish: @escaping () -> Void) {
        self.groupId = groupId
        photoId = member.photo?.photoId ?? 0
        downloadUrl = member.photo?.downloadUrl
        photoTitle = "\(member.nickname)의 점심"
        self.dateText = dateText
        self.onFinish = onFinish
    }

    var isSubmitEnabled: Bool {
        guard selectedReason == .custom else { return true }
        let trimmed = customReason.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && customReason.count <= Self.customReasonCharacterLimit
    }

    private var reasonText: String {
        selectedReason == .custom ? customReason : selectedReason.title
    }

    func submitTapped() {
        guard !isLoading, isSubmitEnabled else { return }

        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }

            do {
                try await reportPhotoUseCase.execute(
                    ReportPhotoRequest(groupId: groupId, photoId: photoId, reason: reasonText)
                )
                onFinish()
                DSTopToastWindowPresenter.shared.show(DSTopToastContent(message: "신고가 접수되었어요", tone: .success))
            } catch {
                errorMessage = "잠시 후 다시 시도해주세요."
            }
        }
    }
}
