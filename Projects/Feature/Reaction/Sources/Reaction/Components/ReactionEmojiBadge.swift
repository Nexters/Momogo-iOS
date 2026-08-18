import SwiftUI

import DesignSystem

/// 이모지 일러스트 배지. Figma `Illust_Imoji`는 40pt gray50 원 안에 35pt 얼굴 아트가 2.5pt 인셋으로
/// 들어가는 구조이고, 에셋은 그 35pt 아트만 담고 있어 같은 비율로 축소해 원 위에 올린다.
struct ReactionEmojiBadge: View {
    struct Constants {
        /// Figma 스펙: 배지 40pt 대비 아트 35pt.
        let artRatio: CGFloat = 35.0 / 40.0
    }

    private let constants = Constants()

    let emoji: ReactionEmoji
    let size: CGFloat

    var body: some View {
        Image(asset: emoji.asset)
            .resizable()
            .scaledToFit()
            .frame(width: size * constants.artRatio, height: size * constants.artRatio)
            .frame(width: size, height: size)
            .background(DesignSystem.Color.gray50, in: Circle())
    }
}
