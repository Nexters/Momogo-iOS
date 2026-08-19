import Foundation

import Dependencies
import DesignSystem
import DomainInterface

/// 반응 화면. 리액션 조회/등록 API가 아직 없어 로그는 목 데이터로 채우고, 이모지 탭은 로컬 상태만
/// 갱신한다(모드별 코멘트 프리셋에서 랜덤 추첨). 사진 삭제는 이미 있는 UseCase를 그대로 쓴다.
@Observable
@MainActor
public final class ReactionViewModel {
    private enum Constants {
        static let deleteSuccessMessage = "사진을 삭제했어요"
        static let errorMessage = "잠시 후 다시 시도해주세요."

        /// 목 로그 한 벌의 개수. 스크롤·Gradient·스크롤바가 보일 만큼은 채운다.
        static let mockReactionCount = 8
        /// 이 배수의 userId는 로그를 비워 둬, Example/그룹상세에서 엠티뷰 상태도 함께 확인할 수 있게 한다.
        static let mockEmptyUserIdMultiple = 3
        /// 두 줄 래핑 레이아웃(Figma TagL Variant2)을 항상 확인할 수 있도록, 이 인덱스의 줄에는
        /// 후보 중 가장 긴 코멘트를 넣는다.
        static let mockLongestCommentIndex = 0
    }

    public let groupId: Int
    public let groupName: String
    public let dateText: String

    /// 신고 화면은 FeatureHome이 소유해, 이 모듈은 대상만 들고 실제 화면은 호출부가
    /// `ReactionView(viewModel:reportDestination:)`으로 주입한다(단방향 의존 유지).
    public var reportTarget: ReactionReportTarget?

    private(set) var items: [ReactionPhotoItem]
    /// 가로 페이저에서 현재 보이는 카드. `scrollPosition(id:)`가 스와이프에 맞춰 갱신한다.
    var selectedItemId: Int?

    private(set) var mode: ReactionMode = .youngCrack
    var isModeSheetPresented: Bool = false
    /// 바텀시트에서 고른 값. '적용'을 눌러야 `mode`에 반영된다.
    private(set) var pendingMode: ReactionMode = .youngCrack

    /// 삭제 확인 모달 대상. nil이 아니면 모달이 노출된다(GroupDetailViewModel과 동일 패턴 —
    /// Bool 하나로는 어떤 사진을 지울지 함께 들고 있을 수 없다).
    var deletingItem: ReactionPhotoItem?
    private(set) var isDeletingPhoto: Bool = false

    @ObservationIgnored
    @Dependency(\.deletePhotoUseCase) private var deletePhotoUseCase

    /// 사진 삭제 성공 시 상위(그룹상세)에 알려 목록을 다시 조회하게 한다.
    private let onPhotoDeleted: () -> Void

    public init(
        groupId: Int,
        groupName: String,
        dateText: String,
        members: [GroupMember],
        selectedUserId: Int,
        onPhotoDeleted: @escaping () -> Void = {}
    ) {
        self.groupId = groupId
        self.groupName = groupName
        self.dateText = dateText
        self.onPhotoDeleted = onPhotoDeleted
        items = members.map { ReactionPhotoItem(member: $0, reactions: Self.mockReactions(for: $0, in: members)) }
        selectedItemId = selectedUserId
    }

    var selectedItem: ReactionPhotoItem? {
        items.first { $0.id == selectedItemId }
    }

    /// 버튼 바 활성 여부. 내 사진·미업로드 사진에서는 비활성(Opacity 30%)된다.
    var isReactionEnabled: Bool {
        selectedItem?.isReactable ?? false
    }

    var isBusy: Bool { isDeletingPhoto }

    var modeTitle: String { mode.title }

    // MARK: - 리액션 남기기

    /// 이모지를 누르면 현재 모드의 코멘트 후보에서 하나를 뽑아 로그에 바로 붙인다. Figma의 로그는
    /// 아래가 최신인 채팅형 정렬이라(컨테이너 bottom 정렬 + 진입 시 최하단) 새 리액션도 맨 아래로 붙는다.
    func emojiTapped(_ emoji: ReactionEmoji) {
        guard isReactionEnabled,
              let index = items.firstIndex(where: { $0.id == selectedItemId }),
              let comment = mode.comments(for: emoji).randomElement()
        else { return }

        items[index].reactions.append(
            ReactionLogEntry(
                nickname: ReactionLogEntry.myDisplayName,
                isMine: true,
                emoji: emoji,
                comment: comment
            )
        )
    }

