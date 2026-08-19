import SwiftUI

import DesignSystem

/// '받은 리액션' 로그 목록. 아래가 최신인 채팅형 정렬이라 진입·리액션 추가 시 맨 아래로 붙는다.
/// 스크롤 위치에 따라 위/아래 Gradient를 노출하고(최하단=위만, 중앙=상하 모두, 최상단=아래만),
/// 오른쪽에는 Figma 스펙의 커스텀 스크롤바를 그린다(기본 인디케이터는 모양이 달라 숨긴다).
struct ReactionLogView: View {
    struct Constants {
        let rowSpacing: CGFloat = 6
        let leadingPadding: CGFloat = 8
        let columnSpacing: CGFloat = 8
        let gradientHeight: CGFloat = 20
        let bottomAnchorHeight: CGFloat = 0

        let scrollBarThumbWidth: CGFloat = 4
        let scrollBarPadding: CGFloat = 2
        let scrollBarMinThumbHeight: CGFloat = 24
        let scrollBarTrackOpacity: CGFloat = 0.04

        /// 부동소수 오차로 Gradient가 깜빡이지 않도록 두는 여유값.
        let edgeTolerance: CGFloat = 1

        let bottomAnchorId = "reaction-log-bottom"
        let coordinateSpaceName = "reaction-log-scroll"
    }

    private let constants = Constants()

    let entries: [ReactionLogEntry]

    @State private var viewportHeight: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0

    private var isScrollable: Bool {
        contentHeight - viewportHeight > constants.edgeTolerance
    }

    private var showsTopGradient: Bool {
        isScrollable && scrollOffset > constants.edgeTolerance
    }

    private var showsBottomGradient: Bool {
        isScrollable && scrollOffset < contentHeight - viewportHeight - constants.edgeTolerance
    }

    var body: some View {
        HStack(alignment: .top, spacing: constants.columnSpacing) {
            list
            scrollBar
        }
        .padding(.leading, constants.leadingPadding)
    }

    private var list: some View {
        GeometryReader { outer in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: constants.rowSpacing) {
                        ForEach(entries) { entry in
                            ReactionLogRow(entry: entry)
                        }

                        // 새 리액션이 붙었을 때 맨 아래로 스크롤하기 위한 앵커.
                        Color.clear
                            .frame(height: constants.bottomAnchorHeight)
                            .id(constants.bottomAnchorId)
                    }
                    // 로그가 짧을 때도 아래에 붙어 보이도록(Figma: justify-end) 최소 높이를 뷰포트로 맞춘다.
                    .frame(minHeight: outer.size.height, alignment: .bottom)
                    .background { metricsReader }
                }
                .coordinateSpace(.named(constants.coordinateSpaceName))
                .scrollIndicators(.hidden)
                .onAppear {
                    viewportHeight = outer.size.height
                    proxy.scrollTo(constants.bottomAnchorId, anchor: .bottom)
                }
                .onChange(of: outer.size.height) { _, newValue in
                    viewportHeight = newValue
                }
                .onChange(of: entries.count) { _, _ in
                    withAnimation { proxy.scrollTo(constants.bottomAnchorId, anchor: .bottom) }
                }
            }
        }
        .overlay(alignment: .top) {
            if showsTopGradient { gradient(from: .top, to: .bottom) }
        }
        .overlay(alignment: .bottom) {
            if showsBottomGradient { gradient(from: .bottom, to: .top) }
        }
    }

    /// 스크롤 오프셋·콘텐츠 높이를 읽는다. iOS 18의 `onScrollGeometryChange`를 쓸 수 없어(배포 타깃 17)
    /// 콘텐츠 배경의 `GeometryReader` + `onChange(initial:)`로 대체한다.
    private var metricsReader: some View {
        GeometryReader { inner in
            let offset = -inner.frame(in: .named(constants.coordinateSpaceName)).minY

            Color.clear
                .onChange(of: offset, initial: true) { _, newValue in
                    scrollOffset = newValue
                    contentHeight = inner.size.height
                }
        }
    }

    private func gradient(from startPoint: UnitPoint, to endPoint: UnitPoint) -> some View {
        LinearGradient(
            colors: [DesignSystem.Color.gray900, DesignSystem.Color.gray900.opacity(0)],
            startPoint: startPoint,
            endPoint: endPoint
        )
        .frame(height: constants.gradientHeight)
        .allowsHitTesting(false)
    }

    /// 스크롤 불가일 때도 폭(8pt)은 그대로 차지해, 리액션이 늘어날 때 로그 폭이 튀지 않게 한다.
    private var scrollBar: some View {
        GeometryReader { proxy in
            let trackHeight = proxy.size.height
            let thumbHeight = thumbHeight(inTrackHeight: trackHeight)

            Capsule()
                .fill(DesignSystem.Color.gray400)
                .frame(width: constants.scrollBarThumbWidth, height: thumbHeight)
                .offset(y: (trackHeight - thumbHeight) * progress)
        }
        .frame(width: constants.scrollBarThumbWidth)
        .background(
            DesignSystem.Color.white.opacity(constants.scrollBarTrackOpacity),
            in: Capsule()
        )
        .padding(constants.scrollBarPadding)
        .opacity(isScrollable ? 1 : 0)
        .allowsHitTesting(false)
    }

    private func thumbHeight(inTrackHeight trackHeight: CGFloat) -> CGFloat {
        guard contentHeight > 0 else { return constants.scrollBarMinThumbHeight }

        let ratio = min(max(viewportHeight / contentHeight, 0), 1)
        return max(constants.scrollBarMinThumbHeight, trackHeight * ratio)
    }

    private var progress: CGFloat {
        let maxOffset = contentHeight - viewportHeight
        guard maxOffset > 0 else { return 0 }

        return min(max(scrollOffset / maxOffset, 0), 1)
    }
}
