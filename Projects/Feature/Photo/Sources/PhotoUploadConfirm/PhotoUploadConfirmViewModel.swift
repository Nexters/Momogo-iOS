import Foundation

@Observable
@MainActor
public final class PhotoUploadConfirmViewModel {
    let photoData: Data
    let groups: [PhotoUploadGroupOption]
    private(set) var selectedGroupIDs: Set<Int> = []

    private let onCancel: () -> Void
    private let onConfirm: (Data, Set<Int>) -> Void

    /// - Parameters:
    ///   - onCancel: 뒤로가기 시 호출. 사진 업로드 취소 및 홈 화면 이동은 이 화면을 띄운 상위 플로우가 책임진다.
    ///   - onConfirm: CTA 탭 시 사진 데이터와 선택된 그룹 ID 목록으로 호출된다.
    public init(
        photoData: Data,
        groups: [PhotoUploadGroupOption],
        onCancel: @escaping () -> Void,
        onConfirm: @escaping (Data, Set<Int>) -> Void
    ) {
        self.photoData = photoData
        self.groups = groups
        self.onCancel = onCancel
        self.onConfirm = onConfirm
    }

    var isAllSelected: Bool {
        !groups.isEmpty && selectedGroupIDs.count == groups.count
    }

    var isConfirmEnabled: Bool {
        !selectedGroupIDs.isEmpty
    }

    func isSelected(_ group: PhotoUploadGroupOption) -> Bool {
        selectedGroupIDs.contains(group.id)
    }

    func toggle(_ group: PhotoUploadGroupOption) {
        if selectedGroupIDs.contains(group.id) {
            selectedGroupIDs.remove(group.id)
        } else {
            selectedGroupIDs.insert(group.id)
        }
    }

    func toggleSelectAll() {
        selectedGroupIDs = isAllSelected ? [] : Set(groups.map(\.id))
    }

    func backTapped() {
        onCancel()
    }

    func confirmTapped() {
        onConfirm(photoData, selectedGroupIDs)
    }
}
