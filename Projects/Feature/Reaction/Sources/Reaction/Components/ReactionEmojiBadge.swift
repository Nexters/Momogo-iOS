import SwiftUI

import DesignSystem

/// 이모지 일러스트 배지. Figma `Illust_Imoji`(node 2107:50265, "Button Bar_iOS")가 gray50 원형
/// 배경 없이 40pt 아트를 그대로 노출하는 구조로 바뀌어, 에셋을 배지 크기에 꽉 채워 그린다.
struct ReactionEmojiBadge: View {
    let emoji: ReactionEmoji
    let size: CGFloat

    var body: some View {
        Image(asset: emoji.asset)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}
