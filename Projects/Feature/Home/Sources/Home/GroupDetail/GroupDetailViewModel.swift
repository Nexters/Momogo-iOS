import Foundation
import UIKit

import Dependencies
import DesignSystem
import DomainInterface
import FeatureReaction
import SwiftUINavigation

@Observable
@MainActor
public final class GroupDetailViewModel {
    @CasePathable
    enum Destination {
        case renameGroup(GroupRenameViewModel)
        case reportPhoto(ReportPhotoViewModel)
        case reaction(ReactionViewModel)
    }

    let groupId: Int
    /// 상위(Home)에서 최초 진입 시 전달받은 초깃값이며, 이후 `load()`가 오늘 날짜를 조회할 때마다
    /// `members`의 실제 업로드 현황으로 다시 계산된다(`recalculateTodayPhotoUploaderCountIfNeeded()`).
    /// 과거 날짜를 보는 동안에는 그 날짜의 인원 수로 "오늘" 표시가 오염되지 않도록 갱신하지 않는다.
    var todayPhotoUploaderCount: Int

    var groupName: String
    private(set) var invitationCode: String?
    var members: [GroupMember] = []
    /// 사진(`photoId`)별로 카드에 노출할 반응 하나. `loadReactions()`가 `load()` 직후 채운다.
    var featuredReactionByPhotoId: [Int: PhotoReaction] = [:]
    var selectedDate: Date = GroupDetailViewModel.today
    var isLoading: Bool = false
    var errorMessage: String?

    var destination: Destination?
    var showsLeaveConfirm: Bool = false
    var isLeaving: Bool = false

    /// 삭제 확인 모달 대상. nil이 아니면 모달이 노출된다(그룹 나가기의 `showsLeaveConfirm`과 달리
    /// 확인 대상 사진 정보까지 함께 들고 있어야 해서 Bool 대신 Optional로 상태를 겸한다).
    var deletingPhotoMember: GroupMember?
    var isDeletingPhoto: Bool = false

    /// 내 빈 카드의 카메라 아이콘을 탭했을 때 카메라 fullScreenCover를 띄우는 데 쓰인다
    /// (`HomeViewModel.isCameraPresented`와 동일 패턴).
    var isCameraPresented: Bool = false
    var isUploadingPhoto: Bool = false

    @ObservationIgnored
    @Dependency(\.getGroupDetailUseCase) private var getGroupDetailUseCase
    @ObservationIgnored
    @Dependency(\.leaveGroupUseCase) private var leaveGroupUseCase
    @ObservationIgnored
    @Dependency(\.deletePhotoUseCase) private var deletePhotoUseCase
    @ObservationIgnored
    @Dependency(\.uploadPhotoUseCase) private var uploadPhotoUseCase
    @ObservationIgnored
    @Dependency(\.getReactionsUseCase) private var getReactionsUseCase

    /// 그룹 탈퇴 완료 시 상위(HomeViewModel)에 알려 화면을 되돌리고 목록을 새로고침한다.
    private let onLeave: () -> Void
    /// 사진 삭제 성공 시 상위(HomeViewModel)에 알려 홈 썸네일을 다시 계산하게 한다. 홈은 이 화면이
    /// pop될 때도 재조회하지만, 삭제 시점에 화면 안에 계속 머무는 경우까지 커버하려면 별도 통지가 필요하다.
    private let onPhotoDeleted: () -> Void
    /// 그룹상세에서 직접 촬영·업로드했을 때도 위와 동일한 이유로 상위에 통지한다.
    private let onPhotoUploaded: () -> Void

    public init(
        groupId: Int,
        groupName: String,
        todayPhotoUploaderCount: Int,
        onLeave: @escaping () -> Void = {},
        onPhotoDeleted: @escaping () -> Void = {},
        onPhotoUploaded: @escaping () -> Void = {}
    ) {
        self.groupId = groupId
        self.groupName = groupName
        self.todayPhotoUploaderCount = todayPhotoUploaderCount
        self.onLeave = onLeave
        self.onPhotoDeleted = onPhotoDeleted
        self.onPhotoUploaded = onPhotoUploaded
    }

    /// 이 화면에서 진행 중인 API 요청이 하나라도 있는지. `momogoLoadingOverlay`를 하나로 묶어 걸기 위한 값이다.
    var isBusy: Bool {
        isLoading || isLeaving || isDeletingPhoto || isUploadingPhoto
    }

    var isToday: Bool {
        Self.calendar.isDate(selectedDate, inSameDayAs: Self.today)
    }

    /// 날짜 변경 완료 시 노출되고, '오늘' 태그를 누르면 오늘 날짜로 원복되며 함께 숨김 처리된다.
    var showsTodayTag: Bool { !isToday }
    var isNextDayDisabled: Bool { isToday }

