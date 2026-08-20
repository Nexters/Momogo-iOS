import SwiftUI

import DesignSystem
import DomainInterface
import FeatureCamera
import FeatureReaction

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

        let photoMenuReportTitle = "신고하기"
        let photoMenuDeleteTitle = "점심 사진 지우기"

        let leaveConfirmTitle = "그룹을 떠나시겠어요?"
        let leaveConfirmDescription = "내가 업로드한 기록이 사라져요"
        let leaveConfirmCancelTitle = "취소"
        let leaveConfirmConfirmTitle = "떠나기"

        let deleteConfirmTitle = "사진을 삭제하시겠어요?"
        let deleteConfirmDescription = "이 그룹에서 사진이 사라져요"
        let deleteConfirmCancelTitle = "취소"
        let deleteConfirmConfirmTitle = "삭제"
    }

    private let constants = Constants()

    @Bindable private var viewModel: GroupDetailViewModel
    @Environment(\.dismiss) private var dismiss
    /// 순수 UI 상태라 ViewModel이 아닌 View가 소유한다(Home의 그룹 추가 메뉴와 동일한 이유).
    @State private var isMenuPresented = false
    /// 더보기 메뉴가 열려 있는 사진 카드의 `userId`. 카드마다 `.dsMenuAnchor()`를 항상 붙이면
    /// `DSMenuAnchorKey`가 마지막 카드 위치로 덮어써져 엉뚱한 곳에 메뉴가 뜬다 — 이 카드만
    /// 조건부로 앵커를 붙여(GroupPhotoCardView 참고) 한 번에 하나의 메뉴만 정확한 위치에 뜨게 한다.
    @State private var photoMenuTargetId: Int?
    /// 내 빈 카드의 카메라 아이콘 → 촬영 → 업로드 흐름(Home의 `presentCamera` 선례와 동일 구조).
    @State private var cameraViewModel: CameraViewModel?
    @State private var pendingPhotoData: Data?

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
                        GroupPhotoCardView(
                            member: member,
                            reaction: member.photo.flatMap { viewModel.featuredReactionByPhotoId[$0.photoId] },
                            rotationDegrees: rotationDegrees(forIndex: index),
                            isMenuAnchor: photoMenuTargetId == member.userId,
                            onTapMenu: { togglePhotoMenu(for: member) },
                            onTapCamera: presentCamera,
                            onTapPhoto: { viewModel.photoTapped(member) }
                        )
                    }
                }
                .padding(.horizontal, constants.gridHorizontalPadding)
                .padding(.top, constants.gridTopPadding)
                .padding(.bottom, constants.gridBottomPadding)
            }
            .refreshable { await viewModel.load() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.gray950.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .momogoLoadingOverlay(isPresented: viewModel.isBusy)
        // 로딩 오버레이가 화면을 덮어 탭은 막지만, 인터랙티브 스와이프 백 제스처는 별개로 계속 동작하므로 같이 막는다.
        .navigationBarBackButtonHidden(viewModel.isBusy)
        .task { await viewModel.load() }
        .navigationDestination(item: $viewModel.destination.renameGroup) { renameViewModel in
            GroupRenameView(viewModel: renameViewModel)
        }
        .navigationDestination(item: $viewModel.destination.reportPhoto) { reportPhotoViewModel in
            ReportPhotoView(viewModel: reportPhotoViewModel)
        }
        // 반응 화면의 '신고하기'도 이 스택에 push된다. 신고 화면은 FeatureHome이 소유하므로
        // FeatureReaction에는 대상만 넘기고 화면은 여기서 만들어 주입한다(단방향 의존 유지).
        .navigationDestination(item: $viewModel.destination.reaction) { reactionViewModel in
            ReactionView(viewModel: reactionViewModel) { target in
                ReportPhotoView(viewModel: viewModel.makeReportPhotoViewModel(for: reactionViewModel, target: target))
            }
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
        .overlayPreferenceValue(DSMenuAnchorKey.self) { anchor in
            photoMenuOverlay(anchor: anchor)
        }
        .momogoModalOverlay(isPresented: $viewModel.showsLeaveConfirm) { leaveConfirmModal }
        .momogoModalOverlay(isPresented: showsDeletePhotoConfirm) { deleteConfirmModal }
        .fullScreenCover(
            isPresented: $viewModel.isCameraPresented,
            onDismiss: { uploadPendingPhotoIfNeeded() },
            content: {
                if let cameraViewModel {
                    CameraView(viewModel: cameraViewModel)
                }
            }
        )
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

    /// `momogoModalOverlay`는 `Binding<Bool>`을 요구하지만, ViewModel은 삭제 대상 사진 정보까지
    /// 함께 들고 있어야 해서 `deletingPhotoMember: GroupMember?`로 상태를 겸한다. 여기서 Bool로 어댑팅한다.
    private var showsDeletePhotoConfirm: Binding<Bool> {
        Binding(
            get: { viewModel.deletingPhotoMember != nil },
            set: { isPresented in
                guard !isPresented else { return }
                viewModel.deletingPhotoMember = nil
            }
        )
    }

    /// Figma 스펙(그룹 나가기 모달)과 동일하게 "취소"(outlined, 왼쪽) / "삭제"(solid primary, 오른쪽).
    private var deleteConfirmModal: DSModal {
        DSModal(
            title: constants.deleteConfirmTitle,
            description: constants.deleteConfirmDescription,
            primaryTitle: constants.deleteConfirmConfirmTitle,
            primaryAction: { Task { await viewModel.deletePhotoConfirmed() } },
            secondaryTitle: constants.deleteConfirmCancelTitle,
            secondaryAction: viewModel.deletePhotoCancelled
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

    private func presentCamera() {
        cameraViewModel = CameraViewModel(onFinish: { photoData in
            pendingPhotoData = photoData
            viewModel.isCameraPresented = false
        })
        viewModel.isCameraPresented = true
    }

    /// 카메라 fullScreenCover가 완전히 닫힌 뒤 호출된다. 촬영을 취소했다면(pendingPhotoData == nil)
    /// 아무것도 하지 않고, 촬영에 성공했다면 이 그룹으로 바로 업로드한다(Home과 달리 그룹 선택
    /// 화면을 거치지 않는다 — `groupId`가 이미 확정돼 있으므로).
    private func uploadPendingPhotoIfNeeded() {
        cameraViewModel = nil
        guard let photoData = pendingPhotoData else { return }
        pendingPhotoData = nil

        Task { await viewModel.uploadCapturedPhoto(photoData) }
    }
}

// MARK: - 사진 카드 더보기 메뉴

/// 사진 카드의 케밥 메뉴(신고하기 / 점심 사진 지우기) 표시 로직. 화면 본체와 관심사가 달라
/// 확장으로 분리했다.
private extension GroupDetailView {
    /// `momogoMenuOverlay`(DesignSystem)는 딤 위에 앵커 뷰의 "밝은 사본"을 다시 그려서, 원본은 딤 아래
    /// 그대로 두고 사본만 밝게 보이게 한다. 나비 버튼처럼 화면에 고정된 앵커 1개에서는 문제없지만,
    /// 스크롤 가능한 그리드 카드에 붙이면 원본과 사본의 위치가 미세하게 어긋나 배지가 두 개로
    /// 겹쳐 보이는 버그가 있었다(실측 확인됨). 사본을 아예 그리지 않고 메뉴만 앵커 위치에 띄우는
    /// 방식으로 바꿔 근본적으로 제거한다 — 대신 원본 배지는 다른 화면처럼 딤에 함께 어두워진다.
    ///
    /// 앵커는 호출부(`body`)의 `overlayPreferenceValue`에서 받아 넘긴다. 이 프로퍼티 안에서 직접
    /// `overlayPreferenceValue`를 부르면 수신자가 `GroupDetailView` 자신이 되어, 자기 오버레이 안에
    /// 자기를 다시 그리는 무한 재귀(진입 즉시 스택 오버플로)가 된다.
    @ViewBuilder
    func photoMenuOverlay(anchor: Anchor<CGRect>?) -> some View {
        if let anchor, let member = photoMenuTargetMember {
            ZStack(alignment: .topLeading) {
                Button {
                    withAnimation { photoMenuTargetId = nil }
                } label: {
                    DesignSystem.Color.black.opacity(0.4).ignoresSafeArea()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("메뉴 닫기")

                DSMenu(photoMenuItems(for: member))
                    .visualEffect { content, proxy in
                        let frame = proxy[anchor]
                        return content.offset(x: frame.maxX - DSMenu.defaultWidth, y: frame.maxY + 8)
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
            .accessibilityAddTraits(.isModal)
        }
    }

    var photoMenuTargetMember: GroupMember? {
        viewModel.members.first { $0.userId == photoMenuTargetId }
    }

    /// Figma 스펙(2342-29262): 내 사진이면 "점심 사진 지우기", 남의 사진이면 "신고하기" — 항목이
    /// 소유 여부로 완전히 갈리므로 한 카드에 두 항목이 동시에 뜨는 경우는 없다.
    func photoMenuItems(for member: GroupMember) -> [DSMenu.Item] {
        if member.isMine {
            [
                DSMenu.Item(constants.photoMenuDeleteTitle, icon: DesignSystemAsset.trash) {
                    photoMenuTargetId = nil
                    viewModel.deleteTapped(member)
                }
            ]
        } else {
            [
                DSMenu.Item(constants.photoMenuReportTitle, icon: DesignSystemAsset.warningTriangle) {
                    photoMenuTargetId = nil
                    viewModel.reportTapped(member)
                }
            ]
        }
    }

    func togglePhotoMenu(for member: GroupMember) {
        withAnimation {
            photoMenuTargetId = (photoMenuTargetId == member.userId) ? nil : member.userId
        }
    }
}
