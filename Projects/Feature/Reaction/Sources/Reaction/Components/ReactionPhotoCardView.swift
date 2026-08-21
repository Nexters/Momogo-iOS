import SwiftUI

import DesignSystem
import Kingfisher

/// 가로 페이저 카드 1장. 위쪽은 정사각형 사진(업로더 이름 칩 · 미트볼 · 촬영 날짜),
/// 아래쪽은 '받은 리액션' 로그다.
struct ReactionPhotoCardView: View {
    struct Constants {
        let cardPadding: CGFloat = 8
        let contentSpacing: CGFloat = 12
        let overlayPadding: CGFloat = 8
        let borderLineWidth: CGFloat = 1

        let chipHorizontalPadding: CGFloat = 12
        let chipVerticalPadding: CGFloat = 6
        let chipBackgroundOpacity: CGFloat = 0.16
        let chipBorderOpacity: CGFloat = 0.08

        let dateHorizontalPadding: CGFloat = 16
        let dateVerticalPadding: CGFloat = 14
        let dateGradientOpacity: CGFloat = 0.4

        let placeholderIconSize: CGFloat = 56
        let imageFadeDuration: Double = 0.2

        let logSpacing: CGFloat = 8
        let logHeaderSpacing: CGFloat = 4
        let logHeaderHorizontalPadding: CGFloat = 8
        let logHeaderVerticalPadding: CGFloat = 2

        let logTitle = "받은 리액션"
        let menuAccessibilityLabel = "더보기"
    }

    private let constants = Constants()

    let item: ReactionPhotoItem
    let dateText: String
    /// 이 카드의 미트볼 메뉴가 열려 있는지. 열려 있을 때만 `.dsMenuAnchor()`를 붙인다(ReactionView 참고).
    let isMenuAnchor: Bool
    let onTapMenu: () -> Void

    var body: some View {
        // 사진은 "카드 폭 - 좌우 패딩"을 한 변으로 하는 정사각형이다. `aspectRatio(1, contentMode: .fit)`은
        // 제안된 크기 안에 맞추는 방식이라, 사진과 로그가 같은 VStack의 flexible 자식으로 높이를 나눠
        // 제안받으면 정사각형이 폭이 아니라 그 높이에 갇혀 작아진다. 그래서 카드 폭을 직접 재서
        // 한 변을 고정한다 — 사진이 inflexible해지므로 남는 높이는 전부 로그가 받는다.
        GeometryReader { proxy in
            content(photoSide: max(0, proxy.size.width - constants.cardPadding * 2))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            DesignSystem.Color.gray900,
            in: RoundedRectangle(cornerRadius: DesignSystem.Radius.r16)
        )
    }

    private func content(photoSide: CGFloat) -> some View {
        VStack(spacing: constants.contentSpacing) {
            photo(side: photoSide)
            log
        }
        .padding(constants.cardPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func photo(side: CGFloat) -> some View {
        photoContent
            .frame(width: side, height: side)
            .overlay(alignment: .bottom) {
                if item.hasPhoto { dateOverlay }
            }
            .overlay(alignment: .top) { topOverlay }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r16))
    }

    @ViewBuilder
    private var photoContent: some View {
        if let photo = item.member.photo, let url = URL(string: photo.downloadUrl) {
            // presigned URL은 조회할 때마다 서명이 바뀌어, 캐시 키를 photoId로 고정해야 그룹상세에서
            // 이미 캐싱된 사진을 네트워크 재요청 없이 즉시 표시한다(RemotePhotoSource 참고).
            KFImage(source: RemotePhotoSource.make(photoId: photo.photoId, downloadURL: url))
                .resizable()
                .fade(duration: constants.imageFadeDuration)
                .placeholder { placeholder }
                .scaledToFill()
        } else {
            placeholder
        }
    }

    /// 아직 사진이 올라오지 않은 카드. 내 카드는 카메라, 남의 카드는 zzz 아이콘을 보여준다
    /// (그룹상세 카드와 동일 규칙).
    private var placeholder: some View {
        DesignSystem.Color.gray800
            .overlay {
                Image(asset: item.member.isMine ? DesignSystemAsset.cameraFill : DesignSystemAsset.iconZzz)
                    .resizable()
                    .scaledToFit()
                    .frame(width: constants.placeholderIconSize, height: constants.placeholderIconSize)
                    .foregroundStyle(DesignSystem.Color.gray700)
            }
    }

