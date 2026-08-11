import SwiftUI

import DesignSystem
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

                VStack(alignment: .leading, spacing: 16) {
                    Text("내 그룹")
                        .momogoTypography(.heading20)
                        .foregroundStyle(DesignSystem.Color.gray50)

                    if isGroupEmpty {
                        GroupEmptyView()
                    } else {
                        ForEach(viewModel.groups) { group in
                            GroupCardView(group: group)
                        }
                    }
                }

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
        .momogoMenuOverlay(
            isPresented: $isAddGroupMenuPresented,
            items: [
                DSMenu.Item("그룹 생성", icon: DesignSystemAsset.usersThree, action: {}),
                DSMenu.Item("그룹 참여", icon: DesignSystemAsset.login, action: {})
            ],
            anchorContent: {
                DSIconButton(.plus, style: .filled, action: toggleAddGroupMenu)
            }
        )
        .task {
            await viewModel.load()
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $viewModel.destination.settings) { settingsViewModel in
            SettingsView(viewModel: settingsViewModel)
        }
    }

    private func toggleAddGroupMenu() {
        withAnimation { isAddGroupMenuPresented.toggle() }
    }
}
