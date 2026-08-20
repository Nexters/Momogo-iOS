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
        /// 케밥 배지(항상 우상단)와 반응 태그가 같은 코너로 배정됐을 때만 그 아래로 쌓기 위한
        /// 상단 여백. menuButtonPadding(8) + PhotoMenuBadge 지름(20) + 배지-태그 간격(8) = 36.
        /// (±2° 회전에 따른 좌표 오차는 8pt 간격이면 무시할 수준이라 감수한다.)
        let reactionTagTopTrailingPadding: CGFloat = 36
        /// 우상단을 제외한 나머지 3개 코너(좌상단/좌하단/우하단)에 쓰는 기본 여백 — 케밥 배지
        /// 자체 여백(menuButtonPadding)과 통일해 시각적으로 어색하지 않게 맞춘다.
        let reactionTagEdgePadding: CGFloat = 8

        let cameraAccessibilityLabel = "카메라로 촬영하기"
        let photoAccessibilityLabel = "반응 남기기"
    }

    private let constants = Constants()

    let member: GroupMember
    /// 이 카드(멤버 사진)에 남겨진 반응 중 화면에 노출할 하나. 코멘트가 빈 문자열이면 태그를 띄우지 않는다.
    let reaction: PhotoReaction?
    /// 반응 태그가 놓일 코너를 카드마다 랜덤으로 고른다("재밌을 것 같다"는 사용자 요청).
    /// 카드 identity(멤버)가 유지되는 동안은 값이 고정돼, 메뉴 토글 등 리렌더에서 위치가 튀지 않는다.
    @State private var reactionTagCorner = ReactionTagCorner.allCases.randomElement() ?? .topTrailing
    /// Figma 스펙: 카드가 (row+col) 짝/홀에 따라 ±2도씩 번갈아 기울어져 폴라로이드처럼 보인다.
    let rotationDegrees: Double
    /// 이 카드의 더보기 메뉴가 현재 열려 있는지. 열려 있을 때만 이 카드의 배지에 `.dsMenuAnchor()`를
    /// 붙여야, 여러 카드가 동시에 존재해도 메뉴가 정확히 이 카드 위치에 뜬다(GroupDetailView 참고).
    let isMenuAnchor: Bool
    /// 더보기 배지 탭 콜백. 신고 대상이 아닌(내 사진이거나 사진이 없는) 카드에서는 배지 자체가 노출되지 않는다.
    let onTapMenu: () -> Void
    /// 내 카드인데 아직 사진이 없을 때 카메라 아이콘 탭 콜백. 남의 빈 카드(zzz 아이콘)에는 쓰이지 않는다.
    let onTapCamera: () -> Void
    /// 사진이 있는 카드의 사진 영역 탭 콜백. 이 멤버의 사진부터 시작하는 반응 화면으로 이동한다.
    let onTapPhoto: () -> Void

    /// 사진이 있는 카드에만 더보기 배지를 노출한다: 남의 사진이면 신고, 내 사진이면 삭제.
    private var showsMenuButton: Bool {
        member.photo != nil
    }

    /// 카메라 placeholder 카드(내 카드 + 사진 없음)만 이미지 영역이 아니라 카드 전체(이미지+닉네임)를
    /// 터치 가능하게 한다(Figma "그룹상세_기본" 스펙). Button 중첩을 피하려고 `imageContent`
    /// 내부의 Button은 제거하고 이 바깥 Button 하나로만 감싼다.
    var body: some View {
        if member.isMine, member.photo == nil {
            Button(action: onTapCamera) {
                cardContent
            }
            .buttonStyle(.plain)
            .accessibilityLabel(constants.cameraAccessibilityLabel)
        } else {
            cardContent
        }
    }

    private var cardContent: some View {
        VStack(spacing: constants.contentSpacing) {
            imageContent
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .top) {
                    if showsMenuButton {
                        menuGradientOverlay
                    }
                }
                .overlay(alignment: reactionTagCorner.alignment) {
                    if let reaction, !reaction.comment.isEmpty {
                        PhotoReactionTag(icon: reaction.emoji.icon, comment: reaction.comment)
                            .padding(reactionTagPadding)
                    }
                }
                // 그라디언트·반응 태그는 사진과 함께 회전해야 하므로(Figma에서 한 그룹으로 묶여 같이 기운다)
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

    /// 코너별 여백. 우상단만 케밥 배지 아래로 쌓기 위한 특수 상단 여백을 쓰고, 나머지 3개
    /// 코너는 케밥 배지와 겹치지 않아 균일한 기본 여백만 적용한다.
    private var reactionTagPadding: EdgeInsets {
        switch reactionTagCorner {
        case .topLeading:
            EdgeInsets(
                top: constants.reactionTagEdgePadding, leading: constants.reactionTagEdgePadding, bottom: 0, trailing: 0
            )
        case .topTrailing:
            EdgeInsets(
                top: constants.reactionTagTopTrailingPadding, leading: 0, bottom: 0,
                trailing: constants.reactionTagEdgePadding
            )
        case .bottomLeading:
            EdgeInsets(
                top: 0, leading: constants.reactionTagEdgePadding, bottom: constants.reactionTagEdgePadding, trailing: 0
            )
        case .bottomTrailing:
            EdgeInsets(
                top: 0, leading: 0, bottom: constants.reactionTagEdgePadding, trailing: constants.reactionTagEdgePadding
            )
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
        // downloadUrl은 presigned URL이라 조회할 때마다 서명이 바뀐다. KFImage(url)처럼 URL
        // 문자열을 그대로 캐시 키로 쓰면 재방문할 때마다 캐시 미스가 나 매번 재다운로드하므로,
        // 캐시 키를 photoId로 고정해야 실제로 "재요청 없이 즉시 표시"된다(RemotePhotoSource 참고).
        if let photo = member.photo, let url = URL(string: photo.downloadUrl) {
            // 사진 영역 전체가 반응 화면 진입 버튼이다. 우상단 더보기 배지는 이 뒤에 overlay로
            // 얹히므로 배지 탭이 이 버튼에 먹히지 않는다.
            Button(action: onTapPhoto) {
                KFImage(source: RemotePhotoSource.make(photoId: photo.photoId, downloadURL: url))
                    .resizable()
                    .fade(duration: 0.2)
                    .placeholder { placeholder }
                    .scaledToFill()
            }
            .buttonStyle(.plain)
            .accessibilityLabel(constants.photoAccessibilityLabel)
        } else if member.isMine {
            // 카드 전체(이미지+닉네임)를 감싸는 Button이 body에 있으므로 여기서는 중첩 Button 없이
            // placeholder만 반환한다.
            placeholder
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

/// 반응 태그가 놓일 코너. 케밥 배지가 항상 우상단을 차지하므로, 우상단으로 뽑혔을 때만
/// `GroupPhotoCardView.reactionTagPadding`이 그 아래로 쌓는 특수 여백을 쓴다.
private enum ReactionTagCorner: CaseIterable {
    case topLeading, topTrailing, bottomLeading, bottomTrailing

    var alignment: Alignment {
        switch self {
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        case .bottomLeading: .bottomLeading
        case .bottomTrailing: .bottomTrailing
        }
    }
}

extension CommentEmoji {
    /// FeatureReaction이 쓰는 `illust-imoji-*` 에셋(Figma `Illust_Imoji` 4종)을 그대로 재사용한다.
    /// Domain은 DesignSystem을 모르므로 이 매핑은 Feature에 둔다.
    var icon: DesignSystemImages {
        switch self {
        case .delicious: DesignSystemAsset.illustImojiDrool
        case .hot: DesignSystemAsset.illustImojiHot
        case .flex: DesignSystemAsset.illustImojiMoney
        case .hmm: DesignSystemAsset.illustImojiThinking
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
