import SwiftUI

import DesignSystem
import FeatureGroup
import FeatureSettings
import SwiftUINavigation

public struct HomeView: View {
    @State private var viewModel: HomeViewModel

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
                    onTapAddGroup: toggleAddGroupMenu,
                    onTapSettings: viewModel.settingsTapped
                )

                GroupListSection(
                    groups: viewModel.groups,
                    isEmpty: isGroupEmpty,
                    onTapGroup: viewModel.groupTapped
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
    }

    private func toggleAddGroupMenu() {
        withAnimation { isAddGroupMenuPresented.toggle() }
    }
}
