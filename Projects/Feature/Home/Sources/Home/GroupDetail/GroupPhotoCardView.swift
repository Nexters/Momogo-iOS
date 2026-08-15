import SwiftUI

import DesignSystem
import DomainInterface
import Kingfisher

/// 그룹상세 2단 그리드의 카드 1개.
struct GroupPhotoCardView: View {
    struct Constants {
        let nameRowSpacing: CGFloat = 2
        let nameArrowIconSize: CGFloat = 24
        let placeholderIconSize: CGFloat = 40
        let placeholderIconOpacity: CGFloat = 0.4
        let borderOpacity: CGFloat = 0.04
        let borderLineWidth: CGFloat = 4
        let contentSpacing: CGFloat = 6
        /// Figma 스펙(케밥메뉴): 사진 위쪽에 깔리는 어두운 그라디언트 띠 높이.
        let menuGradientHeight: CGFloat = 42
        let menuButtonPadding: CGFloat = 8
    }

    private let constants = Constants()

    let member: GroupMember
    /// Figma 스펙: 카드가 (row+col) 짝/홀에 따라 ±2도씩 번갈아 기울어져 폴라로이드처럼 보인다.
    let rotationDegrees: Double
    /// 이 카드의 더보기 메뉴가 현재 열려 있는지. 열려 있을 때만 이 카드의 배지에 `.dsMenuAnchor()`를
    /// 붙여야, 여러 카드가 동시에 존재해도 메뉴가 정확히 이 카드 위치에 뜬다(GroupDetailView 참고).
    let isMenuAnchor: Bool
    /// 더보기 배지 탭 콜백. 신고 대상이 아닌(내 사진이거나 사진이 없는) 카드에서는 배지 자체가 노출되지 않는다.
    let onTapMenu: () -> Void

    /// 사진이 있는 카드에만 더보기 배지를 노출한다: 남의 사진이면 신고, 내 사진이면 삭제.
    private var showsMenuButton: Bool {
        member.photo != nil
    }

    var body: some View {
        VStack(spacing: constants.contentSpacing) {
            imageContent
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .top) {
                    if showsMenuButton {
                        menuGradientOverlay
                    }
                }
                // 그라디언트는 사진과 함께 회전해야 하므로(Figma에서 한 그룹으로 묶여 같이 기운다)
                // clipShape·rotationEffect 이전에 얹는다.
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r12))
                .rotationEffect(.degrees(rotationDegrees))
                // 배지는 반대로 회전 *이후*에 얹는다 — `.dsMenuAnchor()`가 캡처하는 좌표는 회전이 반영되지
                // 않는 레이아웃 프레임이라, 회전된 뷰 안쪽에 배지를 두면 실제 렌더링 위치와 앵커가 어긋나
                // `momogoMenuOverlay`가 딤 위에 다시 그리는 "밝은 사본"이 원본과 미세하게 안 맞아
                // 배지가 두 개 겹쳐 보이는 버그가 있었다(실측 확인됨).
                .overlay(alignment: .topTrailing) {
                    if showsMenuButton {
                        menuButton
                    }
                }

            HStack(spacing: constants.nameRowSpacing) {
                Image(asset: DesignSystemAsset.arrowCornerDownLeft)
                    .resizable()
                    .scaledToFit()
                    .frame(width: constants.nameArrowIconSize, height: constants.nameArrowIconSize)
                    .foregroundStyle(DesignSystem.Color.gray600)
                Text(member.nickname)
                    .momogoTypography(.smSemistrong)
                    .foregroundStyle(DesignSystem.Color.gray50)
            }
        }
    }

    private var menuGradientOverlay: some View {
        LinearGradient(
            colors: [Color.black.opacity(0.3), Color.black.opacity(0)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: constants.menuGradientHeight)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var menuButton: some View {
        if isMenuAnchor {
            rawMenuButton.dsMenuAnchor()
        } else {
            rawMenuButton
        }
    }

    private var rawMenuButton: some View {
        Button(action: onTapMenu) {
            PhotoMenuBadge()
        }
        .padding(constants.menuButtonPadding)
    }

    @ViewBuilder
    private var imageContent: some View {
        // KFImage는 기본으로 메모리+디스크에 자동 캐싱한다(재방문/재실행 시 네트워크 재요청 없이 즉시 표시).
        if let photo = member.photo, let url = URL(string: photo.downloadUrl) {
            KFImage(url)
                .resizable()
                .fade(duration: 0.2)
                .placeholder { placeholder }
                .scaledToFill()
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: DesignSystem.Radius.r12)
            .fill(DesignSystem.Color.gray900)
            .overlay {
                Image(asset: member.isMine ? DesignSystemAsset.cameraFill : DesignSystemAsset.iconZzz)
                    .resizable()
                    .scaledToFit()
                    .frame(width: constants.placeholderIconSize, height: constants.placeholderIconSize)
                    .foregroundStyle(DesignSystem.Color.gray50.opacity(constants.placeholderIconOpacity))
            }
            // 사진이 있는 카드에는 이 테두리가 없다 — placeholder(사진 없음)에만 적용한다.
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.Radius.r12)
                    .strokeBorder(Color.white.opacity(constants.borderOpacity), lineWidth: constants.borderLineWidth)
            }
    }
}

/// 사진 카드 우상단 케밥(⋯) 배지. `momogoMenuOverlay`가 딤 위에 다시 그리는 "밝은 사본"에도
/// 그대로 재사용해 시각적으로 동일하게 맞춘다(GroupDetailView 참고).
struct PhotoMenuBadge: View {
    struct Constants {
        let iconSize: CGFloat = 16
        let padding: CGFloat = 2
        let backgroundOpacity: CGFloat = 0.16
    }

    private let constants = Constants()

    var body: some View {
        Image(asset: DesignSystemAsset.ellipsis)
            .resizable()
            .frame(width: constants.iconSize, height: constants.iconSize)
            .foregroundStyle(DesignSystem.Color.white)
            .padding(constants.padding)
            .background(Color.white.opacity(constants.backgroundOpacity), in: Circle())
    }
}
