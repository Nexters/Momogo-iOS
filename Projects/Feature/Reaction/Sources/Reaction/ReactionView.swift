import SwiftUI

import DesignSystem

/// 반응 화면. 신고 화면(`ReportPhotoView`)은 FeatureHome이 소유해 호출부가 `reportDestination`으로
/// 주입한다 — FeatureHome → FeatureReaction 단방향 의존을 유지하기 위한 구조다.
public struct ReactionView<ReportDestination: View>: View {
    struct Constants {
        let pagerCardSpacing: CGFloat = 8
        let pagerHorizontalPadding: CGFloat = 16
        let pagerVerticalPadding: CGFloat = 8
        /// Figma 스펙: Button Bar는 화면 좌우 14pt를 남겨 347pt 폭이 된다(다른 화면의 16pt와 다름).
        let buttonBarHorizontalPadding: CGFloat = 14
        let buttonBarTopPadding: CGFloat = 8
        let buttonBarBottomPadding: CGFloat = 16
        let menuOffsetY: CGFloat = 8
        let menuDimOpacity: CGFloat = 0.4
        let modeSheetApplyTopPadding: CGFloat = 24

        let menuReportTitle = "신고하기"
        let menuDeleteTitle = "점심 사진 지우기"
        let menuCloseAccessibilityLabel = "메뉴 닫기"

        let modeSheetTitle = "모드 변경"
        let modeSheetApplyTitle = "적용"

        let deleteConfirmTitle = "사진을 삭제하시겠어요?"
        let deleteConfirmDescription = "이 그룹에서 사진이 사라져요"
        let deleteConfirmCancelTitle = "취소"
        let deleteConfirmConfirmTitle = "삭제"
    }

    private let constants = Constants()

    @Bindable private var viewModel: ReactionViewModel
    private let reportDestination: (ReactionReportTarget) -> ReportDestination

    @Environment(\.dismiss) private var dismiss
    /// 미트볼 메뉴가 열려 있는 카드의 `userId`. 카드마다 `.dsMenuAnchor()`를 항상 붙이면
    /// `DSMenuAnchorKey`가 마지막 카드 위치로 덮어써져 엉뚱한 곳에 메뉴가 뜬다(GroupDetailView 선례).
    @State private var menuTargetId: Int?

    public init(
        viewModel: ReactionViewModel,
        @ViewBuilder reportDestination: @escaping (ReactionReportTarget) -> ReportDestination
    ) {
        self.viewModel = viewModel
        self.reportDestination = reportDestination
    }

    public var body: some View {
        VStack(spacing: 0) {
            DSTopNavigationBar(title: viewModel.groupName, leading: {
                DSBackButton(action: { dismiss() })
            })

            ReactionIndicatorView(items: viewModel.items, selectedItemId: viewModel.selectedItemId)

            pager

            buttonBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.gray950.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .momogoLoadingOverlay(isPresented: viewModel.isBusy)
        // 로딩 오버레이가 탭은 막지만 인터랙티브 스와이프 백은 별개로 동작하므로 같이 막는다.
        .navigationBarBackButtonHidden(viewModel.isBusy)
        .navigationDestination(item: $viewModel.reportTarget) { target in
            reportDestination(target)
        }
        .overlayPreferenceValue(DSMenuAnchorKey.self) { anchor in
            menuOverlay(anchor: anchor)
        }
        .momogoBottomSheetOverlay(isPresented: $viewModel.isModeSheetPresented) { modeSheet }
        .momogoModalOverlay(isPresented: showsDeleteConfirm) { deleteConfirmModal }
        .task { await viewModel.load() }
    }

    /// 카드 1장이 화면 폭을 꽉 채우는 가로 페이저. `safeAreaPadding`으로 좌우 16pt를 빼고
    /// `containerRelativeFrame`으로 그 폭에 카드를 맞춰, Figma의 343pt 카드 + 8pt 간격을 재현한다.
    private var pager: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: constants.pagerCardSpacing) {
                ForEach(viewModel.items) { item in
                    ReactionPhotoCardView(
                        item: item,
                        dateText: viewModel.dateText,
                        isMenuAnchor: menuTargetId == item.id,
                        onTapMenu: { toggleMenu(for: item) }
                    )
                    .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $viewModel.selectedItemId)
        .safeAreaPadding(.horizontal, constants.pagerHorizontalPadding)
        .padding(.vertical, constants.pagerVerticalPadding)
    }

