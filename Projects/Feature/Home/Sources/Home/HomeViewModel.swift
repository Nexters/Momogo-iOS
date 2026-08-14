import Foundation

import Dependencies
import DesignSystem
import DomainInterface
import FeatureGroup
import FeatureSettings
import SwiftUINavigation

@Observable
@MainActor
public final class HomeViewModel {
    var groups: [GroupSummary] = []
    var isLoading: Bool = false
    var errorMessage: String?
    /// 최초 로드 완료 여부. `groups.isEmpty`만으로는 로드 전 초기값과 실제 빈 상태를 구분할 수 없다.
    private(set) var hasLoaded: Bool = false

    /// 그룹 생성/참여 플로우의 push 상태.
    ///
    /// nil로 되돌아오는 경로는 종착 화면 CTA(`onFinish`)와 뒤로가기 pop 두 가지인데, 후자에서도
    /// 그룹 생성·참여 API는 이미 성공한 뒤일 수 있다. 그래서 경로를 구분하지 않고 항상 목록을 다시 불러온다.
    /// `.task`는 NavigationStack 루트가 뷰 계층에서 제거되지 않아 pop 복귀 시 재실행되지 않으므로,
    /// 여기가 복귀 후 목록을 갱신하는 유일한 지점이다. Settings로 갔다 돌아올 때도 동일하게 다시 불러온다.
    var destination: Destination? {
        didSet {
            guard destination == nil, oldValue != nil else { return }
            Task { await load() }
        }
    }

    @ObservationIgnored
    @Dependency(\.getGroupsUseCase) private var getGroupsUseCase

    private let onLogout: () -> Void

    public init(onLogout: @escaping () -> Void = {}) {
        self.onLogout = onLogout
    }

    /// 그룹 추가 메뉴에서 이미 생성/참여를 선택했으므로 `GroupSelectView`를 거치지 않고 각 플로우의 첫 화면으로 바로 들어간다.
    @CasePathable
    enum Destination {
        case groupName(GroupNameViewModel)
        case inviteCode(InviteCodeInputViewModel)
        case settings(SettingsViewModel)
    }

    func settingsTapped() {
        guard destination == nil else { return }
        // 탈퇴 완료 시에도 기존 로그아웃 경로(onLogout → 온보딩 복귀)를 그대로 태운다.
        destination = .settings(SettingsViewModel(onSessionEnded: onLogout))
    }

    /// 내 그룹들에서 오늘 사진을 올린 인원 수의 합. 그룹 목록 API가 인원 자체가 아닌 그룹별 집계 수치만 제공한다.
    var todayPosterCount: Int {
        groups.reduce(0) { $0 + $1.todayPhotoUploaderCount }
    }

    /// `onFinish`가 self를 강하게 잡으면 `HomeViewModel → destination → GroupNameViewModel → onFinish → HomeViewModel`
    /// 순환이 생긴다. 기존 플로우들은 상위에서 받은 `onFinish`를 그대로 넘기기만 해 순환이 없었지만,
    /// 홈은 클로저를 직접 만들어 자식에게 주는 첫 화면이라 여기서 끊어야 한다.
    /// 이 클로저는 자식이 손자(`InviteShareViewModel`)에게 그대로 전달하므로 weak가 플로우 끝까지 전파된다.
    func createGroupTapped() {
        guard destination == nil else { return }
        destination = .groupName(GroupNameViewModel(onFinish: { [weak self] in
            self?.destination = nil
        }))
    }

    func joinGroupTapped() {
        guard destination == nil else { return }
        destination = .inviteCode(InviteCodeInputViewModel(onFinish: { [weak self] in
            // 참여는 확인 화면 없이 곧바로 홈으로 돌아오므로, 완료 피드백을 여기서 대신 알린다.
            self?.destination = nil
            DSTopToastWindowPresenter.shared.show(.joinCompleted)
        }))
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
            hasLoaded = true
        }

        do {
            groups = try await getGroupsUseCase.execute().groups
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }
}
