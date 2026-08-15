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

    /// 남의 사진에만 신고 메뉴를 노출한다. 내 사진의 삭제 메뉴는 디자인이 나오면 추가한다.
    private var showsMenuButton: Bool {
        member.photo != nil && !member.isMine
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
                .overlay(alignment: .topTrailing) {
                    if showsMenuButton {
                        menuButton
                    }
                }
                // 그라디언트·배지가 사진과 함께 회전해야 하므로(Figma에서 한 그룹으로 묶여 같이 기운다),
                // 두 오버레이를 얹은 뒤에 clipShape·rotationEffect를 적용한다.
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r12))
                .rotationEffect(.degrees(rotationDegrees))

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
