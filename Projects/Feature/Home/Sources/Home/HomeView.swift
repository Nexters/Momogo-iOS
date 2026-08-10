import SwiftUI

import DesignSystem

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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                TodayCardView(hasGroups: !isGroupEmpty, onTapAddGroup: toggleAddGroupMenu)

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

                // 플로우 검증용 임시 버튼들 — Settings 화면이 생기면 그쪽으로 옮기고 여기서는 제거한다.
                VStack(alignment: .leading, spacing: 8) {
                    Button("로그아웃 (임시)", action: viewModel.logoutTapped)
                    Button("refresh/UUID 토큰 초기화 (임시)", action: viewModel.clearLocalAuthStateTapped)
                }
                .momogoTypography(.smMedium)
                .foregroundStyle(DesignSystem.Color.gray100)
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
                HomeHeaderIconButton(
                    asset: DesignSystemAsset.plus,
                    accessibilityLabel: "그룹 추가",
                    action: toggleAddGroupMenu
                )
            }
        )
        .task {
            await viewModel.load()
        }
    }

    private func toggleAddGroupMenu() {
        withAnimation { isAddGroupMenuPresented.toggle() }
    }
}