    private var topOverlay: some View {
        HStack(alignment: .top, spacing: 0) {
            titleChip
            Spacer(minLength: 0)
            if item.showsMenu { menuButton }
        }
        .padding(constants.overlayPadding)
    }

    private var titleChip: some View {
        Text(item.title)
            .momogoTypography(.smSemistrong)
            .foregroundStyle(DesignSystem.Color.white)
            .padding(.horizontal, constants.chipHorizontalPadding)
            .padding(.vertical, constants.chipVerticalPadding)
            .background(DesignSystem.Color.white.opacity(constants.chipBackgroundOpacity), in: Capsule())
            .overlay {
                Capsule().strokeBorder(
                    DesignSystem.Color.white.opacity(constants.chipBorderOpacity),
                    lineWidth: constants.borderLineWidth
                )
            }
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
            ReactionMenuBadge()
        }
        .accessibilityLabel(constants.menuAccessibilityLabel)
    }

    private var dateOverlay: some View {
        Text(dateText)
            .momogoTypography(.smSemistrong)
            .foregroundStyle(DesignSystem.Color.gray50)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, constants.dateHorizontalPadding)
            .padding(.vertical, constants.dateVerticalPadding)
            .background(
                LinearGradient(
                    colors: [
                        DesignSystem.Color.black.opacity(0),
                        DesignSystem.Color.black.opacity(constants.dateGradientOpacity)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .allowsHitTesting(false)
    }

    private var log: some View {
        VStack(alignment: .leading, spacing: constants.logSpacing) {
            logHeader

            if item.reactions.isEmpty {
                emptyMessage
            } else {
                ReactionLogView(entries: item.reactions)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var logHeader: some View {
        HStack(spacing: constants.logHeaderSpacing) {
            Text(constants.logTitle)
                .momogoTypography(.smSemistrong)
                .foregroundStyle(DesignSystem.Color.gray50)
            Text("\(item.reactions.count)")
                .momogoTypography(.smMedium)
                .foregroundStyle(DesignSystem.Color.primary400)
        }
        .padding(.horizontal, constants.logHeaderHorizontalPadding)
        .padding(.vertical, constants.logHeaderVerticalPadding)
    }

    private var emptyMessage: some View {
        Text(item.emptyMessage)
            .momogoMultilineTypography(.smMedium)
            .foregroundStyle(DesignSystem.Color.gray300)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 사진 우상단 미트볼 배지(Figma `floating menu1l`). 그룹상세의 `PhotoMenuBadge`와 달리
/// 32pt 반투명 원형 + 테두리 + 그림자 스펙이라 별도 뷰로 둔다.
struct ReactionMenuBadge: View {
    struct Constants {
        let size: CGFloat = 32
        let iconSize: CGFloat = 20
        let backgroundOpacity: CGFloat = 0.5
        let borderOpacity: CGFloat = 0.08
        let borderLineWidth: CGFloat = 1
        let shadowOpacity: CGFloat = 0.2
        let shadowRadius: CGFloat = 4
        let shadowY: CGFloat = 4
    }

    private let constants = Constants()

    var body: some View {
        Image(asset: DesignSystemAsset.ellipsisVertical)
            .resizable()
            .scaledToFit()
            .frame(width: constants.iconSize, height: constants.iconSize)
            .foregroundStyle(DesignSystem.Color.white)
            .frame(width: constants.size, height: constants.size)
            .background(DesignSystem.Color.gray800.opacity(constants.backgroundOpacity), in: Circle())
            .overlay {
                Circle().strokeBorder(
                    DesignSystem.Color.white.opacity(constants.borderOpacity),
                    lineWidth: constants.borderLineWidth
                )
            }
            .shadow(
                color: DesignSystem.Color.black.opacity(constants.shadowOpacity),
                radius: constants.shadowRadius,
                x: 0,
                y: constants.shadowY
            )
    }
}
