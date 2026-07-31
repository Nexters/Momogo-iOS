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

    public init() {}

    /// 내 그룹들에서 오늘 사진을 올린 고유 인원. 같은 사람이 여러 그룹에 올려도 한 번만 센다.
    var todayPosters: [GroupMemberPhoto] {
        var seenMemberIds = Set<Int>()
        return groups.flatMap(\.photos).filter { seenMemberIds.insert($0.memberId).inserted }
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
}
