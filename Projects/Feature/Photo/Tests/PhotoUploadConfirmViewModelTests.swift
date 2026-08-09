import Foundation
import Testing
@testable import FeaturePhoto

@MainActor
struct PhotoUploadConfirmViewModelTests {
    private let groups: [PhotoUploadGroupOption] = [
        PhotoUploadGroupOption(id: 1, groupName: "그룹1", memberNames: ["나나", "가가"]),
        PhotoUploadGroupOption(id: 2, groupName: "그룹2", memberNames: ["다다"])
    ]

    private func makeViewModel(
        photoData: Data = Data(),
        onCancel: @escaping () -> Void = {},
        onConfirm: @escaping (Data, Set<Int>) -> Void = { _, _ in }
    ) -> PhotoUploadConfirmViewModel {
        PhotoUploadConfirmViewModel(photoData: photoData, groups: groups, onCancel: onCancel, onConfirm: onConfirm)
    }

    @Test("초기 상태에서는 아무 그룹도 선택되지 않아 CTA가 비활성 상태다")
    func initialState_hasNoSelection_confirmDisabled() {
        let viewModel = makeViewModel()

        #expect(viewModel.isConfirmEnabled == false)
        #expect(viewModel.isAllSelected == false)
    }

    @Test("그룹을 1개 이상 선택하면 CTA가 활성화된다")
    func toggle_selectsGroup_enablesConfirm() {
        let viewModel = makeViewModel()

        viewModel.toggle(groups[0])

        #expect(viewModel.isSelected(groups[0]))
        #expect(viewModel.isConfirmEnabled)
    }

    @Test("모두 선택을 탭하면 전체 그룹이 선택되고, 다시 탭하면 전체 해제된다")
    func toggleSelectAll_selectsAndDeselectsAllGroups() {
        let viewModel = makeViewModel()

        viewModel.toggleSelectAll()
        #expect(viewModel.isAllSelected)
        #expect(groups.allSatisfy(viewModel.isSelected))

        viewModel.toggleSelectAll()
        #expect(viewModel.isAllSelected == false)
        #expect(groups.allSatisfy { !viewModel.isSelected($0) })
    }

    @Test("멤버 이름은 가나다 순으로 정렬된다")
    func memberNames_areSortedInKoreanAlphabeticalOrder() {
        let option = PhotoUploadGroupOption(id: 1, groupName: "그룹", memberNames: ["다다", "가가", "나나"])

        #expect(option.memberNames == ["가가", "나나", "다다"])
    }

    @Test("뒤로가기를 탭하면 취소 콜백이 호출된다")
    func backTapped_invokesOnCancel() {
        var didCancel = false
        let viewModel = makeViewModel(onCancel: { didCancel = true })

        viewModel.backTapped()

        #expect(didCancel)
    }

    @Test("업로드를 탭하면 선택된 그룹 ID와 사진 데이터로 확인 콜백이 호출된다")
    func confirmTapped_invokesOnConfirm_withSelectedGroupIDs() {
        let photoData = Data([0x01, 0x02])
        var confirmedData: Data?
        var confirmedIDs: Set<Int>?
        let viewModel = makeViewModel(
            photoData: photoData,
            onConfirm: { data, ids in
                confirmedData = data
                confirmedIDs = ids
            }
        )
        viewModel.toggle(groups[0])

        viewModel.confirmTapped()

        #expect(confirmedData == photoData)
        #expect(confirmedIDs == [1])
    }
}
