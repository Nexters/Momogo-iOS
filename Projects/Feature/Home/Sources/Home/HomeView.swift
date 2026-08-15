import SwiftUI

import DesignSystem
import FeatureCamera
import FeatureGroup
import FeaturePhoto
import FeatureSettings
import SwiftUINavigation

public struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var cameraViewModel: CameraViewModel?
    @State private var photoUploadConfirmViewModel: PhotoUploadConfirmViewModel?
    /// 카메라 화면이 완전히 내려간 뒤(fullScreenCover onDismiss) 업로드 확인 화면을 이어서 띄우기
    /// 위해 잠시 들고 있는 캡처 결과. 두 fullScreenCover를 동시에 전환하면 애니메이션이 깨질 수
    /// 있어, 카메라가 내려가는 애니메이션이 끝난 뒤에 다음 화면을 띄운다.
    @State private var pendingPhotoData: Data?

    public init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    /// 순수 UI 상태라 ViewModel이 아닌 View가 소유한다.
    @State private var isAddGroupMenuPresented = false

    private var isGroupEmpty: Bool {
        viewModel.hasLoaded && viewModel.groups.isEmpty
    }

    public var body: some View {
        NavigationStack {
            content
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                TodayCardView(
                    hasGroups: !isGroupEmpty,
                    recentPhoto: viewModel.recentPhoto,
                    onTapAddGroup: toggleAddGroupMenu,
                    onTapSettings: viewModel.settingsTapped,
                    onTapShoot: presentCamera,
                    onTapCreateGroup: viewModel.createGroupTapped
                )

                GroupListSection(
                    groups: viewModel.groups,
                    isEmpty: isGroupEmpty,
                    hasNewPhoto: viewModel.hasNewPhoto,
                    onGroupTap: viewModel.groupTapped
                )

                if !isGroupEmpty {
                    ReactionCardView(posterCount: viewModel.todayPosterCount)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(DesignSystem.Color.gray950.ignoresSafeArea())
        // 딤·메뉴는 ScrollView 바깥에 걸어야 화면 전체를 덮고 스크롤에 클리핑되지 않는다.
        // 다만 NavigationStack보다는 안쪽이어야 한다. 앵커(`dsMenuAnchor()`)가 ScrollView 안에 있어
        // 오버레이가 같은 서브트리에서 preference를 읽어야 하고, 바깥에 걸면 push된 화면 위까지 딤이 덮인다.
        .momogoMenuOverlay(
            isPresented: $isAddGroupMenuPresented,
            items: [
                DSMenu.Item("그룹 생성", icon: DesignSystemAsset.usersThree, action: viewModel.createGroupTapped),
                DSMenu.Item("그룹 참여", icon: DesignSystemAsset.login, action: viewModel.joinGroupTapped)
            ],
            anchorContent: {
                DSIconButton(.plus, style: .filled, action: toggleAddGroupMenu)
            }
        )
        .task {
            await viewModel.load()
        }
        // 홈은 TodayCardView가 최상단에 오는 커스텀 레이아웃이라 시스템 내비게이션 바 영역만큼 밀리면 시안이 깨진다.
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $viewModel.destination.groupName) { groupNameViewModel in
            GroupNameView(viewModel: groupNameViewModel)
        }
        .navigationDestination(item: $viewModel.destination.inviteCode) { inviteCodeInputViewModel in
            InviteCodeInputView(viewModel: inviteCodeInputViewModel)
        }
        .navigationDestination(item: $viewModel.destination.settings) { settingsViewModel in
            SettingsView(viewModel: settingsViewModel)
        }
        .navigationDestination(item: $viewModel.destination.groupDetail) { groupDetailViewModel in
            GroupDetailView(viewModel: groupDetailViewModel)
        }
        .fullScreenCover(
            isPresented: $viewModel.isCameraPresented,
            onDismiss: { presentPhotoUploadConfirmIfNeeded() },
            content: {
                if let cameraViewModel {
                    CameraView(viewModel: cameraViewModel)
                }
            }
        )
        .fullScreenCover(
            isPresented: Binding(
                get: { photoUploadConfirmViewModel != nil },
                set: { isPresented in if !isPresented { photoUploadConfirmViewModel = nil } }
            ),
            content: {
                if let photoUploadConfirmViewModel {
                    PhotoUploadConfirmView(viewModel: photoUploadConfirmViewModel)
                }
            }
        )
    }

    private func toggleAddGroupMenu() {
        withAnimation { isAddGroupMenuPresented.toggle() }
    }

    private func presentCamera() {
        cameraViewModel = CameraViewModel(onFinish: { photoData in
            pendingPhotoData = photoData
            viewModel.isCameraPresented = false
        })
        viewModel.isCameraPresented = true
    }

    /// 카메라 fullScreenCover가 완전히 닫힌 뒤 호출된다. 촬영을 취소했다면(pendingPhotoData == nil)
    /// 아무것도 하지 않고, 촬영에 성공했다면 이어서 그룹 선택(업로드 확인) 화면을 띄운다.
    private func presentPhotoUploadConfirmIfNeeded() {
        cameraViewModel = nil
        guard let photoData = pendingPhotoData else { return }
        pendingPhotoData = nil

        photoUploadConfirmViewModel = PhotoUploadConfirmViewModel(
            photoData: photoData,
            onCancel: { photoUploadConfirmViewModel = nil },
            onUploaded: {
                photoUploadConfirmViewModel = nil
                Task { await viewModel.load() }
            }
        )
    }
}
