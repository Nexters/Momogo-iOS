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

    /// 오늘 이미 업로드한 그룹은 선택 대상 자체가 아니므로, "모두 선택"의 기준은 전체 그룹이 아니라
    /// 업로드 가능한 그룹만으로 계산한다.
    private var uploadableGroups: [PhotoUploadGroupOption] {
        groups.filter(\.isUploadable)
    }

    var isAllSelected: Bool {
        !uploadableGroups.isEmpty && selectedGroupIDs.count == uploadableGroups.count
    }

    var isConfirmEnabled: Bool {
        !selectedGroupIDs.isEmpty && !isUploading
    }

    func isSelected(_ group: PhotoUploadGroupOption) -> Bool {
        selectedGroupIDs.contains(group.id)
    }

    func toggle(_ group: PhotoUploadGroupOption) {
        guard group.isUploadable else { return }

        if selectedGroupIDs.contains(group.id) {
            selectedGroupIDs.remove(group.id)
        } else {
            selectedGroupIDs.insert(group.id)
        }
    }

    func toggleSelectAll() {
        selectedGroupIDs = isAllSelected ? [] : Set(uploadableGroups.map(\.id))
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
            groups = response.groups.map { summary in
                PhotoUploadGroupOption(
                    id: summary.groupId,
                    groupName: summary.groupName,
                    memberNames: summary.members.map(\.nickname),
                    isUploadable: !summary.todayPhotoUploaded
                )
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
