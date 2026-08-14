import SwiftUI

import DesignSystem
import DomainInterface

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
    }

    private let constants = Constants()

    let member: GroupMember
    /// Figma 스펙: 카드가 (row+col) 짝/홀에 따라 ±2도씩 번갈아 기울어져 폴라로이드처럼 보인다.
    let rotationDegrees: Double

    var body: some View {
        VStack(spacing: constants.contentSpacing) {
            imageContent
                .aspectRatio(1, contentMode: .fit)
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

    @ViewBuilder
    private var imageContent: some View {
        if let photo = member.photo, let url = URL(string: photo.downloadUrl) {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    placeholder
                }
            }
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
