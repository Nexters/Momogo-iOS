import SwiftUI

import DesignSystem

public struct HomeView: View {
    @State private var viewModel: HomeViewModel

    public init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                TodayCardView()

                VStack(alignment: .leading, spacing: 16) {
                    Text("내 그룹")
                        .momogoTypography(.heading20)
                        .foregroundStyle(DesignSystem.Color.gray50)

                    ForEach(viewModel.groups, id: \.groupId) { group in
                        GroupCardView(group: group)
                    }
                }

                ReactionCardView(posters: viewModel.todayPosters)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(DesignSystem.Color.gray950.ignoresSafeArea())
        .safeAreaInset(edge: .top) {
            DSTopNavigationBar(
                leading: { DSNavigationLogo() },
                trailing: {
                    HStack(spacing: 12) {
                        DSIconButton(.plus, style: .circular, action: {})
                        DSIconButton(.settings, style: .circular, action: {})
                    }
                }
            )
            .background(DesignSystem.Color.gray950)
        }
        .task {
            await viewModel.load()
        }
    }
}
