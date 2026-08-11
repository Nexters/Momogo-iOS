import Foundation

import Dependencies
import DomainInterface
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
    var destination: Destination?

    @ObservationIgnored
    @Dependency(\.getGroupsUseCase) private var getGroupsUseCase

    private let onLogout: () -> Void

    public init(onLogout: @escaping () -> Void = {}) {
        self.onLogout = onLogout
    }

    @CasePathable
    enum Destination {
        case settings(SettingsViewModel)
    }

    func settingsTapped() {
        // 탈퇴 완료 시에도 기존 로그아웃 경로(onLogout → 온보딩 복귀)를 그대로 태운다.
        destination = .settings(SettingsViewModel(onSessionEnded: onLogout))
    }

    /// 내 그룹들에서 오늘 사진을 올린 인원 수의 합. 그룹 목록 API가 인원 자체가 아닌 그룹별 집계 수치만 제공한다.
    var todayPosterCount: Int {
        groups.reduce(0) { $0 + $1.todayPhotoUploaderCount }
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
