import SwiftUI

import DesignSystem
import DomainInterface

public struct GroupDetailView: View {
    struct Constants {
        let columnSpacing: CGFloat = 15
        let gridSpacing: CGFloat = 24
        let gridHorizontalPadding: CGFloat = 16
        let gridTopPadding: CGFloat = 4
        let gridBottomPadding: CGFloat = 40
        /// Figma 스펙: 2단 그리드에서 (행+열)이 짝수면 -해당 값, 홀수면 +해당 값으로 번갈아 기울인다.
        let cardRotationDegrees: Double = 2

        let todayLabel = "오늘"
        let todayUploaderCountSuffix = "명 업로드"

        let dateTextWidth: CGFloat = 93
        let dateBadgeHorizontalPadding: CGFloat = 16
        let dateBadgeVerticalPadding: CGFloat = 20
        let dateArrowIconSize: CGFloat = 18
        let dateArrowTapAreaSize: CGFloat = 24
        let dateArrowDisabledOpacity: CGFloat = 0.4

        let todayTagIconSize: CGFloat = 18
        let todayTagHorizontalPadding: CGFloat = 12
        // Figma 스펙: Tag 68×33 — 폰트 메트릭에 기대지 않고 높이를 고정해 가로세로 비율을 맞춘다.
        let todayTagHeight: CGFloat = 33
        let todayTagBackgroundOpacity: CGFloat = 0.08

        let menuInviteShareTitle = "초대코드 공유"
        let menuRenameGroupTitle = "그룹명 변경"
        let menuLeaveGroupTitle = "그룹 떠나기"

        let leaveConfirmTitle = "그룹을 떠나시겠어요?"
        let leaveConfirmDescription = "내가 업로드한 기록이 사라져요"
        let leaveConfirmCancelTitle = "취소"
        let leaveConfirmConfirmTitle = "떠나기"
    }

    private let constants = Constants()