    var formattedDate: String {
        Self.displayDateFormatter.string(from: selectedDate)
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let requestDate = isToday ? nil : Self.apiDateFormatter.string(from: selectedDate)
            let response = try await getGroupDetailUseCase.execute(
                GetGroupDetailRequest(groupId: groupId, date: requestDate)
            )
            groupName = response.groupName
            invitationCode = response.invitationCode
            members = response.members
            recalculateTodayPhotoUploaderCountIfNeeded()
            await loadReactions()
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }

    /// 사진이 있는 멤버마다 반응을 조회해 카드에 띄울 하나를 고른다. 한 사진에 여러 반응이 달릴 수
    /// 있어(예: 여러 명이 각자 반응), 정책상 "코멘트가 있는 것 중 가장 최근 것"을 보여준다 —
    /// 코멘트 없는(이모지만 있는) 반응은 태그에 보여줄 텍스트가 없어 후보에서 제외한다.
    /// 개별 사진 조회가 실패해도 그 사진만 태그 없이 넘어가고, 나머지 그리드 표시는 막지 않는다.
    /// 사진마다 순차 호출하면 인원 수만큼 왕복이 누적돼 그룹상세 진입이 느려지므로, 병렬로 조회해
    /// 전체 대기시간을 가장 느린 요청 1개 수준으로 줄인다.
    private func loadReactions() async {
        let getReactionsUseCase = getReactionsUseCase // self 캡처 없이 TaskGroup에 넘기기 위해 로컬로 복사
        let groupId = groupId
        let photoIds = members.compactMap(\.photo?.photoId)

        let results = await withTaskGroup(of: (Int, PhotoReaction?).self) { group in
            for photoId in photoIds {
                group.addTask {
                    guard let reactions = try? await getReactionsUseCase.execute(groupId, photoId) else {
                        return (photoId, nil)
                    }
                    return (photoId, Self.featuredReaction(in: reactions))
                }
            }
            return await group.reduce(into: [Int: PhotoReaction]()) { partialResult, result in
                partialResult[result.0] = result.1
            }
        }
        featuredReactionByPhotoId = results
    }

    private nonisolated static func featuredReaction(in reactions: [PhotoReaction]) -> PhotoReaction? {
        reactions.filter { !$0.comment.isEmpty }.max { $0.createdAt < $1.createdAt }
    }

    /// `GetGroupDetailResponse`는 업로더 수 필드를 내려주지 않아, 오늘 날짜를 보고 있을 때만
    /// `members`(각자의 `photo` 유무)로부터 직접 센다. 초기값은 목록 화면(`GroupSummary`)에서
    /// 전달받은 값을 그대로 쓰다가, 이 화면에서 사진을 올리거나 지워 오늘자 목록이 바뀌면
    /// 여기서 실제 값으로 맞춘다.
    private func recalculateTodayPhotoUploaderCountIfNeeded() {
        guard isToday else { return }
        todayPhotoUploaderCount = members.filter { $0.photo != nil }.count
    }

    func previousDayTapped() {
        guard let newDate = Self.calendar.date(byAdding: .day, value: -1, to: selectedDate) else { return }
        selectedDate = newDate
        Task { await load() }
    }

    func nextDayTapped() {
        guard !isNextDayDisabled,
              let newDate = Self.calendar.date(byAdding: .day, value: 1, to: selectedDate)
        else { return }
        selectedDate = newDate
        Task { await load() }
    }

    func todayTagTapped() {
        guard !isToday else { return }
        selectedDate = Self.today
        Task { await load() }
    }

    /// `load()`가 아직 성공하지 못했으면 코드가 없다. 로딩 중엔 momogoLoadingOverlay가 탭을 막지만,
    /// 조회 실패 후에는 메뉴가 그대로 눌리므로 여기서 방어한다.
    func inviteShareTapped() {
        guard let invitationCode else {
            DSTopToastWindowPresenter.shared.show(DSTopToastContent(message: "잠시 후 다시 시도해주세요.", tone: .error))
            return
        }
        UIPasteboard.general.string = invitationCode
        DSTopToastWindowPresenter.shared.show(DSTopToastContent(message: "초대코드가 복사되었어요!", tone: .success))
    }

    func renameTapped() {
        destination = .renameGroup(
            GroupRenameViewModel(groupId: groupId, currentName: groupName, onFinish: { [weak self] newName in
                self?.groupName = newName
                self?.destination = nil
                DSTopToastWindowPresenter.shared.show(DSTopToastContent(message: "그룹명이 저장되었어요", tone: .success))
            })
        )
    }

    func leaveTapped() {
        showsLeaveConfirm = true
    }

    func leaveCancelled() {
        showsLeaveConfirm = false
    }

    func leaveConfirmed() async {
        guard !isLeaving else { return }

        isLeaving = true
        // 재확인하지 않도록 모달을 먼저 닫는다. 실패해도 모달을 다시 띄우지 않고 토스트로만 알린다.
        showsLeaveConfirm = false
        defer { isLeaving = false }

        do {
            try await leaveGroupUseCase.execute(groupId)
            onLeave()
        } catch {
            DSTopToastWindowPresenter.shared.show(DSTopToastContent(message: "잠시 후 다시 시도해주세요.", tone: .error))
        }
    }

