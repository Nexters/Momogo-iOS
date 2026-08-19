import ConcurrencyExtras
import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import FeatureHome

/// `getGroupVisitsUseCase`/`markGroupVisitedUseCase`는 실제로는 로컬(UserDefaults)을 건드리지만,
/// 여기서는 항상 테스트 더블로 주입해 실제 로컬 저장을 전혀 거치지 않는다.
@MainActor
struct HomeViewModelTests {
    private enum Constants {
        static let myPhotosDate = "2026-08-12"
    }

    private func withMockedDependencies(
        groups: [GroupSummary] = [],
        visits: [Int: String] = [:],
        myPhotos: [MyPhoto] = [],
        onMarkVisited: @escaping @Sendable (Int, String?) -> Void = { _, _ in },
        operation: () async throws -> Void
    ) async rethrows {
        try await withDependencies {
            $0.getGroupsUseCase = GetGroupsUseCase { GetGroupsResponse(groups: groups) }
            $0.getGroupVisitsUseCase = GetGroupVisitsUseCase { visits }
            $0.markGroupVisitedUseCase = MarkGroupVisitedUseCase(execute: onMarkVisited)
            // 홈 상단 최근 사진 미리보기용. 빈 목록이면 `resolveRecentPhoto`가 즉시 nil을 반환해
            // `getGroupDetailUseCase`까지 타지 않는다.
            $0.getMyPhotosUseCase = GetMyPhotosUseCase { _ in
                GetMyPhotosResponse(date: Constants.myPhotosDate, photos: myPhotos)
            }
        } operation: {
            try await operation()
        }
    }

    @Test("load()는 그룹 목록과 방문 기록을 함께 불러와 각 그룹의 New 배지 여부를 판정한다")
    func load_populatesGroupsAndBadgeState() async {
        let alreadySeen = GroupSummary(
            groupId: 1, groupName: "이미 봄", totalMemberCount: 2, todayPhotoUploaderCount: 1,
            latestUploadAt: "2026-08-10T00:00:00.000000"
        )
        let newPhoto = GroupSummary(
            groupId: 2, groupName: "새 사진 있음", totalMemberCount: 3, todayPhotoUploaderCount: 2,
            latestUploadAt: "2026-08-12T00:00:00.000000"
        )
        let neverVisited = GroupSummary(
            groupId: 3, groupName: "한 번도 안 봄", totalMemberCount: 1, todayPhotoUploaderCount: 0,
            latestUploadAt: "2026-08-01T00:00:00.000000"
        )

        await withMockedDependencies(
            groups: [alreadySeen, newPhoto, neverVisited],
            visits: [1: "2026-08-10T00:00:00.000000", 2: "2026-08-11T00:00:00.000000"]
        ) {
            let viewModel = HomeViewModel()

            await viewModel.load()

            #expect(viewModel.groups.map(\.groupId) == [1, 2, 3])
            #expect(viewModel.hasNewPhoto(alreadySeen) == false)
            #expect(viewModel.hasNewPhoto(newPhoto) == true)
            #expect(viewModel.hasNewPhoto(neverVisited) == true)
        }
    }

    @Test("groupTapped는 방문을 기록하고 상세 화면으로 이동하며, 배지를 재조회 없이 즉시 지운다")
    func groupTapped_marksVisitedNavigatesAndClearsBadgeOptimistically() async {
        let group = GroupSummary(
            groupId: 10, groupName: "우리 가족", totalMemberCount: 4, todayPhotoUploaderCount: 2,
            latestUploadAt: "2026-08-12T09:00:00.000000"
        )
        let markedCalls = LockIsolated<[(groupId: Int, latestUploadAt: String?)]>([])

        await withMockedDependencies(
            groups: [group],
            onMarkVisited: { groupId, latestUploadAt in
                markedCalls.withValue { $0.append((groupId, latestUploadAt)) }
            },
            operation: {
                let viewModel = HomeViewModel()
                await viewModel.load()
                #expect(viewModel.hasNewPhoto(group) == true)

                viewModel.groupTapped(group)

                #expect(markedCalls.value.count == 1)
                #expect(markedCalls.value.first?.groupId == 10)
                #expect(markedCalls.value.first?.latestUploadAt == "2026-08-12T09:00:00.000000")
                // load()를 다시 부르지 않아도 방금 탭한 그룹은 더 이상 New가 아니어야 한다(낙관적 갱신).
                #expect(viewModel.hasNewPhoto(group) == false)

                guard case let .groupDetail(detailViewModel) = viewModel.destination else {
                    Issue.record("groupDetail로 push되어야 한다")
                    return
                }
                #expect(detailViewModel.groupId == 10)
                #expect(detailViewModel.groupName == "우리 가족")
            }
        )
    }

    @Test("groupTapped는 활성 사진이 없는 그룹(latestUploadAt == nil)도 방문 기록에 nil을 그대로 남긴다")
    func groupTapped_withNoActivePhoto_marksVisitedWithNil() async {
        let group = GroupSummary(groupId: 20, groupName: "대학 동기", totalMemberCount: 3, todayPhotoUploaderCount: 0)
        let markedCalls = LockIsolated<[(groupId: Int, latestUploadAt: String?)]>([])

        await withMockedDependencies(
            groups: [group],
            onMarkVisited: { groupId, latestUploadAt in
                markedCalls.withValue { $0.append((groupId, latestUploadAt)) }
            },
            operation: {
                let viewModel = HomeViewModel()
                await viewModel.load()

                viewModel.groupTapped(group)

                #expect(markedCalls.value.first?.groupId == 20)
                #expect(markedCalls.value.first?.latestUploadAt == nil)
            }
        )
    }
}
