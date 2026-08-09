import SwiftUI

import DesignSystem

public struct HomeView: View {
    @State private var viewModel: HomeViewModel

    public init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private var isGroupEmpty: Bool {
        viewModel.hasLoaded && viewModel.groups.isEmpty
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                TodayCardView(hasGroups: !isGroupEmpty)

                VStack(alignment: .leading, spacing: 16) {
                    Text("내 그룹")
                        .momogoTypography(.heading20)
                        .foregroundStyle(DesignSystem.Color.gray50)

                    if isGroupEmpty {
                        GroupEmptyView()
                    } else {
                        ForEach(viewModel.groups, id: \.groupId) { group in
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
        .task {
            await viewModel.load()
        }
    }
}