    // MARK: - 모드 변경

    func modeTapped() {
        pendingMode = mode
        isModeSheetPresented = true
    }

    /// '이후 버전' 모드는 선택 자체가 막혀 있어 pendingMode가 바뀌지 않는다.
    func modeSelected(_ mode: ReactionMode) {
        guard mode.isAvailable else { return }
        pendingMode = mode
    }

    /// 'X' 버튼. 고르던 값은 버리고 닫는다.
    func modeSheetDismissed() {
        isModeSheetPresented = false
    }

    /// '적용' 버튼. 고른 값을 반영하고 닫는다.
    func modeApplyTapped() {
        mode = pendingMode
        isModeSheetPresented = false
    }

    // MARK: - 미트볼 메뉴

    /// 남의 사진에만 노출되는 '신고하기'. 미업로드 카드는 배지 자체가 없어 호출되지 않는다.
    func reportTapped(_ item: ReactionPhotoItem) {
        reportTarget = item.reportTarget()
    }

    /// 신고 접수(또는 이탈)로 신고 화면을 닫을 때 호출한다.
    public func reportFinished() {
        reportTarget = nil
    }

    /// 내 사진에만 노출되는 '점심 사진 지우기'. 확인 모달만 띄우고 실제 삭제는 `deleteConfirmed()`에서 한다.
    func deleteTapped(_ item: ReactionPhotoItem) {
        guard item.hasPhoto else { return }
        deletingItem = item
    }

    func deleteCancelled() {
        deletingItem = nil
    }

    func deleteConfirmed() async {
        guard !isDeletingPhoto, let item = deletingItem, let photoId = item.member.photo?.photoId else { return }

        isDeletingPhoto = true
        // 재확인하지 않도록 모달을 먼저 닫는다. 실패해도 모달을 다시 띄우지 않고 토스트로만 알린다.
        deletingItem = nil
        defer { isDeletingPhoto = false }

        do {
            try await deletePhotoUseCase.execute(DeletePhotoRequest(groupId: groupId, photoId: photoId))
            clearPhoto(ofItemId: item.id)
            onPhotoDeleted()
            DSTopToastWindowPresenter.shared.show(
                DSTopToastContent(message: Constants.deleteSuccessMessage, tone: .success)
            )
        } catch {
            DSTopToastWindowPresenter.shared.show(
                DSTopToastContent(message: Constants.errorMessage, tone: .error)
            )
        }
    }

    /// 삭제한 카드는 페이저에서 빼지 않고 '미업로드' 상태로 되돌린다 — 인디케이터 dot이 그룹원과
    /// 1:1로 유지돼야 스와이프 위치가 어긋나지 않고, Figma의 '내 점심_미업로드' 상태와도 일치한다.
    private func clearPhoto(ofItemId id: Int) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        let member = items[index].member
        items[index] = ReactionPhotoItem(
            member: GroupMember(
                userId: member.userId,
                nickname: member.nickname,
                isMine: member.isMine,
                photo: nil
            )
        )
    }

    /// 리액션 조회 API가 없어 UI 확인용으로 채우는 임시 로그. API 연동 시 제거한다.
    private static func mockReactions(for member: GroupMember, in members: [GroupMember]) -> [ReactionLogEntry] {
        guard member.photo != nil,
              !member.userId.isMultiple(of: Constants.mockEmptyUserIdMultiple)
        else { return [] }

        let authors = members.filter { $0.userId != member.userId }
        guard !authors.isEmpty else { return [] }

        return (0 ..< Constants.mockReactionCount).compactMap { index in
            let author = authors[index % authors.count]
            let emoji = ReactionEmoji.allCases[index % ReactionEmoji.allCases.count]
            let comments = emoji.youngCrackComments
            guard !comments.isEmpty else { return nil }

            let comment = index == Constants.mockLongestCommentIndex
                ? comments.max { $0.count < $1.count } ?? comments[0]
                : comments[index % comments.count]

            return ReactionLogEntry(
                nickname: author.nickname,
                isMine: author.isMine,
                emoji: emoji,
                comment: comment
            )
        }
    }
}