    /// 사진 카드 더보기 메뉴의 "신고하기" 항목. 남의 사진에만 노출되므로 `member.isMine`을 다시
    /// 확인하지 않는다. 사진이 없는(placeholder) 카드에서는 메뉴 자체가 뜨지 않아 호출되지 않는다.
    func reportTapped(_ member: GroupMember) {
        guard member.photo != nil else { return }

        destination = .reportPhoto(
            ReportPhotoViewModel(
                groupId: groupId,
                member: member,
                dateText: formattedDate,
                onFinish: { [weak self] in self?.destination = nil }
            )
        )
    }

    /// 반응 화면에서 '신고하기'를 눌렀을 때 push할 신고 화면 ViewModel. 신고 화면은 FeatureHome이
    /// 소유하므로 FeatureReaction은 대상(`ReactionReportTarget`)만 넘기고, 조립은 여기서 한다.
    func makeReportPhotoViewModel(
        for reactionViewModel: ReactionViewModel,
        target: ReactionReportTarget
    ) -> ReportPhotoViewModel {
        ReportPhotoViewModel(
            groupId: groupId,
            member: target.member,
            dateText: reactionViewModel.dateText,
            onFinish: { reactionViewModel.reportFinished() }
        )
    }

    /// 사진 카드 더보기 메뉴의 "점심 사진 지우기" 항목. 내 사진에만 노출되므로 `member.isMine`을
    /// 다시 확인하지 않는다. 확인 모달을 띄우기만 하고, 실제 삭제는 `deletePhotoConfirmed()`에서 한다.
    func deleteTapped(_ member: GroupMember) {
        guard member.photo != nil else { return }
        deletingPhotoMember = member
    }

    /// 사진 카드를 탭하면 그 멤버의 사진부터 시작하는 반응 화면으로 이동한다. 사진이 없는 카드는
    /// 탭 대상이 아니라(내 카드는 카메라, 남의 카드는 무반응) 여기까지 오지 않는다.
    func photoTapped(_ member: GroupMember) {
        guard member.photo != nil else { return }

        destination = .reaction(
            ReactionViewModel(
                groupId: groupId,
                groupName: groupName,
                dateText: formattedDate,
                members: members,
                selectedUserId: member.userId,
                onPhotoDeleted: { [weak self] in
                    guard let self else { return }
                    // 중첩 Task 클로저 안에서는 self 캡처를 명시해야 한다(암시적 캡처 금지).
                    Task { await self.load() }
                    onPhotoDeleted()
                }
            )
        )
    }

    func deletePhotoCancelled() {
        deletingPhotoMember = nil
    }

    func deletePhotoConfirmed() async {
        guard !isDeletingPhoto, let photoId = deletingPhotoMember?.photo?.photoId else { return }

        isDeletingPhoto = true
        // 재확인하지 않도록 모달을 먼저 닫는다. 실패해도 모달을 다시 띄우지 않고 토스트로만 알린다.
        deletingPhotoMember = nil
        defer { isDeletingPhoto = false }

        do {
            try await deletePhotoUseCase.execute(DeletePhotoRequest(groupId: groupId, photoId: photoId))
            await load()
            onPhotoDeleted()
            DSTopToastWindowPresenter.shared.show(DSTopToastContent(message: "사진을 삭제했어요", tone: .success))
        } catch {
            DSTopToastWindowPresenter.shared.show(DSTopToastContent(message: "잠시 후 다시 시도해주세요.", tone: .error))
        }
    }

    /// 내 빈 카드의 카메라 아이콘으로 촬영한 사진을 현재 그룹에 바로 업로드한다. 이 화면은 이미
    /// `groupId`가 확정된 컨텍스트라, 홈에서 쓰는 `PhotoUploadConfirmView`(여러 그룹 중 선택)를
    /// 다시 거치지 않고 `[groupId]` 하나만 담아 업로드한다.
    func uploadCapturedPhoto(_ photoData: Data) async {
        guard !isUploadingPhoto else { return }

        isUploadingPhoto = true
        defer { isUploadingPhoto = false }

        do {
            _ = try await uploadPhotoUseCase.execute(
                UploadPhotoRequest(photoData: photoData, contentType: "image/jpeg", groupIDs: [groupId])
            )
            await load()
            onPhotoUploaded()
            DSTopToastWindowPresenter.shared.show(DSTopToastContent(message: "사진을 업로드했어요", tone: .success))
        } catch {
            DSTopToastWindowPresenter.shared.show(DSTopToastContent(message: "잠시 후 다시 시도해주세요.", tone: .error))
        }
    }

    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        return calendar
    }

    private static var today: Date {
        calendar.startOfDay(for: Date())
    }

    private static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter
    }()
}
