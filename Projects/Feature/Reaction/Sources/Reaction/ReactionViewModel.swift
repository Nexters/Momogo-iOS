import Foundation

import Dependencies
import DesignSystem
import DomainInterface

/// 반응 화면. 리액션 등록·조회 모두 API로 처리한다(문구는 서버 카탈로그 우선, 없으면 클라이언트
/// 폴백 프리셋에서 랜덤 추첨). 화면 진입 시 `load()`가 사진별 리액션을 병렬로 불러오고, 등록은
/// 성공 시 로컬에 즉시 반영한다(등록 직후 다시 조회하지 않는다 — 이미 로컬에 반영돼 있어 불필요).
/// 사진 삭제는 이미 있는 UseCase를 그대로 쓴다.
@Observable
@MainActor
public final class ReactionViewModel {
    private enum Constants {
        static let deleteSuccessMessage = "사진을 삭제했어요"
        static let errorMessage = "잠시 후 다시 시도해주세요."
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
    @ObservationIgnored
    @Dependency(\.getCommentsUseCase) private var getCommentsUseCase
    @ObservationIgnored
    @Dependency(\.addReactionUseCase) private var addReactionUseCase
    @ObservationIgnored
    @Dependency(\.getReactionsUseCase) private var getReactionsUseCase

    /// 리액션 등록 중인 아이템(사진)의 id 집합. 화면 전체를 막는 Bool이 아니라 아이템 단위로 두는
    /// 이유는, 페이저를 스와이프하며 여러 사진에 빠르게 반응하는 게 이 화면의 자연스러운 사용
    /// 패턴이라 화면 전체를 막으면 무관한 다른 사진의 탭까지 아무 신호 없이 무시되기 때문이다.
    private var registeringItemIds: Set<Int> = []

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
        items = members.map { ReactionPhotoItem(member: $0) }
        selectedItemId = selectedUserId
    }

    /// 화면 진입 시 사진이 있는 멤버 각각의 리액션을 병렬로 불러온다. `ReactionView`의 `.task`에서 호출한다.
    func load() async {
        let getReactionsUseCase = getReactionsUseCase // self 캡처 없이 TaskGroup에 넘기기 위해 로컬로 복사
        let groupId = groupId

        await withTaskGroup(of: (Int, [ReactionLogEntry]).self) { group in
            for item in items {
                guard let photoId = item.member.photo?.photoId else { continue }
                group.addTask {
                    let reactions = await (try? getReactionsUseCase.execute(groupId, photoId)) ?? []
                    // 서버가 이미 등록순으로 정렬해서 내려주므로 클라이언트에서 다시 정렬하지 않는다.
                    let entries = reactions.map {
                        ReactionLogEntry(
                            nickname: $0.nickname,
                            isMine: $0.isMine,
                            emoji: ReactionEmoji(catalogKey: $0.emoji),
                            comment: $0.comment
                        )
                    }
                    return (item.id, entries)
                }
            }
            for await (itemId, entries) in group {
                guard let index = items.firstIndex(where: { $0.id == itemId }) else { continue }
                // 화면 진입 직후 이 사진에 대한 등록(POST)이 조회(GET)보다 먼저 성공하면, 로컬에는
                // 이미 내 리액션이 붙어 있다. 통째로 덮어쓰면 그게 사라진 것처럼 보이므로, fetch 결과에
                // 없는 "내 리액션"만 골라 뒤에 살려 붙인다. 안정적인 서버 id가 로컬 항목엔 없어
                // (emoji, comment) 내용 일치로 판단한다.
                let fetchedMineKeys = Set(entries.filter(\.isMine).map { "\($0.emoji.rawValue)|\($0.comment)" })
                let localOnlyMine = items[index].reactions.filter {
                    $0.isMine && !fetchedMineKeys.contains("\($0.emoji.rawValue)|\($0.comment)")
                }
                items[index].reactions = entries + localOnlyMine
            }
        }
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

    /// 이모지를 누르면 현재 모드의 코멘트 후보에서 하나를 뽑아 서버에 등록하고, 성공했을 때만
    /// 로그에 붙인다(비관적 업데이트 — 요청 스펙이 아직 미확인이라, 실패를 낙관적 UI로 가리면
    /// "등록이 하나도 안 되고 있다"는 사실을 놓치기 쉽다). Figma의 로그는 아래가 최신인 채팅형
    /// 정렬이라(컨테이너 bottom 정렬 + 진입 시 최하단) 새 리액션도 맨 아래로 붙는다.
    func emojiTapped(_ emoji: ReactionEmoji) async {
        guard isReactionEnabled,
              let item = selectedItem,
              !registeringItemIds.contains(item.id),
              let photoId = item.member.photo?.photoId,
              let concept = mode.catalogConcept,
              let comment = mode.comments(for: emoji, serverContents: serverContents(for: emoji)).randomElement()
        else { return }

        registeringItemIds.insert(item.id)
        defer { registeringItemIds.remove(item.id) }

        do {
            try await addReactionUseCase.execute(
                AddReactionRequest(
                    groupId: groupId,
                    photoId: photoId,
                    concept: concept,
                    emoji: emoji.catalogKey,
                    comment: comment
                )
            )
            // await 도중 페이저가 스와이프돼 selectedItemId가 바뀔 수 있어, 탭 시점에 캡처한
            // item.id로 다시 찾아 붙인다 — selectedItemId를 다시 읽으면 엉뚱한 카드에 붙을 수 있다.
            appendMyReaction(emoji: emoji, comment: comment, toItemId: item.id)
        } catch {
            DSTopToastWindowPresenter.shared.show(
                DSTopToastContent(message: Constants.errorMessage, tone: .error)
            )
        }
    }

    private func appendMyReaction(emoji: ReactionEmoji, comment: String, toItemId id: Int) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        items[index].reactions.append(
            ReactionLogEntry(
                nickname: ReactionLogEntry.myDisplayName,
                isMine: true,
                emoji: emoji,
                comment: comment
            )
        )
    }

    /// 스플래시에서 미리 채워둔 문구 카탈로그를 탭 시점에 조회한다. init 시점 스냅샷을 쓰지 않는
    /// 이유는, 스플래시 동기화가 이 화면이 뜬 뒤에 끝나도 다음 탭부터 바로 반영되게 하기 위해서다.
    /// 모드에 서버 매핑이 없으면(`ReactionMode.catalogConcept`, 현재는 영크크 모드만 있음) 조회
    /// 자체를 하지 않고 빈 배열을 반환해 폴백으로 넘어간다.
    private func serverContents(for emoji: ReactionEmoji) -> [String] {
        guard let concept = mode.catalogConcept else { return [] }
        return getCommentsUseCase.execute(concept, emoji.catalogKey)
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
}
