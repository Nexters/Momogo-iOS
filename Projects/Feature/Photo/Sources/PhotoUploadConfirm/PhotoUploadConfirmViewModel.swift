import Foundation

import Dependencies
import DomainInterface

@Observable
@MainActor
public final class PhotoUploadConfirmViewModel {
    let photoData: Data
    private(set) var groups: [PhotoUploadGroupOption] = []
    private(set) var selectedGroupIDs: Set<Int> = []
    private(set) var isLoadingGroups = false
    private(set) var isUploading = false
    var errorMessage: String?

    private let contentType: String
    private let onCancel: () -> Void
    private let onUploaded: () -> Void

    @ObservationIgnored
    @Dependency(\.getGroupsUseCase) private var getGroupsUseCase
    @ObservationIgnored
    @Dependency(\.uploadPhotoUseCase) private var uploadPhotoUseCase

    /// - Parameters:
    ///   - contentType: 업로드할 이미지의 MIME 타입. 기본값은 카메라가 만들어내는 JPEG 데이터를 가정한다.
    ///   - onCancel: 뒤로가기 시 호출. 사진 업로드 취소 및 홈 화면 이동은 이 화면을 띄운 상위 플로우가 책임진다.
    ///   - onUploaded: 선택된 그룹에 업로드가 성공적으로 확정된 뒤 호출된다.
    public init(
        photoData: Data,
        contentType: String = "image/jpeg",
        onCancel: @escaping () -> Void,
        onUploaded: @escaping () -> Void
    ) {
        self.photoData = photoData
        self.contentType = contentType
        self.onCancel = onCancel
        self.onUploaded = onUploaded
    }

    var isAllSelected: Bool {
        !groups.isEmpty && selectedGroupIDs.count == groups.count
    }

    var isConfirmEnabled: Bool {
        !selectedGroupIDs.isEmpty && !isUploading
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

    func onAppear() async {
        guard groups.isEmpty else { return }

        isLoadingGroups = true
        defer { isLoadingGroups = false }

        do {
            let response = try await getGroupsUseCase.execute()
            groups = response.groups.map {
                PhotoUploadGroupOption(id: $0.groupId, groupName: $0.groupName, memberNames: [])
            }
        } catch {
            errorMessage = ViewModelCopy.groupsLoadFailed
        }
    }

    func confirmTapped() async {
        isUploading = true
        defer { isUploading = false }

        do {
            _ = try await uploadPhotoUseCase.execute(
                UploadPhotoRequest(photoData: photoData, contentType: contentType, groupIDs: Array(selectedGroupIDs))
            )
            onUploaded()
        } catch {
            errorMessage = ViewModelCopy.uploadFailed
        }
    }
}

private enum ViewModelCopy {
    static let groupsLoadFailed = "그룹 목록을 불러오지 못했어요"
    static let uploadFailed = "업로드에 실패했어요. 다시 시도해주세요"
}
