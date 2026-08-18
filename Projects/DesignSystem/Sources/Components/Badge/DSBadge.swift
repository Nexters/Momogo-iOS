import SwiftUI

/// Figma `Chip/New`(node 1600:61249 내 인스턴스)에 대응하는 작은 배지.
/// 반투명 검정 배경 + 옐로우 텍스트 조합이라 `DSChip`의 tone 어디에도 맞지 않아 별도 컴포넌트로
/// 분리하되, 크기는 `DSChip(size: .small)`과 동일한 xsSemistrong(12px) + 8/4 패딩을 따라 그룹명
/// 옆에서도 눈에 띄게 한다.
public struct DSBadge: View {
    private let title: String

    public init(_ title: String) {
        self.title = title
    }

    /// 그룹 목록 등에서 "새 소식 있음"을 알리는 New 배지.
    public static var new: DSBadge { DSBadge("New") }

    public var body: some View {
        Text(title)
            .momogoTypography(.xsSemistrong)
            .fixedSize()
            .foregroundStyle(DesignSystem.Color.primary500)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(DesignSystem.Color.black.opacity(0.32))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r10))
    }
}
