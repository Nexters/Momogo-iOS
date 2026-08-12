import ConcurrencyExtras
import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import FeaturePhoto

@MainActor
struct PhotoUploadConfirmViewModelTests {
    private func makeViewModel(
        photoData: Data = Data(),
        onCancel: @escaping () -> Void = {},
        onUploaded: @escaping () -> Void = {}
    ) -> PhotoUploadConfirmViewModel {
        PhotoUploadConfirmViewModel(photoData: photoData, onCancel: onCancel, onUploaded: onUploaded)
    }

    /// `getGroupsUseCase`(목록)와 `getGroupDetailUseCase`(멤버 이름)를 함께 목킹한다.
    /// `membersByGroupID`에 없는 그룹 ID는 멤버 이름 없이(빈 배열) 반환한다.
    private func withMockGroups(
        _ groups: [GroupSummary],
        membersByGroupID: [Int: [String]] = [:],
        operation: () async throws -> Void
    ) async rethrows {
        try await withDependencies {
            $0.getGroupsUseCase = GetGroupsUseCase { GetGroupsResponse(groups: groups) }
            $0.getGroupDetailUseCase = GetGroupDetailUseCase { request in
                let nicknames = membersByGroupID[request.groupId] ?? []
                return GetGroupDetailResponse(
                    groupId: request.groupId,
                    groupName: "",
                    members: nicknames.map { GroupMember(userId: 0, nickname: $0, isMine: false) }
                )
            }
        } operation: {
            try await operation()
        }
    }

    @Test("화면이 나타나면 그룹 목록과 멤버 이름을 불러와 초기에는 아무 그룹도 선택돼 있지 않다")
    func onAppear_loadsGroupsWithMemberNames_noneSelectedInitially() async throws {
        try await withMockGroups(
            [
                GroupSummary(groupId: 1, groupName: "그룹1", totalMemberCount: 2, todayPhotoUploaderCount: 0),
                GroupSummary(groupId: 2, groupName: "그룹2", totalMemberCount: 1, todayPhotoUploaderCount: 0)
            ],
            membersByGroupID: [1: ["나나", "가가"]]
        ) {
            let viewModel = makeViewModel()

            await viewModel.onAppear()

            #expect(viewModel.groups.map(\.id) == [1, 2])
            #expect(viewModel.groups[0].memberNames == ["가가", "나나"]) // 가나다순 정렬
            #expect(viewModel.groups[1].memberNames == [])
            #expect(viewModel.isConfirmEnabled == false)
            #expect(viewModel.isAllSelected == false)
        }
    }

    @Test("그룹 목록 조회에 실패하면 에러 메시지가 노출된다")
    func onAppear_failure_setsErrorMessage() async throws {
        try await withDependencies {
            $0.getGroupsUseCase = GetGroupsUseCase { throw PhotoUploadTestError.failed }
        } operation: {
            let viewModel = makeViewModel()

            await viewModel.onAppear()

            #expect(viewModel.groups.isEmpty)
            #expect(viewModel.errorMessage != nil)
        }
    }

    @Test("그룹 상세 조회가 실패해도 화면 전체는 막지 않고 해당 그룹의 멤버 이름만 빈 채로 남는다")
    func onAppear_detailFailure_leavesMemberNamesEmptyButLoadsGroup() async throws {
        try await withDependencies {
            $0.getGroupsUseCase = GetGroupsUseCase {
                GetGroupsResponse(groups: [
                    GroupSummary(groupId: 1, groupName: "그룹1", totalMemberCount: 2, todayPhotoUploaderCount: 0)
                ])
            }
            $0.getGroupDetailUseCase = GetGroupDetailUseCase { _ in throw PhotoUploadTestError.failed }
        } operation: {
            let viewModel = makeViewModel()

            await viewModel.onAppear()

            #expect(viewModel.groups.map(\.id) == [1])
            #expect(viewModel.groups[0].memberNames == [])
            #expect(viewModel.errorMessage == nil)
        }
    }

    @Test("그룹을 1개 이상 선택하면 CTA가 활성화된다")
    func toggle_selectsGroup_enablesConfirm() async throws {
        try await withMockGroups([
            GroupSummary(groupId: 1, groupName: "그룹1", totalMemberCount: 2, todayPhotoUploaderCount: 0)
        ]) {
            let viewModel = makeViewModel()
            await viewModel.onAppear()

            viewModel.toggle(viewModel.groups[0])

            #expect(viewModel.isSelected(viewModel.groups[0]))
            #expect(viewModel.isConfirmEnabled)
        }
    }

    @Test("모두 선택을 탭하면 전체 그룹이 선택되고, 다시 탭하면 전체 해제된다")
    func toggleSelectAll_selectsAndDeselectsAllGroups() async throws {
        try await withMockGroups([
            GroupSummary(groupId: 1, groupName: "그룹1", totalMemberCount: 2, todayPhotoUploaderCount: 0),
            GroupSummary(groupId: 2, groupName: "그룹2", totalMemberCount: 1, todayPhotoUploaderCount: 0)
        ]) {
            let viewModel = makeViewModel()
            await viewModel.onAppear()

            viewModel.toggleSelectAll()
            #expect(viewModel.isAllSelected)

            viewModel.toggleSelectAll()
            #expect(viewModel.isAllSelected == false)
        }
    }

    @Test("뒤로가기를 탭하면 취소 콜백이 호출된다")
    func backTapped_invokesOnCancel() {
        var didCancel = false
        let viewModel = makeViewModel(onCancel: { didCancel = true })

        viewModel.backTapped()

        #expect(didCancel)
    }

    @Test("업로드를 탭하면 선택된 그룹 ID로 UploadPhotoUseCase를 호출하고, 성공 시 onUploaded가 호출된다")
    func confirmTapped_success_invokesOnUploaded() async throws {
        let requestedGroupIDs = LockIsolated<[Int]?>(nil)

        try await withMockGroups([
            GroupSummary(groupId: 1, groupName: "그룹1", totalMemberCount: 2, todayPhotoUploaderCount: 0)
        ]) {
            try await withDependencies {
                $0.uploadPhotoUseCase = UploadPhotoUseCase { request in
                    requestedGroupIDs.setValue(request.groupIDs)
                    return UploadPhotoResponse(photoId: 501, objectKey: request.contentType)
                }
            } operation: {
                var didUpload = false
                let viewModel = makeViewModel(onUploaded: { didUpload = true })
                await viewModel.onAppear()
                viewModel.toggle(viewModel.groups[0])

                await viewModel.confirmTapped()

                #expect(requestedGroupIDs.value == [1])
                #expect(didUpload)
                #expect(viewModel.errorMessage == nil)
            }
        }
    }

    @Test("업로드가 실패하면 onUploaded를 호출하지 않고 에러 메시지를 노출한다")
    func confirmTapped_failure_setsErrorMessage() async throws {
        try await withMockGroups([
            GroupSummary(groupId: 1, groupName: "그룹1", totalMemberCount: 2, todayPhotoUploaderCount: 0)
        ]) {
            try await withDependencies {
                $0.uploadPhotoUseCase = UploadPhotoUseCase { _ in throw PhotoUploadTestError.failed }
            } operation: {
                var didUpload = false
                let viewModel = makeViewModel(onUploaded: { didUpload = true })
                await viewModel.onAppear()
                viewModel.toggle(viewModel.groups[0])

                await viewModel.confirmTapped()

                #expect(didUpload == false)
                #expect(viewModel.errorMessage != nil)
            }
        }
    }
}

private enum PhotoUploadTestError: Error {
    case failed
}
