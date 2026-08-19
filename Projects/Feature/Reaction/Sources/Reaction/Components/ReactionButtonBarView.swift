import SwiftUI

import DesignSystem

/// 하단 반응 바. 왼쪽은 모드 선택(탭 시 모드 변경 바텀시트), 오른쪽은 이모지 4종이다.
/// 리액션할 수 없는 사진(내 사진 · 미업로드)에서는 Figma 스펙대로 바 전체가 Opacity 30%로 비활성된다.
struct ReactionButtonBarView: View {
    struct Constants {
        let barSpacing: CGFloat = 12
        let barPadding: CGFloat = 16
        let modeSpacing: CGFloat = 2
        let chevronSize: CGFloat = 18
        let dividerWidth: CGFloat = 1
        let dividerHeight: CGFloat = 26
        let emojiSpacing: CGFloat = 16
        let emojiSize: CGFloat = 40
        /// Figma 스펙: 40pt 이모지 4개 + 16pt 간격 3개 = 208pt 고정.
        let emojiRowWidth: CGFloat = 208
        let disabledOpacity: CGFloat = 0.3

        let modeAccessibilityLabel = "모드 변경"
    }

    private let constants = Constants()

    let modeTitle: String
    let isEnabled: Bool
    let onTapMode: () -> Void
    let onTapEmoji: (ReactionEmoji) -> Void

    var body: some View {
        HStack(spacing: constants.barSpacing) {
            modeButton

            DesignSystem.Color.gray700
                .frame(width: constants.dividerWidth, height: constants.dividerHeight)

            emojiRow
        }
        .padding(constants.barPadding)
        .frame(maxWidth: .infinity)
        .background(
            DesignSystem.Color.gray800,
            in: RoundedRectangle(cornerRadius: DesignSystem.Radius.r12)
        )
        .opacity(isEnabled ? 1 : constants.disabledOpacity)
        .disabled(!isEnabled)
    }

    private var modeButton: some View {
        Button(action: onTapMode) {
            HStack(spacing: constants.modeSpacing) {
                Text(modeTitle)
                    .momogoTypography(.smMedium)
                    .foregroundStyle(DesignSystem.Color.white)
                    .fixedSize()

                Image(asset: DesignSystemAsset.chevronDown)
                    .resizable()
                    .scaledToFit()
                    .frame(width: constants.chevronSize, height: constants.chevronSize)
                    .foregroundStyle(DesignSystem.Color.white)
            }
        }
        .accessibilityLabel(constants.modeAccessibilityLabel)
    }

    private var emojiRow: some View {
        HStack(spacing: constants.emojiSpacing) {
            ForEach(ReactionEmoji.allCases) { emoji in
                Button {
                    onTapEmoji(emoji)
                } label: {
                    ReactionEmojiBadge(emoji: emoji, size: constants.emojiSize)
                }
                .accessibilityLabel(emoji.accessibilityLabel)
            }
        }
        .frame(width: constants.emojiRowWidth)
    }
}
