import SwiftUI

public struct DSMenu: View {
    public struct Item {
        let title: String
        let icon: DesignSystemImages
        let action: () -> Void

        public init(_ title: String, icon: DesignSystemImages, action: @escaping () -> Void) {
            self.title = title
            self.icon = icon
            self.action = action
        }
    }

    /// Figma 스펙상 메뉴는 내용에 맞춰 늘어나지 않고 158pt로 고정된다(항목 내부가 컨테이너 폭을 채우는 구조).
    public static let defaultWidth: CGFloat = 158

    private let items: [Item]
    private let width: CGFloat

    public init(_ items: [Item], width: CGFloat = DSMenu.defaultWidth) {
        self.items = items
        self.width = width
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(items.enumerated(), id: \.offset) { index, item in
                button(item)

                if index < items.count - 1 {
                    DesignSystem.Color.gray800
                        .frame(height: 1)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        // `width`는 Figma 스펙상 패딩을 포함한 컨테이너 전체 폭이다. 패딩 앞에 frame을 걸면
        // 내부 VStack만 158이 되고 패딩이 그 바깥에 더해져 실제 폭이 182로 부풀어, 오버레이가
        // trailing 정렬을 계산할 때 기준으로 삼는 `DSMenu.defaultWidth`와 어긋난다.
        .frame(width: width)
        .background {
            RoundedRectangle(cornerRadius: DesignSystem.Radius.r16)
                .fill(DesignSystem.Color.gray900)
                .stroke(DesignSystem.Color.gray700, lineWidth: 1)
        }
        // Figma "Floating Blur"(0 4px 4px / 검정 20%) 근사. 공용 `momogoShadow()`는 radius 32 · 32%로
        // 이 스펙보다 훨씬 크고 흐려서 쓰지 않는다.
        .shadow(color: DesignSystem.Color.black.opacity(0.2), radius: 2, x: 0, y: 4)
    }

    // 탭 영역이 Apple 최소 권장치(44pt)에 못 미치지 않도록 `contentShape`를 바깥쪽 세로 padding까지
    // 포함해서 적용한다(안쪽 padding(6)만으로는 raw 행 높이가 44pt에 못 미친다).
    private func button(_ item: Item) -> some View {
        Button(action: item.action) {
            HStack(spacing: 8) {
                Image(asset: item.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(DesignSystem.Color.gray200)

                Text(item.title)
                    .momogoTypography(.smMedium)
                    .foregroundStyle(DesignSystem.Color.white)

                Spacer(minLength: 0)
            }
            .padding(6)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

public struct DSMenuAnchorKey: PreferenceKey {
    public static let defaultValue: Anchor<CGRect>? = nil

    public static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue() ?? value
    }
}

public extension View {
    /// 메뉴가 따라붙을 기준 뷰를 표시한다. `momogoMenuOverlay(isPresented:items:anchorContent:)`와 짝으로 쓴다.
    func dsMenuAnchor() -> some View {
        anchorPreference(key: DSMenuAnchorKey.self, value: .bounds) { $0 }
    }

    /// `dsMenuAnchor()`로 표시한 뷰 바로 아래(8pt)에 메뉴를 띄운다.
    ///
    /// 딤은 화면 전체를 덮으므로 기준 뷰도 함께 어두워진다. Figma 시안은 기준 버튼만 밝게 남기므로
    /// `anchorContent`로 받은 사본을 딤 위 같은 좌표에 다시 그린다.
    /// 닫기(딤 탭·항목 선택)는 이 오버레이가 책임진다 — 호출부가 항목마다 닫기를 중복 작성하지 않도록.
    func momogoMenuOverlay(
        isPresented: Binding<Bool>,
        items: [DSMenu.Item],
        @ViewBuilder anchorContent: @escaping () -> some View
    ) -> some View {
        overlayPreferenceValue(DSMenuAnchorKey.self) { anchor in
            if isPresented.wrappedValue, let anchor {
                // `GeometryReader`를 `ZStack`의 형제로 두면(중첩) 같은 스택 안의 다른 형제가 렌더링되지
                // 않는 현상이 있어(실측 확인됨), `GeometryReader` 대신 순수 `ZStack` + `visualEffect(_:)`로
                // 구성한다. `visualEffect`는 레이아웃에 관여하지 않고 순수 시각 효과(오프셋)만 적용하므로
                // 이 문제 자체가 발생하지 않는다. 기준 뷰 사본은 원본과 동일한 콘텐츠라 자연 크기가 이미
                // 앵커와 같으므로, 위치만 옮기면 되고 별도로 frame(width:height:)를 강제할 필요가 없다.
                ZStack(alignment: .topLeading) {
                    Button {
                        isPresented.wrappedValue = false
                    } label: {
                        DesignSystem.Color.black.opacity(0.4)
                            .ignoresSafeArea()
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("메뉴 닫기")

                    anchorContent()
                        .visualEffect { content, proxy in
                            let frame = proxy[anchor]
                            return content.offset(x: frame.minX, y: frame.minY)
                        }

                    DSMenu(items.map { item in
                        DSMenu.Item(item.title, icon: item.icon) {
                            isPresented.wrappedValue = false
                            item.action()
                        }
                    })
                    .visualEffect { content, proxy in
                        let frame = proxy[anchor]
                        return content.offset(x: frame.maxX - DSMenu.defaultWidth, y: frame.maxY + 8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
                .accessibilityAddTraits(.isModal)
            }
        }
    }
}
