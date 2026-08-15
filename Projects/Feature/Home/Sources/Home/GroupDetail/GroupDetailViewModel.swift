import Foundation

import Dependencies
import DesignSystem
import DomainInterface
import SwiftUINavigation

@Observable
@MainActor
public final class GroupDetailViewModel {
    @CasePathable
    enum Destination {
        case renameGroup(GroupRenameViewModel)
        case reportPhoto(ReportPhotoViewModel)
    }

    let groupId: Int
    let todayPhotoUploaderCount: Int

    var groupName: String
    var members: [GroupMember] = []
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

    @ObservationIgnored
    @Dependency(\.getGroupDetailUseCase) private var getGroupDetailUseCase
    @ObservationIgnored
    @Dependency(\.leaveGroupUseCase) private var leaveGroupUseCase
    @ObservationIgnored
    @Dependency(\.deletePhotoUseCase) private var deletePhotoUseCase

    /// 그룹 탈퇴 완료 시 상위(HomeViewModel)에 알려 화면을 되돌리고 목록을 새로고침한다.
    private let onLeave: () -> Void
    /// 사진 삭제 성공 시 상위(HomeViewModel)에 알려 홈 썸네일을 다시 계산하게 한다. 홈은 이 화면이
    /// pop될 때도 재조회하지만, 삭제 시점에 화면 안에 계속 머무는 경우까지 커버하려면 별도 통지가 필요하다.
    private let onPhotoDeleted: () -> Void

    public init(
        groupId: Int,
        groupName: String,
        todayPhotoUploaderCount: Int,
        onLeave: @escaping () -> Void = {},
        onPhotoDeleted: @escaping () -> Void = {}
    ) {
        self.groupId = groupId
        self.groupName = groupName
        self.todayPhotoUploaderCount = todayPhotoUploaderCount
        self.onLeave = onLeave
        self.onPhotoDeleted = onPhotoDeleted
    }

    /// 이 화면에서 진행 중인 API 요청이 하나라도 있는지. `momogoLoadingOverlay`를 하나로 묶어 걸기 위한 값이다.
    var isBusy: Bool {
        isLoading || isLeaving || isDeletingPhoto
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
            members = response.members
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
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

    /// 기존 그룹의 초대코드를 다시 조회하는 API가 아직 없어, 실제 공유 대신 안내 토스트만 띄운다.
    func inviteShareTapped() {
        DSTopToastWindowPresenter.shared.show(DSTopToastContent(message: "초대코드 공유는 곧 지원될 예정이에요", tone: .notice))
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

    /// 사진 카드 더보기 메뉴의 "점심 사진 지우기" 항목. 내 사진에만 노출되므로 `member.isMine`을
    /// 다시 확인하지 않는다. 확인 모달을 띄우기만 하고, 실제 삭제는 `deletePhotoConfirmed()`에서 한다.
    func deleteTapped(_ member: GroupMember) {
        guard member.photo != nil else { return }
        deletingPhotoMember = member
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