    @Bindable private var viewModel: GroupDetailViewModel
    @Environment(\.dismiss) private var dismiss
    /// 순수 UI 상태라 ViewModel이 아닌 View가 소유한다(Home의 그룹 추가 메뉴와 동일한 이유).
    @State private var isMenuPresented = false

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: constants.columnSpacing),
            GridItem(.flexible(), spacing: constants.columnSpacing)
        ]
    }

    public init(viewModel: GroupDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            navigationBar
            dateBadge

            ScrollView {
                LazyVGrid(columns: columns, spacing: constants.gridSpacing) {
                    ForEach(Array(viewModel.members.enumerated()), id: \.element.id) { index, member in
                        GroupPhotoCardView(member: member, rotationDegrees: rotationDegrees(forIndex: index))
                    }
                }
                .padding(.horizontal, constants.gridHorizontalPadding)
                .padding(.top, constants.gridTopPadding)
                .padding(.bottom, constants.gridBottomPadding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.gray950.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
        .navigationDestination(item: $viewModel.destination.renameGroup) { renameViewModel in
            GroupRenameView(viewModel: renameViewModel)
        }
        .momogoMenuOverlay(
            isPresented: $isMenuPresented,
            items: [
                DSMenu.Item(
                    constants.menuInviteShareTitle,
                    icon: DesignSystemAsset.share2,
                    action: viewModel.inviteShareTapped
                ),
                DSMenu.Item(
                    constants.menuRenameGroupTitle,
                    icon: DesignSystemAsset.edit,
                    action: viewModel.renameTapped
                ),
                DSMenu.Item(
                    constants.menuLeaveGroupTitle,
                    icon: DesignSystemAsset.logout,
                    tone: .destructive,
                    action: viewModel.leaveTapped
                )
            ],
            anchorContent: {
                DSIconButton(.more, action: toggleMenu)
            }
        )
        .momogoModalOverlay(isPresented: $viewModel.showsLeaveConfirm) { leaveConfirmModal }
    }

    private var navigationBar: some View {
        DSTopNavigationBar(
            leading: {
                HStack(spacing: 4) {
                    DSBackButton(action: { dismiss() })
                    VStack(alignment: .leading, spacing: 1) {
                        Text(viewModel.groupName)
                            .momogoTypography(.lgSemistrong)
                            .foregroundStyle(DesignSystem.Color.gray50)
                            .lineLimit(1)
                        HStack(spacing: 3) {
                            Text(constants.todayLabel).foregroundStyle(DesignSystem.Color.gray300)
                            Text("\(viewModel.todayPhotoUploaderCount)").foregroundStyle(DesignSystem.Color.white)
                            Text(constants.todayUploaderCountSuffix).foregroundStyle(DesignSystem.Color.gray300)
                        }
                        .momogoTypography(.xsMedium)
                    }
                }
            },
            trailing: {
                DSIconButton(.more, action: toggleMenu)
                    .dsMenuAnchor()
            }
        )
    }

    private var dateBadge: some View {
        HStack(spacing: 0) {
            Button(action: viewModel.previousDayTapped) {
                Image(asset: DesignSystemAsset.arrowLeftCircleFill)
                    .resizable()
                    .scaledToFit()
                    .frame(width: constants.dateArrowIconSize, height: constants.dateArrowIconSize)
                    .frame(width: constants.dateArrowTapAreaSize, height: constants.dateArrowTapAreaSize)
                    .foregroundStyle(DesignSystem.Color.gray700)
            }
            Text(viewModel.formattedDate)
                .momogoTypography(.mdSemistrong)
                .foregroundStyle(DesignSystem.Color.gray50)
                .frame(width: constants.dateTextWidth)
            Button(action: viewModel.nextDayTapped) {
                Image(asset: DesignSystemAsset.arrowRightCircleFill)
                    .resizable()
                    .scaledToFit()
                    .frame(width: constants.dateArrowIconSize, height: constants.dateArrowIconSize)
                    .frame(width: constants.dateArrowTapAreaSize, height: constants.dateArrowTapAreaSize)
                    .foregroundStyle(DesignSystem.Color.gray700)
                    .opacity(viewModel.isNextDayDisabled ? constants.dateArrowDisabledOpacity : 1)
            }
            .disabled(viewModel.isNextDayDisabled)
        }
        // 날짜 pill은 가운데 유지하고, 태그는 전체 너비 기준 trailing에 오버레이한다.
        // `.overlay`는 부모 높이에 영향을 주지 않아, 태그가 나타나도 아래 그리드가 밀리지 않는다.
        .frame(maxWidth: .infinity)
        .overlay(alignment: .trailing) {
            if viewModel.showsTodayTag {
                todayTagButton
            }
        }
        .padding(.horizontal, constants.dateBadgeHorizontalPadding)
        .padding(.vertical, constants.dateBadgeVerticalPadding)
    }

    private var todayTagButton: some View {
        Button(action: viewModel.todayTagTapped) {
            HStack(spacing: 2) {
                Text(constants.todayLabel)
                Image(asset: DesignSystemAsset.undo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: constants.todayTagIconSize, height: constants.todayTagIconSize)
                    .foregroundStyle(DesignSystem.Color.gray300)
            }
            .momogoTypography(.smMedium)
            .foregroundStyle(DesignSystem.Color.gray50)
            .padding(.horizontal, constants.todayTagHorizontalPadding)
            .frame(height: constants.todayTagHeight)
            .background(Color.white.opacity(constants.todayTagBackgroundOpacity))
            .clipShape(Capsule())
        }
    }

    /// Figma 스펙: "취소"(outlined, 왼쪽) / "떠나기"(solid primary, 오른쪽).
    /// `DSModal`은 secondaryTitle을 outlined·왼쪽에, primaryTitle을 solid·오른쪽에 배치한다.
    private var leaveConfirmModal: DSModal {
        DSModal(
            title: constants.leaveConfirmTitle,
            description: constants.leaveConfirmDescription,
            primaryTitle: constants.leaveConfirmConfirmTitle,
            primaryAction: { Task { await viewModel.leaveConfirmed() } },
            secondaryTitle: constants.leaveConfirmCancelTitle,
            secondaryAction: viewModel.leaveCancelled
        )
    }

    private func rotationDegrees(forIndex index: Int) -> Double {
        let row = index / columns.count
        let col = index % columns.count
        return (row + col).isMultiple(of: 2) ? -constants.cardRotationDegrees : constants.cardRotationDegrees
    }

    private func toggleMenu() {
        withAnimation { isMenuPresented.toggle() }
    }
}
