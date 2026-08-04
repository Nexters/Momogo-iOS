import Foundation

import Dependencies
import DomainInterface

@Observable
@MainActor
public final class HomeViewModel {
    var groups: [GroupSummary] = []
    var isLoading: Bool = false
    var errorMessage: String?

    @ObservationIgnored
    @Dependency(\.getGroupsUseCase) private var getGroupsUseCase
    @ObservationIgnored
    @Dependency(\.logoutUseCase) private var logoutUseCase
    @ObservationIgnored
    @Dependency(\.clearLocalAuthStateUseCase) private var clearLocalAuthStateUseCase

    private let onLogout: () -> Void

    public init(onLogout: @escaping () -> Void = {}) {
        self.onLogout = onLogout
    }

    /// 내 그룹들에서 오늘 사진을 올린 인원 수의 합. 그룹 목록 API가 인원 자체가 아닌 그룹별 집계 수치만 제공한다.
    var todayPosterCount: Int {
        groups.reduce(0) { $0 + $1.todayPhotoUploaderCount }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            groups = try await getGroupsUseCase.execute().groups
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }

    /// 플로우 검증용 임시 로그아웃 진입점.
    func logoutTapped() {
        Task {
            if await logoutUseCase.execute() {
                onLogout()
            }
        }
    }

    /// 플로우 검증용 임시 진입점 — refreshToken/accessToken/게스트 UUID를 전부 지워 완전히 새 유저 상태를 재현한다.
    func clearLocalAuthStateTapped() {
        clearLocalAuthStateUseCase.execute()
        onLogout()
    }
}
