import SwiftUI

/// Figma `Chip/New`(node 1600:61249 내 인스턴스)에 대응하는 작은 배지.
/// 반투명 검정 배경 + 10px 옐로우 텍스트 조합이라 `DSChip`의 tone/typography 스케일 어디에도 맞지 않아
/// 별도 컴포넌트로 분리한다. 10px는 디자인 시스템 공용 타이포(`DesignSystem.Typography`)의 최소 단위인
/// xs(12px)보다 작아 이 배지 전용 값으로만 쓴다.
public struct DSBadge: View {
    private let title: String

    public init(_ title: String) {
        self.title = title
    }

    /// 그룹 목록 등에서 "새 소식 있음"을 알리는 New 배지.
    public static var new: DSBadge { DSBadge("New") }

    public var body: some View {
        Text(title)
            .font(DesignSystemFontFamily.WantedSans.medium.swiftUIFont(size: 10))
            // Figma 스펙: letterSpacing -0.2px = size(10) * -2%, 공용 타이포와 동일한 비율.
            .tracking(-0.2)
            .fixedSize()
            .foregroundStyle(DesignSystem.Color.primary500)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(DesignSystem.Color.black.opacity(0.32))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r12))
    }
}
