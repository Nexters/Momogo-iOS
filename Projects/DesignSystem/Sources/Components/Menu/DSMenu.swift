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
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                button(item)

                if index < items.count - 1 {
                    DesignSystem.Color.gray800
                        .frame(height: 1)
                }
            }
        }
        .frame(width: width)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(DesignSystem.Color.gray900)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r16))
        .overlay {
            RoundedRectangle(cornerRadius: DesignSystem.Radius.r16)
                .stroke(DesignSystem.Color.gray700, lineWidth: 1)
        }
        // Figma "Floating Blur"(0 4px 4px / 검정 20%) 근사. 공용 `momogoShadow()`는 radius 32 · 32%로
        // 이 스펙보다 훨씬 크고 흐려서 쓰지 않는다.
        .shadow(color: DesignSystem.Color.black.opacity(0.2), radius: 2, x: 0, y: 4)
    }

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
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 8)
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
                // 않는 현상이 있어(실측 확인됨), `GeometryReader` 자신을 최상위 컨테이너로 써서
                // 딤·기준 뷰 사본·메뉴 세 개를 그 안의 형제로 둔다(GeometryReader도 다중 자식을 암묵적
                // ZStack처럼 topLeading 정렬로 쌓는다).
                GeometryReader { proxy in
                    let frame = proxy[anchor]

                    DesignSystem.Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { isPresented.wrappedValue = false }

                    anchorContent()
                        .frame(width: frame.width, height: frame.height)
                        .offset(x: frame.minX, y: frame.minY)

                    DSMenu(items.map { item in
                        DSMenu.Item(item.title, icon: item.icon) {
                            isPresented.wrappedValue = false
                            item.action()
                        }
                    })
                    .offset(x: frame.maxX - DSMenu.defaultWidth, y: frame.maxY + 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
                .accessibilityAddTraits(.isModal)
            }
        }
    }
}