    private var buttonBar: some View {
        ReactionButtonBarView(
            modeTitle: viewModel.modeTitle,
            isEnabled: viewModel.isReactionEnabled,
            onTapMode: viewModel.modeTapped,
            onTapEmoji: { emoji in Task { await viewModel.emojiTapped(emoji) } }
        )
        .padding(.horizontal, constants.buttonBarHorizontalPadding)
        .padding(.top, constants.buttonBarTopPadding)
        .padding(.bottom, constants.buttonBarBottomPadding)
    }

    /// 딤 위에 앵커 뷰의 "밝은 사본"을 다시 그리는 `momogoMenuOverlay`는 스크롤되는 카드에서
    /// 원본과 사본이 어긋나 배지가 두 개로 보이는 문제가 있어(GroupDetailView 실측), 사본 없이
    /// 메뉴만 앵커 위치에 띄운다. 앵커는 `body`의 `overlayPreferenceValue`에서 받아 넘긴다 —
    /// 이 함수 안에서 직접 부르면 수신자가 자기 자신이 되어 무한 재귀가 된다.
    @ViewBuilder
    private func menuOverlay(anchor: Anchor<CGRect>?) -> some View {
        if let anchor, let item = menuTargetItem {
            ZStack(alignment: .topLeading) {
                Button {
                    withAnimation { menuTargetId = nil }
                } label: {
                    DesignSystem.Color.black.opacity(constants.menuDimOpacity).ignoresSafeArea()
                }
                .buttonStyle(.plain)
                .accessibilityLabel(constants.menuCloseAccessibilityLabel)

                DSMenu(menuItems(for: item))
                    .visualEffect { content, proxy in
                        let frame = proxy[anchor]
                        return content.offset(
                            x: frame.maxX - DSMenu.defaultWidth,
                            y: frame.maxY + constants.menuOffsetY
                        )
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
            .accessibilityAddTraits(.isModal)
        }
    }

    private var menuTargetItem: ReactionPhotoItem? {
        viewModel.items.first { $0.id == menuTargetId }
    }

    /// 내 사진이면 '점심 사진 지우기', 남의 사진이면 '신고하기' — 소유 여부로 완전히 갈리므로
    /// 한 카드에 두 항목이 함께 뜨는 경우는 없다(그룹상세와 동일 규칙).
    private func menuItems(for item: ReactionPhotoItem) -> [DSMenu.Item] {
        if item.member.isMine {
            [
                DSMenu.Item(constants.menuDeleteTitle, icon: DesignSystemAsset.trash) {
                    menuTargetId = nil
                    viewModel.deleteTapped(item)
                }
            ]
        } else {
            [
                DSMenu.Item(constants.menuReportTitle, icon: DesignSystemAsset.warningTriangle) {
                    menuTargetId = nil
                    viewModel.reportTapped(item)
                }
            ]
        }
    }

    private func toggleMenu(for item: ReactionPhotoItem) {
        withAnimation {
            menuTargetId = (menuTargetId == item.id) ? nil : item.id
        }
    }

    private var modeSheet: DSBottomSheet<some View> {
        DSBottomSheet(title: constants.modeSheetTitle, onClose: viewModel.modeSheetDismissed) {
            VStack(spacing: 0) {
                ForEach(ReactionMode.allCases) { mode in
                    Button {
                        viewModel.modeSelected(mode)
                    } label: {
                        DSBottomSheetAtom(
                            mode.sheetTitle,
                            state: viewModel.pendingMode == mode ? .activate : .deactivate
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!mode.isAvailable)
                }

                Button(constants.modeSheetApplyTitle, action: viewModel.modeApplyTapped)
                    .buttonStyle(.momogoButton(kind: .solid, tone: .primary, size: .xl, isFullWidth: true))
                    .padding(.top, constants.modeSheetApplyTopPadding)
            }
        }
    }

    /// `momogoModalOverlay`는 `Binding<Bool>`을 요구하지만 ViewModel은 삭제 대상까지 들고 있어야 해서
    /// `deletingItem: ReactionPhotoItem?`로 상태를 겸한다(그룹상세와 동일). 여기서 Bool로 어댑팅한다.
    private var showsDeleteConfirm: Binding<Bool> {
        Binding(
            get: { viewModel.deletingItem != nil },
            set: { isPresented in
                guard !isPresented else { return }
                viewModel.deletingItem = nil
            }
        )
    }

    private var deleteConfirmModal: DSModal {
        DSModal(
            title: constants.deleteConfirmTitle,
            description: constants.deleteConfirmDescription,
            primaryTitle: constants.deleteConfirmConfirmTitle,
            primaryAction: { Task { await viewModel.deleteConfirmed() } },
            secondaryTitle: constants.deleteConfirmCancelTitle,
            secondaryAction: viewModel.deleteCancelled
        )
    }
}
