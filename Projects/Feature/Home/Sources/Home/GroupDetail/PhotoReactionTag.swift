import SwiftUI

import DesignSystem

/// 그룹상세 사진 카드 위에 겹쳐 남긴 반응(이모지 일러스트 + 짧은 코멘트)을 보여주는 태그.
/// Figma 스펙(Tag_S): 배경 gray800, 좌 4·우 8·상하 4 비대칭 패딩, 아이콘-텍스트 간격 4,
/// radius 20(높이 28이라 사실상 캡슐). 너비는 `commentMaxWidth`까지는 콘텐츠 길이에 맞춰
/// hug하고, 넘으면 좌→우 무한 마퀴로 스크롤한다(`MarqueeCommentText`).
struct PhotoReactionTag: View {
    struct Constants {
        let spacing: CGFloat = 4
        let leadingPadding: CGFloat = 4
        let trailingPadding: CGFloat = 8
        let verticalPadding: CGFloat = 4
        let iconSize: CGFloat = 20
        /// 코멘트 영역 최대 폭. Figma Tag_S 태그 전체 최대폭(131, 실측 스펙)에서
        /// 아이콘(20)+좌4+간격4+우8=36을 뺀 값.
        let commentMaxWidth: CGFloat = 95
        /// 마퀴 반복 시 기존 텍스트와 다음 텍스트 사이 간격(스펙 명시값).
        let marqueeGap: CGFloat = 32
        /// 정지 상태 유지 시간(스펙 명시값: 진입 후 2초, 새 텍스트 진입 후 2초).
        let marqueePauseDuration: Double = 2
        /// 스크롤 속도(px/초). 스펙에 명시되지 않아 임의로 정한 값 — 체감 확인 후 조정 필요.
        let marqueeScrollSpeed: CGFloat = 40
        /// 가장자리 페이드 폭. 스펙에 명시되지 않아 임의로 정한 값.
        let edgeGradientWidth: CGFloat = 16
    }

    private let constants = Constants()

    let icon: DesignSystemImages
    let comment: String

    /// 코멘트의 제약 없는(hug) 폭. 측정되기 전(nil)에는 일단 hug로 렌더링한다.
    @State private var textWidth: CGFloat?

    var body: some View {
        HStack(spacing: constants.spacing) {
            Image(asset: icon)
                .resizable()
                .frame(width: constants.iconSize, height: constants.iconSize)
            commentContent
        }
        .padding(.leading, constants.leadingPadding)
        .padding(.trailing, constants.trailingPadding)
        .padding(.vertical, constants.verticalPadding)
        .background(DesignSystem.Color.gray800)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r20))
        // 상위(.overlay)가 제안하는 넓은 폭을 무시하고 "이상적 크기"로 레이아웃되게 해,
        // commentMaxWidth가 고정폭이 아니라 상한으로만 동작하게 한다(짧은 코멘트는 hug 유지).
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    private var commentContent: some View {
        if let textWidth, textWidth > constants.commentMaxWidth {
            MarqueeCommentText(comment: comment, textWidth: textWidth, constants: constants)
        } else {
            plainText
                .background {
                    GeometryReader { proxy in
                        Color.clear.preference(key: TextWidthPreferenceKey.self, value: proxy.size.width)
                    }
                }
                .onPreferenceChange(TextWidthPreferenceKey.self) { textWidth = $0 }
        }
    }

    private var plainText: some View {
        Text(comment)
            .momogoTypography(.smSemistrong)
            .foregroundStyle(DesignSystem.Color.white)
            .lineLimit(1)
            .fixedSize()
    }
}

/// `.background { GeometryReader }` 형태로만 쓴다 — `ZStack` 형제로 `GeometryReader`를 두면
/// 다른 형제 렌더링이 멈추는 버그가 실측된 바 있다(`DSMenu.swift` 참고).
private struct TextWidthPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// 코멘트가 `commentMaxWidth`를 넘을 때 좌→우로 무한 반복 스크롤하는 마퀴.
/// 텍스트를 두 벌 나란히 두고 `textWidth + gap`만큼만 이동시키는 표준 seamless 기법 —
/// 한 바퀴를 돌면 두 번째 사본이 정확히 첫 번째의 시작 위치에 오므로, 애니메이션 없이
/// 순간적으로 offset을 0으로 되돌려도 시각적으로 끊김이 없다.
private struct MarqueeCommentText: View {
    let comment: String
    let textWidth: CGFloat
    let constants: PhotoReactionTag.Constants

    @State private var isScrolling = false

    var body: some View {
        HStack(spacing: constants.marqueeGap) {
            textView
            textView
        }
        .offset(x: isScrolling ? -(textWidth + constants.marqueeGap) : 0)
        .frame(width: constants.commentMaxWidth, alignment: .leading)
        .clipped()
        .overlay(edgeGradient)
        .task { await runLoop() }
    }

    private var textView: some View {
        Text(comment)
            .momogoTypography(.smSemistrong)
            .foregroundStyle(DesignSystem.Color.white)
            .lineLimit(1)
            .fixedSize()
    }

    private func runLoop() async {
        while !Task.isCancelled {
            isScrolling = false
            try? await Task.sleep(for: .seconds(constants.marqueePauseDuration))
            guard !Task.isCancelled else { return }

            let duration = Double((textWidth + constants.marqueeGap) / constants.marqueeScrollSpeed)
            withAnimation(.linear(duration: duration)) { isScrolling = true }
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }

            // 정확히 한 바퀴(textWidth+gap) 돌아 offset 0과 시각적으로 동일한 상태이므로,
            // 애니메이션 없이 순간 리셋한다.
            isScrolling = false
        }
    }

    @ViewBuilder
    private var edgeGradient: some View {
        HStack(spacing: 0) {
            if isScrolling {
                LinearGradient(
                    colors: [DesignSystem.Color.gray800, DesignSystem.Color.gray800.opacity(0)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: constants.edgeGradientWidth)
                // 좌측 그라디언트는 offset과 같은 withAnimation(트랜잭션) 안에서 나타나고 사라지므로,
                // 기본 .opacity 삽입/제거 트랜지션을 그대로 두면 스크롤 내내 서서히 페이드 인했다가
                // 도착 직전 가장 진해진 채로 사라져 깜빡이듯 보인다(실측). 오프셋 애니메이션과 무관하게
                // 스크롤 시작/끝 순간에 즉시 켜지고 꺼지도록 트랜지션 자체를 없앤다.
                .transition(.identity)
            }
            Spacer(minLength: 0)
            LinearGradient(
                colors: [DesignSystem.Color.gray800.opacity(0), DesignSystem.Color.gray800],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: constants.edgeGradientWidth)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        PhotoReactionTag(icon: DesignSystemAsset.reactionDelicious, comment: "짧은 코멘트")
        PhotoReactionTag(icon: DesignSystemAsset.reactionHot, comment: "매워보여")
        PhotoReactionTag(icon: DesignSystemAsset.reactionFlex, comment: "짧은 코멘트")
        PhotoReactionTag(icon: DesignSystemAsset.reactionHmm, comment: "길게 쓴 코멘트는 이렇게 흘러요")
            .frame(width: 164, alignment: .trailing)
    }
    .padding()
    .background(DesignSystem.Color.gray950)
}
