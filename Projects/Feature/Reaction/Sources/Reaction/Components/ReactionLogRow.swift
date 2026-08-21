import SwiftUI

import DesignSystem

/// 로그 한 줄(Figma `TagL`): 왼쪽 고정폭 닉네임 + 이모지·코멘트 태그. 코멘트가 길면 태그가 남은
/// 폭까지 늘어나며 두 줄로 감긴다(Variant2).
struct ReactionLogRow: View {
    struct Constants {
        let rowSpacing: CGFloat = 8
        let nameWidth: CGFloat = 72
        let nameVerticalPadding: CGFloat = 6
        let nameLineLimit = 1

        let tagSpacing: CGFloat = 6
        let tagHorizontalPadding: CGFloat = 10
        let tagVerticalPadding: CGFloat = 6
        let tagBackgroundOpacity: CGFloat = 0.08

        let emojiSize: CGFloat = 18
    }

    private let constants = Constants()

    let entry: ReactionLogEntry

    var body: some View {
        HStack(alignment: .top, spacing: constants.rowSpacing) {
            Text(entry.displayName)
                .momogoTypography(.smSemistrong)
                .foregroundStyle(entry.isMine ? DesignSystem.Color.white : DesignSystem.Color.gray300)
                .lineLimit(constants.nameLineLimit)
                .frame(width: constants.nameWidth, alignment: .leading)
                .padding(.vertical, constants.nameVerticalPadding)

            tag

            Spacer(minLength: 0)
        }
    }

    private var tag: some View {
        // Figma 태그는 `items-center` — 이모지와 코멘트를 세로 중앙으로 맞춘다. 위 정렬로 두면
        // 이모지(18pt)와 텍스트(약 18pt)의 높이 차만큼 코멘트가 위로 떠 보인다.
        HStack(spacing: constants.tagSpacing) {
            ReactionEmojiBadge(emoji: entry.emoji, size: constants.emojiSize)
                .accessibilityLabel(entry.emoji.accessibilityLabel)

            Text(entry.comment)
                .momogoMultilineTypography(.smSemistrong)
                .foregroundStyle(DesignSystem.Color.gray50)
        }
        .padding(.horizontal, constants.tagHorizontalPadding)
        .padding(.vertical, constants.tagVerticalPadding)
        .background(DesignSystem.Color.white.opacity(constants.tagBackgroundOpacity), in: Capsule())
    }
}
